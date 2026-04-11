import QtQuick

Item {
    id: _root

    property bool isActive: false
    property string command: "Wallpapers"
    clip: true

    width: Math.max(_loader.width, 150)
    height: Math.max(_loader.height, 75)

    function onKeyPressed(ev) {
        if (_loader.children.length === 0) return
        const func = _loader.children[0].onKeyPressed;
        if (func) func(ev)
    }

    Loader {
        id: _loader
        active: _root.isActive

        source: `${_root.command}.qml`
    }
}
