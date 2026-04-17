import QtQuick

import "../base"

Rectangle {
  id: _root
  property color normalColor: Catppuccin.blue
  property color hoverColor: Catppuccin.sapphire
  property color pressedColor: Catppuccin.sky

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
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

    onMouseXChanged: ev => {
      _root.mouseMoved(ev);
    }

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

    onReleased: ev => {
      _root.released(ev);
    }

    onPressed: ev => {
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