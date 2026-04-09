import Quickshell

import "../components"
import "../modules"
import "../core"

Scope {
    CustomShortcut {
        name: "launcher"
        onPressed: SharedState.isLauncherOpened = !SharedState.isLauncherOpened
    }
}
