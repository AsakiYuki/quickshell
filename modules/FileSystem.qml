import QtQuick

import Quickshell
import Quickshell.Io

Scope {
    id: _root

    property Component fileViewComponent: FileView {
        watchChanges: false
    }

    function readdir(path, hidden) {
        return new Promise(res => {
            const cmd = hidden
                ? ["bash", "-c", `ls -A "${path}"`]
                : ["bash", "-c", `ls "${path}"`]
            chillProcess.exec(cmd, out =>
                res(out.trim() ? out.trim().split("\n") : [])
            )
        })
    }

    function readdirrec(dir, hidden) {
        return new Promise((res, rej) => {
            const cmd = hidden
                ? ["bash", "-c", `find "${dir}" -mindepth 1 -name '.*' -o -print`]
                : ["bash", "-c", `find "${dir}" -mindepth 1 ! -name '.*' -printf '%P\n'`]
            chillProcess.exec(cmd, (out, err) => {
                if (err?.trim()) return rej(err)
                res(out.trim() ? out.trim().split("\n") : [])
            })
        })
    }

    function readfile(path) {
        return new Promise(res => {
            const fv = fileViewComponent.createObject(_root)
            fv.path = path
            fv.onLoaded.connect(() => {
                res(fv.text())
                fv.destroy()
            })
        })
    }

    function readfiles(paths) {
        return Promise.all(paths.map(p => readfile(p)))
    }

    function writefile(path, text) {
        const fv = fileViewComponent.createObject(_root)
        fv.path = path
        fv.setText(text)
        fv.save()
        fv.destroy()
        return Promise.resolve(true)
    }

    function exist(path) {
        return new Promise(res => {
            chillProcess.exec(
                ["bash", "-c", `[ -e "${path}" ] && echo 1 || echo 0`],
                text => res(text.trim() === "1")
            )
        })
    }
}