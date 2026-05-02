//@ pragma UseQApplication

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

    Modules.Overlay {
        id: overlay
    }
    
    Modules.Topbar {
        id: topbar
        property var systemTrayElement;
        property var musicPlayer;
    }

    Modules.Shortcuts {}
    Modules.Wallpaper {}
    Modules.Desktop {}
}
