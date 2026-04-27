pragma ComponentBehavior: Bound

import QtQuick

import Quickshell
import Quickshell.Wayland

import "../components"
import "../core"
import "../elements" as Elements
import "../elements/launcher" as Launcher

Variants {
    id: _root

    model: Quickshell.screens

    property int width: 0
    property int height: 0

    property int trayDragPosX: 0
    property int trayDragPosY: 0
    property string trayIcon: ""

    function setDragIcon(icon) {
        trayIcon = icon;
    }

    function setOverlayPosition(x, y) {
        trayDragPosX = x;
        trayDragPosY = y;
    }

    Scope {
        id: _scope
        required property ShellScreen modelData

        StyledWindow {
            id: _overlay
            name: "overlay"

            function setDragIcon(icon) {
                _root.trayIcon = icon;
            }

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.keyboardFocus: SharedState.isLauncherOpened ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true

            focusable: true

            Component.onCompleted: {
                _root.width = modelData.width;
                _root.height = modelData.height;
            }

            mask: Region {
                item: SharedState.isOverlay ? mouseArea : null
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                focus: SharedState.isOverlay
                onPressed: SharedState.onOverlayClicked()
                anchors.topMargin: (Workspaces.hasFullscreen || SharedState.isLauncherOpened || (`${_root.trayIcon}`[0]) === "0") ? 0 : 45

                Keys.onPressed: ev => {
                    if (ev.key === Qt.Key_Escape)
                        SharedState.onOverlayClicked();
                }
            }

            Item {
                anchors.fill: parent
                anchors.topMargin: Workspaces.hasFullscreen ? 0 : 45
                clip: true

                Behavior on anchors.topMargin {
                    NumberAnimation {
                        duration: 350
                        easing.type: Easing.OutQuint
                    }
                }

                Elements.SystemTray {}
                Elements.MusicPlayer {}
                Elements.PowerProfile {}
                Elements.Calendar {}

                MouseArea {
                    anchors.fill: parent
                    visible: SharedState.isLauncherOpened
                    hoverEnabled: true
                    onPressed: SharedState.onOverlayClicked()
                    z: 10
                }

                Launcher.Launcher {}

                Elements.SystemPopup {
                    z: 100
                }
                // Elements.ActivateNixOS { z: 2 }
            }

            Image {
                id: dragIcon
                width: 20
                height: 20
                x: _root.trayDragPosX
                y: _root.trayDragPosY
                source: _root.trayIcon.slice(1)
                mipmap: true
            }
        }
    }
}
