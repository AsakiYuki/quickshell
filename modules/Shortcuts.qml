import Quickshell
import QtQuick

import "../components"
import "../modules"
import "../core"

Scope {
    Timer {
        id: launcherTimer
        property bool isBlocked: false
        running: false
        interval: 350
        onTriggered: {
            isBlocked = false;
        }
    }

    CustomShortcut {
        name: "launcher"
        onPressed: {
            if (!launcherTimer.isBlocked) {
                launcherTimer.isBlocked = launcherTimer.running = true;
                SharedState.isLauncherOpened = !SharedState.isLauncherOpened;
            }
        }
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
