import QtQuick

import "../../components"

Row {
    height: parent.height

    anchors.left: parent.left
    anchors.leftMargin: 5
    spacing: 10

    Workspaces {}

    OverflowScrollText {
        id: _text
        text: "Bảo sao Đức VIP vãi lồn, cả box chỉ biết ước"
        anchors.verticalCenter: parent.verticalCenter

        textComponent: StyledText {
            font.pixelSize: 13
            font.weight: 1000
        }
    }
}
