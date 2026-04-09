import Quickshell
import QtQuick

import "./modules" as Modules
import "./core" as Core

ShellRoot {
    id: root

    Modules.ChillProcess {
        id: chillProcess
    }

    Modules.FileSystem {
        id: fs
    }

    Modules.Configuration {
        id: configuration
    }

    Modules.Shortcuts {}

    Modules.Overlay {}
    Modules.Wallpaper {}

    Component.onCompleted: {
        console.log(Core.Paths.);
    }
}
