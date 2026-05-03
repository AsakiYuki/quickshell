import QtQuick
import Quickshell
import Quickshell.Wayland

import Qt5Compat.GraphicalEffects

import "../components"
import "../core"

Variants {
    id: root
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
                onFinished: first.source = "";
            }

            Image {
                id: first
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                source: ""
                onStatusChanged: if (status === Image.Ready) {
                    second.source = `${Paths.wallpapers}/${_root.wallpaper}`;
                    second.opacity = 0
                }
            }

            Image {
                id: second
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                source: ""
                onStatusChanged: if (status === Image.Ready) {
                    anim.restart();
                    grabToImage(function(result) {
                        canvas.imageData = result
                        canvas.requestPaint()
                    }, Qt.size(1, 1)) 
                }
            }

            Canvas {
                id: canvas
                width: 16; height: 16
                visible: false

                property var imageData: null
                property color averageColor: "black"

                onPaint: {
                    if (!imageData) return
                    const ctx = getContext("2d")
                    ctx.drawImage(imageData.url, 0, 0, 1, 1)

                    const data = ctx.getImageData(0, 0, 1, 1).data
                    const count = data.length / 4
                    let r = 0, g = 0, b = 0

                    for (let i = 0; i < data.length; i += 4) {
                        r += data[i]
                        g += data[i + 1]
                        b += data[i + 2]
                    }

                    root.avgColor = Qt.rgba(r/count/255, g/count/255, b/count/255, 1);
                    root.isLightColor = Math.sqrt(0.299*r*r + 0.587*g*g + 0.114*b*b) > 127.5
                }
            }
        }
    }
}
