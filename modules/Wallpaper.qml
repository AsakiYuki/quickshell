import QtQuick
import Quickshell
import Quickshell.Wayland

import Qt5Compat.GraphicalEffects

import "../components"
import "../core"

Variants {
    model: Quickshell.screens

    Scope {
        id: _scope
        required property ShellScreen modelData

        StyledWindow {
            id: _root
            name: "wallpaper"

            property int loadedState: -1

            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Bottom

            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true

            readonly property string wallpaper: configuration.wallpaper

            onWallpaperChanged: {
                anim.stop()
                first.source = second.source;
                if (loadedState === -1) second.source = `${Paths.wallpapers}/${_root.wallpaper}`
            }

            OpacityAnimator {
                id: anim
                duration: 150
                target: second
                from: 0
                to: 1
                onFinished: {
                    first.source = "";
                }
            }

            Image {
                id: first
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                source: ""
                onStatusChanged: {
                    if (status === Image.Ready) {
                        second.source = `${Paths.wallpapers}/${_root.wallpaper}`;
                        second.opacity = 0
                    }
                }
            }

            Image {
                id: second
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                source: ""
                onStatusChanged: {
                    if (status === Image.Ready) {
                        anim.restart()
                    }
                }
            }
        }
    }
}
