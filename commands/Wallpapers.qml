pragma ComponentBehavior: Bound

import QtQuick
import QtMultimedia
import Qt5Compat.GraphicalEffects

import "../components"
import "../core"

Item {
    id: _root

    readonly property int maxVisible: 5
    readonly property int visibleCount: Math.min(wallpapers.length, maxVisible)

    width: imageWidth * visibleCount + Math.max(0, visibleCount - 1) * 5 + 20
    height: imageHeight + 23

    property list<string> wallpapers: []
    property bool isLoaded: false

    readonly property int imageWidth: 300
    readonly property int imageHeight: imageWidth / 16 * 9

    readonly property var wallpapersMap: {
        const obj = {};
        wallpapers.forEach((v, k) => obj[v] = k);
        return obj;
    }

    property int currentWallpaperIndex: wallpapersMap[configuration.wallpaper] ?? 0

    onCurrentWallpaperIndexChanged: {
        if (currentWallpaperIndex > wallpapers.length - 1)
            currentWallpaperIndex = 0;
        else if (currentWallpaperIndex < 0)
            currentWallpaperIndex = wallpapers.length - 1;

        _changeWallpaperDelay.restart();
    }

    Timer {
        id: _changeWallpaperDelay
        interval: 250
        onTriggered: configuration.wallpaper = _root.wallpapers[_root.currentWallpaperIndex]
    }

    function onKeyPressed(ev) {
        if (ev.key === Qt.Key_Left)
            currentWallpaperIndex--;
        else if (ev.key === Qt.Key_Right)
            currentWallpaperIndex++;
    }

    Item {
        id: _sliderContainer
        width: _row.width
        height: _row.height

        readonly property int currentViewPos: Math.max(Math.min(_root.currentWallpaperIndex - 2, _root.wallpapers.length - _root.maxVisible), 0)
        readonly property int endViewPos: Math.min(currentViewPos + (_root.maxVisible - 1), _root.wallpapers.length - 1)

        x: 10 + currentViewPos * (-_root.imageWidth - 5)

        Behavior on x {
            NumberAnimation {
                duration: _root.isLoaded ? 350 : 0
                easing.type: Easing.OutQuint
            }
        }

        Row {
            id: _row
            spacing: 5

            Repeater {
                model: _root.wallpapers.length

                Item {
                    id: _thumbnail
                    required property int index

                    readonly property bool shouldLoad: index >= _sliderContainer.currentViewPos && index <= _sliderContainer.endViewPos
                    
                    readonly property string sourcePath: `${Paths.wallpapers}/${_root.wallpapers[index]}`
                    readonly property bool isVideo: _root.wallpapers[index].endsWith(".mp4")

                    width: _root.imageWidth
                    height: _root.imageHeight

                    scale: _root.isLoaded && _root.currentWallpaperIndex === index ? 1 : 0.8
                    opacity: shouldLoad ? 1 : 0

                    Behavior on scale {
                        NumberAnimation { duration: 350; easing.type: Easing.OutQuint }
                    }
                    Behavior on opacity {
                        NumberAnimation { duration: 250 }
                    }

                    Timer {
                        id: _unloadTimer
                        interval: 150
                        onTriggered: {
                            _imgLoader.active = false;
                            _videoLoader.active = false;
                        }
                    }

                    onShouldLoadChanged: {
                        if (shouldLoad) {
                            _unloadTimer.stop();
                            if (isVideo) {
                                _videoLoader.active = true;
                            } else {
                                _imgLoader.active = true;
                            }
                        } else {
                            _unloadTimer.restart();
                        }
                    }

                    Component.onCompleted: {
                        if (shouldLoad) {
                            if (isVideo) _videoLoader.active = true;
                            else _imgLoader.active = true;
                        }
                    }

                    Loader {
                        id: _imgLoader
                        active: false
                        anchors.fill: parent
                        sourceComponent: Image {
                            asynchronous: true
                            mipmap: true
                            cache: true
                            fillMode: Image.PreserveAspectCrop
                            sourceSize.width: _root.imageWidth
                            sourceSize.height: _root.imageHeight
                            source: _thumbnail.sourcePath

                            layer.enabled: true
                            layer.effect: OpacityMask {
                                maskSource: Rectangle {
                                    width: _root.imageWidth
                                    height: _root.imageHeight
                                    radius: 15
                                }
                            }
                        }
                    }

                    Loader {
                        id: _videoLoader
                        active: false
                        anchors.fill: parent
                        sourceComponent: Video {
                            fillMode: VideoOutput.PreserveAspectCrop
                            autoPlay: true
                            loops: MediaPlayer.Infinite
                            muted: true
                            source: `file://${_thumbnail.sourcePath}`

                            layer.enabled: true
                            layer.effect: OpacityMask {
                                maskSource: Rectangle {
                                    width: _root.imageWidth
                                    height: _root.imageHeight
                                    radius: 15
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    ScaleText {
        property string fileName: _root.wallpapers[_root.currentWallpaperIndex] || ""
        property string name: fileName.replace(/\.[^/.]+$/, "") 
        text: fileName.endsWith(".mp4") ? qsTr("Video: %1").arg(name) : qsTr("Image: %1").arg(name)
        
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        resizeSpeed: 0
        textAlign: "center"

        textComponent: StyledText {
            font.pixelSize: 13
        }
    }

    Component.onCompleted: {
        fs.readdir(Paths.wallpapers).then(v => {
            _root.wallpapers = v;
            _root.isLoaded = true;
        });
    }
}