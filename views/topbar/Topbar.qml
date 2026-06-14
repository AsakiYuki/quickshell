import Quickshell
import Quickshell.Wayland

PanelWindow {
    anchors.top: true
    anchors.left: true
    anchors.right: true

    implicitHeight: 40
    color: "transparent"

    WlrLayershell.namespace: "panel-topbar"
}