import "../base"
import "../components"

import QtQuick
import QtQuick.Controls

TextField {
    id: root

    property bool allowTyping: true

    height: 30
    color: Catppuccin.text
    placeholderTextColor: Catppuccin.subtext0

    leftPadding: 15
    rightPadding: 15

    font.pixelSize: 11

    background: RadiusRectangle {
        anchors.fill: parent
        color: Catppuccin.crust
    }

    onTextChanged: {
        if (root.allowTyping)
            return;
        text = "";
    }

    cursorDelegate: Rectangle {
        id: _blink
        property bool disableBlink

        implicitWidth: 2
        opacity: 1

        onXChanged: {
            opacity = root.allowTyping * 1;
            disableBlink = false;
            disableBlink = true;
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 500
                easing.type: Easing.OutQuart
            }
        }

        Timer {
            interval: 750
            running: _blink.disableBlink && root.allowTyping
            repeat: true
            onTriggered: {
                _blink.opacity = _blink.opacity ? 0 : 1;
            }
        }
    }
}
