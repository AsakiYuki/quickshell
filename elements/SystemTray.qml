import QtQuick

import Quickshell

import "../utils/Utils.js" as Utils

import "../components"
import "../base"
import "../core"

Loader {
  id: _loader

  anchors.right: parent.right
  anchors.top: parent.top
  anchors.topMargin: 50
  anchors.rightMargin: 5

  Timer {
    interval: 0
    running: SharedState.isMoreTrayOpened
    onTriggered: {
      _loader.active = true
    }
  }

  active: false

  sourceComponent: RadiusRectangle {
    radius: 15
    id: _system_tray
    clip: true

    NumberAnimation {
      target: _system_tray
      running: SharedState.isMoreTrayOpened
      properties: "y"
      from: -_system_tray.height - 50
      to: 0
      duration: 350
      easing.type: Easing.OutQuint
    }

    NumberAnimation {
      target: _system_tray
      running: !SharedState.isMoreTrayOpened || !SystemTray.hideTray.length
      properties: "y"
      from: 0
      to: -_system_tray.height - 50
      duration: 350
      easing.type: Easing.OutQuint

      onFinished: {
        _loader.active = false;
        SharedState.isMoreTrayOpened = false;
      }
    }

    width: _repeater.model ? _grid.width : _text.width + 35
    height: _repeater.model ? _grid.height : _text.height + 25

    StyledText {
      id: _text
      visible: !_repeater.model
      anchors.centerIn: parent
      text: "Nothing here."
    }

    Grid {
      id: _grid
      columns: 5
      padding: 10
      
      Repeater {
        id: _repeater
        model: SystemTray.hideTray.length

        Item {
          id: _trayitem
          required property int index;
          readonly property var modelData: SystemTray.hideTray[index];

          width: 30
          height: 30

          QsMenuAnchor {
              id: menu
              menu: _trayitem.modelData.menu
              anchor.item: _trayitem
              anchor.margins.top: 35
              anchor.edges: Edges.Right
          }

          StyledButton {
            anchors.fill: parent

            property int offsetX;
            property int offsetY;
            property bool trayDrag: false;

            function setDragIcon(icon) {
              overlay.setDragIcon(icon)
            }

            normalColor: Catppuccin.base
            hoverColor: Catppuccin.surface1
            pressedColor: "transparent"

            onDrag: (ev, delta) => {
              if (Math.abs(delta.x) > 1.5 || Math.abs(delta.y) > 1.5) {
                setDragIcon(modelData.icon)
                trayDrag = true;
              }

              const {x, y} = this.mapToGlobal(ev.x, ev.y)
              overlay.setOverlayPosition(x - offsetX, y - offsetY)
            }

            onRightClicked: {
              menu.open()
            }

            onPressed: ev => {
              offsetX = ev.x
              offsetY = ev.y
            }

            onReleased: ev => {
              if (ev.button === Qt.LeftButton) {
                overlay.setDragIcon("");
                
                if (trayDrag) {
                  trayDrag = false;
                  const {x, y} = this.mapToGlobal(ev.x, ev.y)
                  if (Utils.isMouseInsideTargetElement(x, y, 0, 0, topbar.systemTrayElement)) {
                    configuration.hideTrayID = configuration.hideTrayID.filter(v => v !== [modelData.id, modelData.tooltipTitle, modelData.title].join("&"))
                  }
                } else {
                  modelData.activate()
                  SharedState.isMoreTrayOpened = false
                }
              }
            }

            Image {
              anchors.centerIn: parent
              source: modelData.icon
              width: 20
              height: 20
            }
          }
        }
      }
    }
  }
} 