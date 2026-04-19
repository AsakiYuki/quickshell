import QtQuick

import "../../core"

Item {
    anchors.fill: parent

    MouseArea {
        width: 250
        height: 1
        anchors.horizontalCenter: parent.horizontalCenter
        cursorShape: Qt.PointingHandCursor
        onClicked: SharedState.isLauncherOpened = true;
    }

    Left {}
    Center {}
    Right {}
}
