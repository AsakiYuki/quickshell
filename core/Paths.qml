pragma Singleton

import Quickshell
import Qt.labs.platform

Singleton {
    id: _root

    readonly property string home: StandardPaths.standardLocations(StandardPaths.HomeLocation)
    readonly property string pictures: StandardPaths.standardLocations(StandardPaths.PicturesLocation)
    readonly property string config: StandardPaths.standardLocations(StandardPaths.ConfigLocation)

    readonly property string shellConfig: `${config}/asashell.json`
}
