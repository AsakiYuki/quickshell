import Quickshell
import QtQuick

import "./views"
import "./controllers" as Controllers

ShellRoot {
    id: shell

    Controllers.FileSystem { id: fs }
    Controllers.ChildProcess { id: chillProcess }

    Variants {
        model: Quickshell.screens
        delegate: Scope {
            Views {}
        }
    }
}
