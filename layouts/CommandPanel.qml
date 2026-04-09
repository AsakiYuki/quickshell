import QtQuick

import "./commands"

Item {
    id: _root

    property int commandId: -1
    property bool isShow: false

    anchors.centerIn: parent

    width: wallpaper.width
    height: wallpaper.height

    ChangeWallpaper {
        id: wallpaper

        enabled: commandId === 0
    }
}
