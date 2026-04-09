import Quickshell

Scope {
    id: _root

    function exec(cmd, callback) {
        const obj = Qt.createQmlObject(`
            import Quickshell.Io

            Process {
                property var callback: () => {}
                running: true
                stdout: StdioCollector {
                    onStreamFinished: callback(this.text)
                }
            }
        `, _root);

        obj.callback = text => {
            callback(text);
            obj.destroy();
        };
        obj.command = cmd;
    }
}
