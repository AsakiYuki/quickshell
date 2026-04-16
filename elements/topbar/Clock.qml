import QtQuick

import "../../components"
import "../../base"

Rectangle {
    width: _text.width + 35
    height: _text.height + 15
    color: Catppuccin.surface0
    radius: height / 2
    anchors.verticalCenter: parent.verticalCenter

    StyledText {
        id: _text
        anchors.centerIn: parent
        property string format: "HH:mm:ss • dddd, dd/MM/yy"
        property var date: new Date()
        text: Qt.formatDateTime(date, format)

        Timer {
            interval: 1000
            repeat: true
            running: true
            onTriggered: parent.date = new Date()
        }
    }
}
