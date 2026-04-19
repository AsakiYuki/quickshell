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
            WlrLayershell.keyboardFocus: SharedState.isOverlay ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true

            Component.onCompleted: {
                _root.width = modelData.width;
                _root.height = modelData.height;
            }

            MouseArea {
                anchors.fill: parent
                onPressed: SharedState.onOverlayClicked()
            }

            mask: Region {
                item: null
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

                Launcher.Launcher {}
                Elements.SystemTray {}
                Elements.SystemPopup {}
            }

            Image {
                width: 20
                height: 20
                x: _root.trayDragPosX
                y: _root.trayDragPosY
                source: _root.trayIcon
            }
        }
    }
}
