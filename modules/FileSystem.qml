import Quickshell

Scope {
    id: _root

    function readdir(path, hidden) {
        return new Promise(res => {
            chillProcess.exec(hidden ? ["ls", "-a", path] : ["ls", path], out => res(out.trim().split("\n")));
        });
    }

    function readdirrec(dir, hidden) {
        return new Promise((res, rej) => {
            chillProcess.exec(
                hidden ? ["ls", "-aR", dir] : ["ls", "-R", dir],
                (out, err) => {
                    if (err) return rej(err);

                    const lines = out.split("\n");
                    const result = [];

                    let current = "";

                    for (let line of lines) {
                        line = line.trim();
                        if (!line) continue;

                        // ví dụ: dir/sub:
                        if (line.endsWith(":")) {
                            current = line.slice(0, -1);

                            // convert thành relative
                            if (current.startsWith(dir)) {
                                current = current.slice(dir.length);
                            }

                            current = current.replace(/^\/+/, ""); // bỏ /
                            continue;
                        }

                        if (!hidden && line.startsWith(".")) continue;
                        if (line === "." || line === "..") continue;

                        const path = current
                            ? current + "/" + line
                            : line;

                        result.push(path);
                    }

                    res(result);
                }
            );
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
