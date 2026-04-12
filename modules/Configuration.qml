import Quickshell
import QtQuick

import "../core"

Scope {
    id: _configuration

    property string wallpaper: ""
    property bool touchpad: false
    property bool capsLock: false

    onWallpaperChanged: save()
    onTouchpadChanged: {
        save();
        chillProcess.exec(["hyprctl", "keyword", "$LAPTOP_TOUCHPAD_ENABLE", touchpad, "-r"]);
    }

    function save() {
        _save.running = false;
        _save.running = true;
    }

    Timer {
        id: _save
        running: false
        interval: 1000
        onTriggered: {
            fs.writefile(Paths.settings, JSON.stringify({
                wallpaper,
                touchpad
            }));
        }
    }

    Component.onCompleted: {
        fs.readfile(Paths.settings).then(v => {
            const data = JSON.parse(v);
            wallpaper = data.wallpaper ?? "wallpaper-0.jpg";
            touchpad = data.touchpad ?? true;
        }).catch(err => {
            wallpaper = "wallpaper-0.jpg";
            touchpad = true;
        });

        chillProcess.exec(["sh", "-c", `hyprctl devices | grep -B 6 "main: yes" | grep capsLock | head -1 | awk '{print $2}'`], v => capsLock = v.trim() === "yes");
    }
}
