import QtQuick

import "../../components"
import "../../base"
import "../../core"

DropPanel {
    id: root
    
    active: SharedState.overlayDropPanelType === 1

    direction: DropPanel.Direction.TOP
    anchors.right: parent.right
    anchors.rightMargin: 5
    viewY: 5

    content: Item {
        width: 380
        height: container.height + 40

        StyledText {
            anchors.centerIn: parent
            text: "Hello World!"
        }

        Row {
            id: container
            anchors.centerIn: parent
            width: parent.width - 40
        }
    }
}