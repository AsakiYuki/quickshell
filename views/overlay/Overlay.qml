import Quickshell
import Quickshell.Wayland

import QtQuick

PanelWindow {
    color: "transparent"

    anchors.bottom: true
    anchors.top: true
    anchors.left: true
    anchors.right: true

    mask: Region { item: null }

    WlrLayershell.namespace: "panel-overlay"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
}