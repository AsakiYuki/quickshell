pragma Singleton

import Quickshell
import Quickshell.Hyprland

Singleton {
    property var workspaces: Hyprland.workspaces
    property bool hasFullscreen: current?.hasFullscreen || false
    onCurrentChanged: { SharedState.overlayDropPanelType = 0; }
    
    property var current: {
        for (const workspace of workspaces.values) if (workspace.active) return workspace;
        return null;
    }

    function getById(id) {
        for (const workspace of workspaces.values) if (workspace.id === id) return workspace;
        return null;
    }

    function next() { return Hyprland.dispatch(`hl.dsp.focus({ workspace = "e+1" })`); }
    function prev() { return Hyprland.dispatch(`hl.dsp.focus({ workspace = "e-1" })`); }
    function set(id) { return Hyprland.dispatch(`hl.dsp.focus({ workspace = "${id}" })`); }
}
