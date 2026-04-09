import Quickshell

Scope {
    id: _root

    function readdir(path, hidden) {
        return new Promise(res => {
            chillProcess.exec(hidden ? ["ls", "-a", path] : ["ls", path], out => res(out.trim().split("\n")));
        });
    }

    function readfile(path) {
        return new Promise(res => {
            chillProcess.exec(["cat", path], text => res(text));
        });
    }

    function writefile(path, text) {
        return new Promise(res => {
            const safeText = text.replace(/(["$`\\])/g, '\\$1');
            chillProcess.exec(["bash", "-c", `echo "${safeText}" > "${path}"`], () => res(true));
        });
    }

    function exist(path) {
        return new Promise(res => {
            chillProcess.exec(["bash", "-c", `stat "${path}" >/dev/null 2>&1 && echo 1 || echo 0`], text => res(text.trim() === "1"));
        });
    }
}
