import QtQuick

import Quickshell.Hyprland

import "../../components"

Item {
    anchors.fill: parent

    Connections {
        target: Hyprland

        function onRawEvent(event) {
        }
    }

    Left {}
    Center {}
    Right {}
}
