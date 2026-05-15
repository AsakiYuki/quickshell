import QtQuick
import Quickshell
import Quickshell.Wayland
import Qt5Compat.GraphicalEffects
import "../components"
import "../core"

Variants {
    id: root

    property color avgColor: "#FFFFFF"
    property bool isLightColor: false

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
                transitionAnimation.stop();
                shaderWallpaper.opacity = 1;
                shaderWallpaper.scheduleUpdate();
            }

            OpacityAnimator {
                id: transitionAnimation
                target: shaderWallpaper
                from: 1
                to: 0
                duration: 150
            }

            Image {
                id: sourceWallpaper
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                anchors.fill: parent
                onStatusChanged: if (status === Image.Ready) {
                    transitionAnimation.restart();
                }
            }

            ShaderEffectSource {
                live: false
                id: shaderWallpaper
                anchors.fill: parent
                sourceItem: sourceWallpaper
                onScheduledUpdateCompleted: {
                    sourceWallpaper.source = `${Paths.wallpapers}/${_root.wallpaper}`;
                }
            }
        }
    }
}