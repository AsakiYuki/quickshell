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

    delegate: Component {
        Scope {
            id: _scope
            required property ShellScreen modelData

            StyledWindow {
                screen: _scope.modelData

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
                property bool transitioning: false
                property bool pendingUpdate: false

                onWallpaperChanged: {
                    if (_root.transitioning) {
                        _root.pendingUpdate = true;
                        return;
                    }
                    _root.transitioning = true;
                    shaderWallpaper.opacity = 1;
                    shaderWallpaper.scheduleUpdate();
                }

                function finalizeTransition(targetItem) {
                    if (!_root.transitioning) return;
                    targetItem.grabToImage(function(result) {
                        canvas.imageData = result;
                        canvas.requestPaint();
                    }, Qt.size(1, 1));
                    transitionAnimation.restart();
                }

                OpacityAnimator {
                    id: transitionAnimation
                    target: shaderWallpaper
                    from: 1
                    to: 0
                    duration: 250
                    onStopped: {
                        _root.transitioning = false;
                        if (_root.pendingUpdate) {
                            _root.pendingUpdate = false;
                            _root.transitioning = true;
                            shaderWallpaper.opacity = 1;
                            shaderWallpaper.scheduleUpdate();
                        }
                    }
                }

                Timer {
                    id: transitionSafetyTimer
                    interval: 1000
                    running: _root.transitioning
                    onTriggered: transitionAnimation.restart()
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
                            if ((status === Image.Ready || status === Image.Error) && String(source) === String(_root.mediaSource)) {
                                if (status === Image.Ready) {
                                    grabToImage(function(result) {
                                        canvas.imageData = result;
                                        canvas.requestPaint();
                                    }, Qt.size(1, 1));
                                }
                                if (visible) _root.finalizeTransition(sourceWallpaper);
                            }
                        }
                    }

                    Video {
                        id: sourceVideoWallpaper
                        readonly property bool isHasFullscreen: Workspaces.current?.hasFullscreen

                        anchors.fill: parent
                        fillMode: VideoOutput.PreserveAspectCrop
                        autoPlay: !isHasFullscreen
                        loops: MediaPlayer.Infinite
                        visible: _root.currentShowVideo
                        muted: true

                        onSourceChanged: {
                            if (source) {
                                if (!isHasFullscreen) play();
                            } else {
                                stop();
                            }
                        }

                        onIsHasFullscreenChanged: {
                            if (isHasFullscreen) pause();
                            else play();
                        }

                        onPlaybackStateChanged: {
                            if ((playbackState === MediaPlayer.PlayingState || playbackState === MediaPlayer.PausedState) && String(source) === String(_root.mediaSource)) {
                                grabToImage(function(result) {
                                    canvas.imageData = result;
                                    canvas.requestPaint();
                                }, Qt.size(1, 1));
                                if (visible) _root.finalizeTransition(sourceVideoWallpaper);
                            }
                        }

                        onErrorChanged: {
                            if (error !== MediaPlayer.NoError && String(source) === String(_root.mediaSource)) {
                                if (visible) _root.finalizeTransition(sourceVideoWallpaper);
                            }
                        }

                        Timer {
                            running: _root.currentShowVideo && !parent.isHasFullscreen && parent.playbackState === MediaPlayer.PlayingState
                            interval: 500
                            repeat: true
                            onTriggered: {
                                if (String(parent.source) === String(_root.mediaSource)) {
                                    parent.grabToImage(function(result) {
                                        canvas.imageData = result;
                                        canvas.requestPaint();
                                    }, Qt.size(1, 1));
                                    if (_root.transitioning && parent.visible) {
                                        _root.finalizeTransition(parent);
                                    }
                                }
                            }
                        }
                    }
                }

                ShaderEffectSource {
                    id: shaderWallpaper
                    live: false
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
                    width: 1
                    height: 1
                    visible: false

                    property var imageData: null

                    onPaint: {
                        if (!imageData) return;
                        const ctx = getContext("2d");
                        ctx.drawImage(imageData.url, 0, 0, 1, 1);
                        const data = ctx.getImageData(0, 0, 1, 1).data;
                        const r = data[0];
                        const g = data[1];
                        const b = data[2];
                        root.avgColor = Qt.rgba(r / 255, g / 255, b / 255, 1);
                        root.isLightColor = Math.sqrt(0.299 * r * r + 0.587 * g * g + 0.114 * b * b) > 127.5;
                    }
                }
            }
        }
    }
}