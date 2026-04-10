import QtQuick

Item {
    id: _root

    property bool isActive: false
    property string command: "Wallpapers"

    width: _loader.width
    height: _loader.height

    Loader {
        id: _loader
        active: _root.isActive
        source: `${_root.command}.qml`
    }
}
