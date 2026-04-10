pragma ComponentBehavior: Bound

import QtQuick

import Quickshell
import Quickshell.Wayland

import "../components"
import "../modules"
import "../core"
import "../elements/Launcher"

Variants {
    id: _root

    model: Quickshell.screens

    Scope {
        id: _scope
        required property ShellScreen modelData

        StyledWindow {
            id: _overlay
            name: "overlay"

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.keyboardFocus: SharedState.isOverlay ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true

            MouseArea {
                anchors.fill: parent
                onPressed: SharedState.onOverlayClicked()
            }

            mask: Region {
                item: null
            }

            Launcher {
                id: launcher

                Timer {
                    running: !SharedState.isLauncherOpened
                    interval: 150
                    onTriggered: {
                        launcher.active = false;
                    }
                }

                Timer {
                    running: SharedState.isLauncherOpened
                    interval: 0
                    onTriggered: {
                        launcher.active = true;
                    }
                }

                active: false
            }
        }
    }
}
