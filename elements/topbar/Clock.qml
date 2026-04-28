import QtQuick

import "../../components"
import "../../core"
import "../../base"

SimpleButton {
    width: _text.width + 35
    height: 35
    color: Catppuccin.surface0
    radius: height / 2
    anchors.verticalCenter: parent.verticalCenter

    onClicked: {
        SharedState.toggleOverlay(4);
    }

    StyledText {
        id: _text
        anchors.centerIn: parent
        property string format: "HH:mm:ss • dddd, dd/MM/yyyy"
        property var date: new Date()
        text: Qt.formatDateTime(date, format)

        FrameAnimation {
            running: !Workspaces.current?.hasFullscreen
            onTriggered: _text.date = new Date()
        }
    }
}
