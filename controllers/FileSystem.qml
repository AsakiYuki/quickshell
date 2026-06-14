import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property Component fileView: FileView {
        watchChanges: false
        printErrors: false
        
    }

    function readfile(path) {
        return new Promise((res, rej) => {
            const fv = root.fileView.createObject(root)
            fv.path = path
            fv.onLoaded.connect(() => {
                res(fv.text())
                fv.destroy()
            })
            fv.onLoadFailed.connect(() => {
                rej(null)
                fv.destroy()
            })
        })
    }

    function writefile(path, content) {
        const fv = root.fileView.createObject(root)
        fv.path = path
        fv.setText(content)
        fv.destroy()
        return Promise.resolve(true)
    }
}