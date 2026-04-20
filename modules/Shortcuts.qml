import Quickshell
import QtQuick

import "../components"
import "../modules"
import "../core"

Scope {
    CustomShortcut {
        name: "launcher"
        onPressed: SharedState.toggleOverlay(1)
    }

    CustomShortcut {
        name: "touchpadtoggle"
        onPressed: {
            configuration.touchpad = !configuration.touchpad;
        }
    }


    CustomShortcut {
        name: "hdrtoggle"
        onPressed: {
            configuration.hdr = !configuration.hdr;
        }
    }

    CustomShortcut {
        name: "capslock"
        onPressed: {
            configuration.capsLock = !configuration.capsLock;
        }
    }
}
