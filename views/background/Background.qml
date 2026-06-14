import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    anchors.left: true
    anchors.right: true
    anchors.top: true
    anchors.bottom: true

    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "panel-background"

    color: "transparent"

    Wallpaper {}

    Component.onCompleted: {
    }
}