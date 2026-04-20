import QtQuick

import "../../core"

Item {
    anchors.fill: parent

    MouseArea {
        anchors.fill: parent
        onClicked: SharedState.overlayDropPanelType = 0;
        focus: true

        Keys.onPressed: ev => {
            if (ev.key === Qt.Key_Escape) SharedState.overlayDropPanelType = 0;
        }

        MouseArea {
            width: 250
            height: 1
            anchors.horizontalCenter: parent.horizontalCenter
            cursorShape: Qt.PointingHandCursor
            onClicked: SharedState.toggleOverlay(1)
        }
    }

    Left {}
    Center {}
    Right {}
}
