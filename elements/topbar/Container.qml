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
    }

    Left {}
    Center {}
    Right {}
}
