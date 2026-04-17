import QtQuick

import "../base"

Rectangle {
  id: _root
  property color normalColor: Catppuccin.blue
  property color hoverColor: Catppuccin.sapphire
  property color pressedColor: Catppuccin.sky

  property bool isDrag: false
  property bool isPressed: false

  height: 100
  width: 100
  radius: 15

  color: normalColor

  signal clicked()
  signal doubleClicked()
  signal rightClicked()
  signal rightDoubleClicked()
  signal middleClicked()
  signal middleDoubleClicked()

  signal mouseMoved(MouseEvent ev)
  signal drag(MouseEvent ev, var delta)
  signal pressed(MouseEvent ev)
  signal released(MouseEvent ev)
  
  signal hovered()
  signal unhovered()

  Behavior on color {
    ColorAnimation {
      duration: 250
    }
  }

  MouseArea {
    property bool isFirstClick: true
    property int lastMouseX: 0
    property int lastMouseY: 0
    
    function getMouseDelta(ev) {
      const deltaX = ev.x - lastMouseX
      const deltaY = ev.y - lastMouseY

      lastMouseX = ev.x
      lastMouseY = ev.x

      return {x: deltaX, y: deltaY}
    }
    
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

    onClicked: ev => {
      if (ev.button === Qt.LeftButton) {
        _root.clicked();
      } else if (ev.button === Qt.RightButton) {
        _root.rightClicked();
      } else if (ev.button === Qt.MiddleButton) {
        _root.middleClicked();
      }
    }

    onDoubleClicked: ev => {
      if (ev.button === Qt.LeftButton) {
        _root.doubleClicked();
      } else if (ev.button === Qt.RightButton) {
        _root.rightDoubleClicked();
      } else if (ev.button === Qt.MiddleButton) {
        _root.middleDoubleClicked();
      }
    }

    onMouseXChanged: ev => {
      if (_root.isPressed) {
        if (isFirstClick) isFirstClick = false;
        else _root.drag(ev, getMouseDelta(ev))
      }

      _root.mouseMoved(ev);
    }

    onReleased: ev => {
      isFirstClick = true;
      _root.released(ev);
      _root.isDrag = _root.isPressed = false;
    }

    onPressed: ev => {
      if (ev.button === Qt.LeftButton) _root.isPressed = true;
      getMouseDelta(ev)
      _root.pressed(ev);
    }

    onEntered: {
      parent.color = _root.hoverColor
      _root.hovered();
    }

    onExited: {
      parent.color = _root.normalColor
      _root.unhovered();
    }
  }
}