import QtQuick
import "../core"
import "../utils/VdfParser.js" as VdfParser
import "../utils/Unit.js" as Unit

SearchList {
    id: root

    readonly property var junkRe: /Proton|Runtime|SDK|Steamworks|Soundtrack/
    readonly property var iconRe: /^(\d+)\/([a-f0-9]+\.jpg)$/

    function scoreFn(r) {
        if (r[0].score > 0) {
            const clickCount = configuration.getSearchScore("gamelauncher", r.obj.entry.appid);
            return (r[0].score * 0.9 + r[1].score * 0.1) + (Math.log(1 + clickCount) * 0.1);
        } else return 0;
    }

    Component.onCompleted: {
        const steamCache = `${Paths.steam}/appcache/librarycache`

        const iconsPromise = fs.readdirrec(`${steamCache}/`, false, false).then(files => {
            const obj = Object.create(null)
            for (const file of files) {
                const m = root.iconRe.exec(file)
                if (m) obj[m[1]] = m[2]
            }
            return obj
        })

        const manifestsPromise = fs.readfile(`${Paths.steam}/steamapps/libraryfolders.vdf`).then(vdf => {
            const folders = Object.values(VdfParser.parse(vdf).libraryfolders)
            const reads = []
            for (const { apps, path } of folders) for (const id in apps) reads.push(fs.readfile(`${path}/steamapps/appmanifest_${id}.acf`))
            return Promise.all(reads).then(contents => contents.map(c => VdfParser.parse(c).AppState) )
        })

        Promise.all([iconsPromise, manifestsPromise]).then(([icons, apps]) => {
            const entries = []
            for (const v of apps) {
                if (!v?.name || root.junkRe.test(v.name)) continue
                entries.push({
                    text: v.name,
                    subtext: `App ID: ${v.appid} | Build ID: ${v.buildid} | Size: ${Unit.diskSize(v.SizeOnDisk)}`,
                    icon: `${steamCache}/${v.appid}/${icons[v.appid]}`,
                    appid: v.appid,
                    execute: () => {
                        configuration.addSearchScore("gamelauncher", v.appid);
                        chillProcess.exec(["steam", `steam://rungameid/${v.appid}`]);
                    }
                })
            }
            root.listEntries = entries.sort((a, b) => a.text.localeCompare(b.text))
        }).catch(err => console.error("[SteamList]", err))
    }
}