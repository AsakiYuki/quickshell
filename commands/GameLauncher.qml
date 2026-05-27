import QtQuick
import Quickshell.Io
import "../core"
import "../utils/VdfParser.js" as VdfParser
import "../utils/Unit.js" as Unit

SearchList {
    id: root

    readonly property var junkRe: /Proton|Runtime|SDK|Steamworks|Soundtrack/
    readonly property var iconRe: /^(\d+)\/([a-f0-9]+\.jpg)$/
    searchScoreName: "gamelauncher"

    FileView {
        id: libraryFile
        path: `${Paths.steam}/steamapps/libraryfolders.vdf`
        onLoaded: {
            const parsed = VdfParser.parse(text())
            const folders = Object.values(parsed.libraryfolders)
            const steamCache = `${Paths.steam}/appcache/librarycache`

            const manifestPaths = []
            for (const { apps, path } of folders) {
                for (const id in apps) {
                    manifestPaths.push(`${path}/steamapps/appmanifest_${id}.acf`)
                }
            }

            const iconsPromise = fs.readdirrec(steamCache).then(files => {
                const obj = Object.create(null)
                for (const file of files) {
                    const m = root.iconRe.exec(file)
                    if (m) obj[m[1]] = m[2]
                }
                return obj
            })

            Promise.all([iconsPromise, fs.readfiles(manifestPaths)])
                .then(([icons, contents]) => {
                    const entries = []
                    for (const c of contents.filter(v => v !== null)) {
                        const v = VdfParser.parse(c).AppState
                        if (!v?.name || root.junkRe.test(v.name)) continue
                        entries.push({
                            text: v.name,
                            subtext: `App ID: ${v.appid} | Build ID: ${v.buildid} | Size: ${Unit.diskSize(v.SizeOnDisk)}`,
                            icon: `${steamCache}/${v.appid}/${icons[v.appid]}`,
                            appid: v.appid,
                            execute: () => {
                                configuration.addSearchScore("gamelauncher", v.appid)
                                chillProcess.exec(["steam", `steam://rungameid/${v.appid}`])
                            }
                        })
                    }
                    root.listEntries = entries.sort((a, b) => a.text.localeCompare(b.text))
                })
                .catch(err => console.error("[SteamList]", err))
        }
    }
}