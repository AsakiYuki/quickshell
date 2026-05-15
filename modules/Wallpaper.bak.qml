import QtQuick
import Quickshell
import Quickshell.Wayland
import Qt5Compat.GraphicalEffects
import "../components"
import "../core"

Variants {
    id: root

    property color avgColor: "black"
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
                anim.stop()
                first.source = second.source
                second.source = `${Paths.wallpapers}/${_root.wallpaper}`
            }

            OpacityAnimator {
                id: anim
                duration: 150
                target: second
                from: 0
                to: 1
                onFinished: first.source = ""
            }

            Image {
                id: first
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                source: ""
                onStatusChanged: if (status === Image.Ready) {
                    second.opacity = 0
                }
            }

            Image {
                id: second
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                source: `${Paths.wallpapers}/${_root.wallpaper}`
                onStatusChanged: if (status === Image.Ready) {
                    anim.restart()
                    grabToImage(function(result) {
                        canvas.imageData = result
                        canvas.requestPaint()
                    }, Qt.size(16, 16))
                }
            }

            Canvas {
                id: canvas
                width: 16
                height: 16
                visible: false

                property var imageData: null

                onPaint: {
                    if (!imageData) return
                    const ctx = getContext("2d")
                    ctx.drawImage(imageData.url, 0, 0, 16, 16)
                    const data = ctx.getImageData(0, 0, 16, 16).data
                    const count = data.length / 4
                    let r = 0, g = 0, b = 0
                    for (let i = 0; i < data.length; i += 4) {
                        r += data[i]
                        g += data[i + 1]
                        b += data[i + 2]
                    }
                    const ar = r / count
                    const ag = g / count
                    const ab = b / count
                    root.avgColor = Qt.rgba(ar / 255, ag / 255, ab / 255, 1)
                    root.isLightColor = Math.sqrt(0.299 * ar * ar + 0.587 * ag * ag + 0.114 * ab * ab) > 127.5
                }
            }
        }
    }
}