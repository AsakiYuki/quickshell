pragma Singleton

import Quickshell
import "../utils/FuzzySort.js" as FuzzySort

Singleton {
    id: _root

    property bool isLauncherOpened: false
    property bool isMoreTrayOpened: false

    readonly property bool isOverlay: isLauncherOpened || isMoreTrayOpened

    onIsLauncherOpenedChanged: {
        if (isLauncherOpened) {
            isMoreTrayOpened = false;
        }
    }
    
    function onOverlayClicked() {
        isLauncherOpened = false;
        isMoreTrayOpened = false;
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
