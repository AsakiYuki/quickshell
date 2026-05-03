import QtQuick

import "../components"
import "../base"
import "../core"
import "../elements/launcher" as Launcher
import "../utils/FuzzySort.js" as FuzzySort

Item {
  id: root
  width: 630
  height: launcherListView.height

  property int viewIndex: 0
  property int selectorIndex: 0
  property int count: launcherListView.model.length
  property int maxSelector: Math.min(launcherListView.maxView || 0, count)

  function onExecute() {
    SharedState.isLauncherOpened = false;
  }

  function onTextfieldTyping(text) {
    launcherListView.search = text.trim();
  }

  function goUp() {
      if (selectorIndex < 1) {
          if (viewIndex === 0) {
              selectorIndex = maxSelector - 1;
              viewIndex = count;
          } else {
              viewIndex--;
          }
      } else {
          selectorIndex--;
      }
  }

  function goDown() {
      if (selectorIndex > maxSelector - 2) {
          if (viewIndex + maxSelector >= count) { 
              selectorIndex = 0;
              viewIndex = 0;
          } else {
              viewIndex++;
          }
      } else {
          selectorIndex++;
      }
  }

    onSelectorIndexChanged: {
        let clamped = Math.max(0, Math.min(selectorIndex, maxSelector - 1));
        if (selectorIndex !== clamped) selectorIndex = clamped;
    }

    onViewIndexChanged: {
        let clamped = Math.max(0, Math.min(count - maxSelector, viewIndex));
        if (viewIndex !== clamped) {
            viewIndex = clamped;
        }
        launcherListView.viewIndex = viewIndex;
    }

  function reset() {
      viewIndex = 0;
      selectorIndex = 0;
  }

  function execute(index) {
    const exec = launcherListView.model[index].execute
    if (exec) exec()
    onExecute()
  }

  function onKeyPressed(ev) {
    switch (ev.key) {
      case Qt.Key_Down: root.goDown(); break;
      case Qt.Key_Up: root.goUp(); break;
      case Qt.Key_Enter: 
      case Qt.Key_Return: root.execute(root.viewIndex + root.selectorIndex)
    }
  }

  property list<var> listEntries: Array.from({ length: 30 }, ($, i) => ({
    text: `Entry Item ${i + 1}`,
    subtext: `Entry Item ${i + 1}`,
    icon: "../../assets/icons/images.png",
    execute: () => console.log(`Execute entry item ${i + 1}`)
  }))

  RadiusRectangle {
    id: selectorPanel
    anchors.horizontalCenter: parent.horizontalCenter
    color: Catppuccin.surface0
    width: parent.width
    height: 55
    y: root.selectorIndex * 55
    Behavior on y { NumberAnimation { duration: 350; easing.type: Easing.OutExpo } }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: (ev) => {
      const clickedIndex = (mouseY / 55 >> 0)
      if (root.selectorIndex === clickedIndex) root.execute(root.selectorIndex + root.viewIndex);
      else root.selectorIndex = clickedIndex;
    }
    onWheel: (ev) => {
        if (ev.angleDelta.y > 0) root.goUp();
        else root.goDown();
    }
  }

  Launcher.LauncherListView {
    id: launcherListView
    width: parent.width - 20
    property string search: ""

    viewIndex: root.viewIndex

    property list<var> entries: root.listEntries.map(a => ({
        name: FuzzySort.prepare(a.text),
        comment: FuzzySort.prepare(a.subtext),
        entry: a
    }))

    onSearchChanged: {
      root.reset()
      if (model === "") model = root.listEntries;
      else model = SharedState.search(search, entries, false).map(v => v.entry);
      if (model.length === 0) model = noResult();
    }

    model: root.listEntries

    function noResult() {
      return [
        {
            text: "No results",
            subtext: "Try again",
            icon: "../../assets/icons/search_off.png"
        }
      ];
    }
  }
}