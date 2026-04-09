pragma Singleton

import Quickshell
import Qt.labs.platform

Singleton {
    id: _root

    readonly property string home: StandardPaths.standardLocations(StandardPaths.HomeLocation)
    readonly property string pictures: StandardPaths.standardLocations(StandardPaths.PicturesLocation)
}
