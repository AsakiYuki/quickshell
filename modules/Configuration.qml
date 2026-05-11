import Quickshell
import Quickshell.Io

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

    function save() {
        if (configuration.loaded) _save.restart()
    }
    
    FileView {
        id: configuration
        path: Paths.settings
        onLoaded: {
            let data = {};
            try { data = JSON.parse(text()); } catch(err) {}

            _configuration.wallpaper = data.wallpaper ?? "wallpaper-0.jpg";
            _configuration.touchpad = data.touchpad ?? true;
            _configuration.hdr = data.hdr || false;
            _configuration.trayIndex = data.trayIndex  || {};
            _configuration.hideTrayID = data.hideTrayID || [];
            _configuration.searchScores = data.searchScores || {};

            chillProcess.exec(["sh", "-c", `hyprctl devices | grep -B 6 "main: yes" | grep capsLock | head -1 | awk '{print $2}'`], v => _configuration.capsLock = v.trim() === "yes");
        }
    }

    Timer {
        id: _save
        running: false
        interval: 200
        onTriggered: if (configuration.loaded) configuration.setText(JSON.stringify(_configuration))
    }
}
