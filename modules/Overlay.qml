pragma ComponentBehavior: Bound

import QtQuick

import Quickshell
import Quickshell.Wayland

import "../components"
import "../modules"
import "../core"
import "../elements" as Elements
import "../elements/launcher" as Launcher

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

            Launcher.Launcher {
                id: launcher
                active: false

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
            }

            Elements.SystemPopup {
                id: _system_popup

                property bool isFirstLoad: true

                readonly property bool touchpad: configuration.touchpad
                onTouchpadChanged: {
                    if (touchpad)
                        setPopup("touchpad_mouse_on.png", "Touchpad enabled");
                    else
                        setPopup("touchpad_mouse_off.png", "Touchpad disabled");
                }

                readonly property bool capslock: configuration.capsLock
                onCapslockChanged: {
                    if (capslock)
                        setPopup("shift_lock.png", "Caps Lock is on");
                    else
                        setPopup("shift_lock_off.png", "Caps Lock is off");
                }

                function setPopup(_icon, _message) {
                    if (isFirstLoad) {
                        isFirstLoad = false;
                        return;
                    }

                    icon = _icon;
                    notifyText = _message;
                    active = true;
                }

                Timer {
                    running: true
                    interval: 50
                    onTriggered: {
                        _system_popup.isFirstLoad = false;
                    }
                }
            }
        }
    }
}
