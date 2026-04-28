import QtQuick

import "../base"


import "../utils/Color.js" as ColorUtils

Rectangle {
    id: _root

    property color normalColor: Catppuccin.surface0
    property color hoverColor: ColorUtils.lighten(`${normalColor}`, 15)

    property bool isDrag: false
    property bool isPressed: false

    height: 100
    width: 100
    radius: 15

    color: normalColor

    signal clicked
    signal rightClicked

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

        onClicked: ev => {
            if (ev.button === Qt.LeftButton)
                _root.clicked();
            else if (ev.button === Qt.RightButton)
                _root.rightClicked();
        }

        onEntered: parent.color = _root.hoverColor
        onExited: parent.color = _root.normalColor
    }
}

