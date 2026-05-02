pragma Singleton

import Quickshell
import Qt.labs.platform

Singleton {
    id: _root

    readonly property string home: String(StandardPaths.standardLocations(StandardPaths.HomeLocation)[0]).slice(7)
    readonly property string pictures: String(StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0]).slice(7)
    readonly property string config: String(StandardPaths.standardLocations(StandardPaths.ConfigLocation)[0]).slice(7)

    readonly property string quickshell: `${config}/quickshell`
    readonly property string settings: `${config}/asa.quickshell.json`
    readonly property string wallpapers: `${pictures}/Wallpapers`
}
