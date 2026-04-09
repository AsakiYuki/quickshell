pragma Singleton

import Quickshell

Singleton {
    id: _root

    property bool isLauncherOpened: false

    readonly property bool isOverlay: isLauncherOpened
    function onOverlayClicked() {
        isLauncherOpened = false;
    }
}
