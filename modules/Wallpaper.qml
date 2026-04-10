import QtQuick
import Quickshell
import Quickshell.Wayland

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

            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Bottom

            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true

            readonly property string wallpaper: configuration.wallpaper

            onWallpaperChanged: {
                first.source = second.source;

                second.opacity = 0;
                second.source = `${Paths.wallpapers}/${wallpaper}`;

                anim.running = true;
            }

            OpacityAnimator {
                id: anim
                target: second
                from: 0
                to: 1
                duration: 100
                onFinished: {
                    first.source = "";
                }
            }

            Image {
                id: first
                width: parent.width
                height: parent.height
                fillMode: Image.PreserveAspectCrop
                source: ""
            }

            Image {
                id: second
                width: parent.width
                height: parent.height
                fillMode: Image.PreserveAspectCrop
                source: ""
            }
        }
    }
}
