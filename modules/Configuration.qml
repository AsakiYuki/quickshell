import Quickshell
import QtQuick

Scope {
    id: _configuration

    property string wallpaper: ""

    onWallpaperChanged: save()

    function save() {
        fs.writefile("/home/asakiyuki/.config/quickshell/settings.json", JSON.stringify({
            wallpaper
        }));
    }

    Component.onCompleted: {
        fs.readfile("/home/asakiyuki/.config/quickshell/settings.json").then(v => {
            const data = JSON.parse(v);

            wallpaper = data.wallpaper || "wallpaper-0.jpg";
        }).catch(() => {
            console.log("cac");
            wallpaper = "wallpaper-0.jpg";
        });
    }
}
