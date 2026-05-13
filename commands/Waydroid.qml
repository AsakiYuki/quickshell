import QtQuick

import Quickshell

SearchList {
    searchScoreName: "waydroid"

    listEntries: [
        {
            icon: "../../assets/icons/android.png",
            text: "Start",
            subtext: "Launch waydroid session",
            execute: () => chillProcess.exec(["waydroid", "show-full-ui"])
        },
        {
            icon: "../../assets/icons/shutdown.png",
            text: "Stop",
            subtext: "Stop current waydroid session",
            execute: () => chillProcess.exec(["waydroid", "session", "stop"])
        },
        ...DesktopEntries.applications.values
            .filter(v => !v.noDisplay && (v.name !== "Waydroid") && (v.categories[0] === "X-WayDroid-App"))
            .sort((a, b) => a.name.localeCompare(b.name))
            .map(a => ({
                icon: a.icon,
                text: a.name,
                subtext: a.id,
                execute: a.execute
            }))
    ]
}