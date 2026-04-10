import QtQuick

Item {
    id: _root

    property bool isActive: false
    property int commandId: -1

    width: _loader.width
    height: _loader.height

    Loader {
        id: _loader
        active: _root.isActive
        source: ["Wallpapers.qml"][_root.commandId] || ""
    }
}
