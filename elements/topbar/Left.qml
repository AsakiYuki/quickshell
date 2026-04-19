import QtQuick

import "../../components"

Row {
    height: parent.height

    anchors.left: parent.left
    anchors.leftMargin: 5
    spacing: 5

    Workspaces {}
    MusicPlayer {}
}
