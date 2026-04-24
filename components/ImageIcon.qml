import QtQuick
import QtQuick.Effects

import "../base"

Item {
    id: root
    width: 48
    height: 48

    property string source: ""
    property color color: Catppuccin.text

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

    Image {
        id: sourceImage
        source: root.source
        sourceSize: Qt.size(root.width, root.height)
        mipmap: true
        visible: false
    }

    MultiEffect {
        source: sourceImage
        anchors.fill: parent
        colorization: 1
        colorizationColor: root.color
    }
}
