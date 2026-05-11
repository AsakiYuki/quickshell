import QtQuick

import Quickshell.Io
import "../core"

SearchList {
    id: root

    searchScoreName: "codelauncher"

    FileView {
        path: `${Paths.config}/Code/User/globalStorage/storage.json`

        onLoaded: {
            const { profileAssociations: { workspaces } } = JSON.parse(text());

            root.listEntries = Object.keys(workspaces).map(path => ({
                text: path.split('/').filter(Boolean).pop(),
                subtext: path.slice(7),
                icon: "../../assets/icons/folder_code.png",
                path,
                execute: () => {
                    configuration.addSearchScore("codelauncher", path);
                    chillProcess.exec(["code", path.slice(7)]);
                }
            }))
        }
    }
}