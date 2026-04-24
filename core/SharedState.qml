pragma Singleton

import Quickshell
import "../utils/FuzzySort.js" as FuzzySort

Singleton {
    id: _root

    property int overlayDropPanelType: 0
    property bool isLauncherOpened: false
    readonly property bool isOverlay: overlayDropPanelType > 0
    
    onIsOverlayChanged: {
        console.info("Is overlay focus", isOverlay)
    }

    onOverlayDropPanelTypeChanged: {
        console.info("Overlay Drop Panel:", overlayDropPanelType)
    }

    function toggleOverlay(type) {
        overlayDropPanelType = (overlayDropPanelType === type) ? 0 : type;
    }
    
    function onOverlayClicked() {
        if (isLauncherOpened) isLauncherOpened = false;
        else overlayDropPanelType = 0;
    }

    function parseIconPath(icon) {
        if (icon[0] === "/")
            return icon;
        else
            return `image://icon/${icon}`;
    }

    function search(search, array, allowParseIcon = true) {
        return FuzzySort.go(search, array, {
            all: true,
            keys: ["name", "comment"],
            scoreFn: r => (r[0].score > 0) ? r[0].score * 0.9 + r[1].score * 0.1 : 0
        }).map(r => {
            const v = r.obj;

            return {
                icon: allowParseIcon ? SharedState.parseIconPath(v.entry.icon) : v.entry.icon,
                text: v.entry.name,
                subtext: v.entry.comment,
                entry: v.entry
            };
        });
    }

    property bool capsLock: false
}
