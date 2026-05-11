import QtQuick

import Quickshell
import Quickshell.Io

Scope {
    id: _root

    property Component procComponent: Process {
        stdout: StdioCollector {}
    }

    function exec(cmd, callback) {
        const proc = procComponent.createObject(_root)
        proc.stdout.onStreamFinished.connect(() => {
            if (callback) callback(proc.stdout.text)
            proc.destroy()
        })
        proc.command = cmd
        proc.running = true
    }
}