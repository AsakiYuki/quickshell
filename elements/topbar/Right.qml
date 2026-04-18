import QtQuick

Row {
    height: parent.height

    anchors.right: parent.right
    anchors.rightMargin: 5
    spacing: 10

    SystemTray {
        id: systemTray
    }
}
