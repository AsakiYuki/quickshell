import Quickshell
import QtQuick

import "./modules" as Modules
import "./core"

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

    Modules.Topbar {
        id: topbar
    }

    Modules.Overlay {
        id: overlay
    }

    Modules.Shortcuts {}
    Modules.Wallpaper {}
}
