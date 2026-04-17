import Quickshell
import QtQuick

import "../core"

Scope {
    id: _configuration

    property string wallpaper: ""
    property bool touchpad: false
    property bool capsLock: false
    property var trayIndex: ({})
    property list<string> hideTrayID: []

    onTrayIndexChanged: save()
    onHideTrayIDChanged: {
        save()
        if (SystemTray.hideTrayID !== hideTrayID) {
            SystemTray.hideTrayID = hideTrayID;
        }
    }

    onWallpaperChanged: save()
    onTouchpadChanged: {
        save();
        chillProcess.exec(["hyprctl", "keyword", "$LAPTOP_TOUCHPAD_ENABLE", touchpad, "-r"]);
    }

    function save() {
        _save.restart()
    }

    Timer {
        id: _save
        running: false
        interval: 1000
        onTriggered: {
            fs.writefile(Paths.settings, JSON.stringify(_configuration));
        }
    }

    Component.onCompleted: {
        fs.readfile(Paths.settings).then(v => {
            const data = JSON.parse(v);
            wallpaper = data.wallpaper ?? "wallpaper-0.jpg";
            touchpad = data.touchpad ?? true;
            trayIndex = data.trayIndex ?? {};
            hideTrayID = data.hideTrayID ?? [];
        }).catch(err => {
            wallpaper = "wallpaper-0.jpg";
            touchpad = true;
            trayIndex = {};
            hideTrayID = [];
        });

        chillProcess.exec(["sh", "-c", `hyprctl devices | grep -B 6 "main: yes" | grep capsLock | head -1 | awk '{print $2}'`], v => capsLock = v.trim() === "yes");
    }
}
