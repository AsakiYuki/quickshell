import Quickshell
import QtQuick

import "../core"

Scope {
    id: _configuration

    property string wallpaper: ""
    property bool touchpad: false
    property bool capsLock: false
    property bool hdr: false
    property var trayIndex: ({})
    property var searchScores: ({})
    property list<string> hideTrayID: []

    function getSearchScore(searchType, id) {
        const data = searchScores[searchType]?.[id];
        if (!data) return 0;
        const now = Date.now();
        const timePassed = now - data.lastUpdate;
        const decayScore = data.score * Math.pow(0.5, timePassed / 604800000);
        return decayScore;
    }

    function addSearchScore(searchType, id, score = 1) {
        if (!searchScores[searchType]) searchScores[searchType] = {};
        const prev = searchScores[searchType][id] || { score: 0 };

        const currentDecayScore = getSearchScore(searchType, id);
        
        searchScores[searchType][id] = {
            score: Math.min(currentDecayScore + score, 500),
            lastUpdate: Date.now()
        };

        save();
    }

    function save() { _save.restart() }
    onTrayIndexChanged: save()
    onWallpaperChanged: save()
    onHideTrayIDChanged: { save(); if (SystemTray.hideTrayID !== hideTrayID) SystemTray.hideTrayID = hideTrayID; }
    onTouchpadChanged: { save(); chillProcess.exec(["hyprctl", "keyword", "$LAPTOP_TOUCHPAD_ENABLE", touchpad, "-r"]);}
    onHdrChanged: {
        save();
        chillProcess.exec([ "hyprctl", "keyword", "$CURRENT_STATE_SCREEN",
            hdr
                ? "eDP-1, 1920x1200@60, 0x0, 1, sdrbrightness, 1.1, sdrsaturation, 1.25, bitdepth, 10, cm, hdr"
                : "eDP-1, 1920x1200@60, 0x0, 1",
            "-r"
        ]);
    }

    Timer {
        id: _save
        running: false
        interval: 1000
        onTriggered: { fs.writefile(Paths.settings, JSON.stringify(_configuration)); }
    }

    Component.onCompleted: {
        fs.readfile(Paths.settings).then(v => {
            const data = JSON.parse(v);
            wallpaper = data.wallpaper ?? "wallpaper-0.jpg";
            touchpad = data.touchpad ?? true;
            hdr = data.hdr || false;
            trayIndex = data.trayIndex ?? {};
            hideTrayID = data.hideTrayID ?? [];
            searchScores = data.searchScores ?? {};
        }).catch(err => {
            wallpaper = "wallpaper-0.jpg";
            touchpad = true;
            hdr = false;
            trayIndex = {};
            hideTrayID = [];
            searchScores = {};
        });

        chillProcess.exec(["sh", "-c", `hyprctl devices | grep -B 6 "main: yes" | grep capsLock | head -1 | awk '{print $2}'`], v => capsLock = v.trim() === "yes");
    }
}
