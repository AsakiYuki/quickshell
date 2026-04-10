import Quickshell
import QtQuick

import "../core"

Scope {
    id: _configuration

    property string wallpaper: ""

    onWallpaperChanged: save()

    function save() {
        fs.writefile(Paths.settings, JSON.stringify({
            wallpaper
        }));
    }

    Component.onCompleted: {
        fs.readfile(Paths.settings).then(v => {
            const data = JSON.parse(v);
            wallpaper = data.wallpaper || "wallpaper-0.jpg";
        }).catch(err => {
            wallpaper = "wallpaper-0.jpg";
        });
    }
}
