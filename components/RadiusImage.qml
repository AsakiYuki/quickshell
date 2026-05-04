pragma ComponentBehavior: Bound

import QtQuick
import Qt5Compat.GraphicalEffects

Image {
    id: root
    property int radius: 15

    layer.enabled: true
    layer.effect: OpacityMask {
        maskSource: Rectangle {
            width: root.width
            height: root.height
            radius: root.radius
        }
    }
}