pragma ComponentBehavior: Bound

import QtQuick
import QtMultimedia
import Qt5Compat.GraphicalEffects

import Quickshell
import Quickshell.Wayland

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
            readonly property bool isVideo: wallpaper.endsWith(".mp4")
            readonly property string mediaSource: wallpaper ? `file://${Paths.wallpapers}/${wallpaper}` : ""

            property bool currentShowVideo: isVideo

            onWallpaperChanged: {
                transitionAnimation.stop();
                shaderWallpaper.opacity = 1;
                shaderWallpaper.scheduleUpdate();
            }

            function finalizeTransition(targetItem) {
                transitionAnimation.restart();
                targetItem.grabToImage(function(result) {
                    canvas.imageData = result
                    canvas.requestPaint()
                }, Qt.size(16, 16))
            }

            OpacityAnimator {
                id: transitionAnimation
                target: shaderWallpaper
                from: 1
                to: 0
                duration: 250 
            }

            Item {
                id: mediaContainer
                anchors.fill: parent

                Image {
                    id: sourceWallpaper
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    visible: !_root.currentShowVideo

                    onStatusChanged: {
                        if (visible && status === Image.Ready && String(source) === String(_root.mediaSource)) {
                            _root.finalizeTransition(sourceWallpaper)
                        }
                    }
                }

                Video {
                    readonly property bool isHasFullscreen: Workspaces.current?.hasFullscreen
                    
                    onSourceChanged: {
                        if (source) {
                            if (!isHasFullscreen) play();
                        } else stop();
                    }

                    onIsHasFullscreenChanged: {
                        if (isHasFullscreen) pause();
                        else play();
                    }

                    muted: true
                    id: sourceVideoWallpaper
                    anchors.fill: parent
                    fillMode: VideoOutput.PreserveAspectCrop
                    autoPlay: true
                    loops: MediaPlayer.Infinite
                    visible: _root.currentShowVideo

                    onPlaying: {
                        if (visible && String(source) === String(_root.mediaSource)) {
                            _root.finalizeTransition(sourceVideoWallpaper)
                        }
                    }
                }
            }

            ShaderEffectSource {
                live: false
                id: shaderWallpaper
                anchors.fill: parent
                sourceItem: mediaContainer

                onScheduledUpdateCompleted: {
                    _root.currentShowVideo = _root.isVideo;

                    if (_root.isVideo) {
                        sourceVideoWallpaper.source = _root.mediaSource;
                        sourceWallpaper.source = ""; 
                    } else {
                        sourceWallpaper.source = _root.mediaSource;
                        sourceVideoWallpaper.source = ""; 
                    }
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