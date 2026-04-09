import "../base"
import "../components"

import QtQuick
import QtQuick.Controls

TextField {
    id: root

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

    cursorDelegate: Rectangle {
        property bool disableBlink

        implicitWidth: 2
        opacity: 1

        onXChanged: {
            opacity = 1;
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
            running: disableBlink
            repeat: true
            onTriggered: {
                opacity = opacity ? 0 : 1;
            }
        }
    }
}
