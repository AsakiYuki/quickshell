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
        const len = wallpapers.length;
        for (let i = 0; i < len; i++) {
            obj[wallpapers[i]] = i;
        }
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
                    
                    readonly property string fileName: _root.wallpapers[index] || ""
                    readonly property string sourcePath: fileName ? `${Paths.wallpapers}/${fileName}` : ""
                    readonly property bool isVideo: fileName.endsWith(".mp4")

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
                        onTriggered: _mediaLoader.active = false
                    }

                    onShouldLoadChanged: {
                        if (shouldLoad) {
                            _unloadTimer.stop();
                            _mediaLoader.active = true;
                        } else if (_mediaLoader.active) {
                            _unloadTimer.restart();
                        }
                    }

                    Component.onCompleted: {
                        if (shouldLoad) _mediaLoader.active = true;
                    }

                    Rectangle {
                        id: _maskRect
                        width: _root.imageWidth
                        height: _root.imageHeight
                        radius: 15
                        visible: false
                    }

                    Component {
                        id: _imgComp
                        Image {
                            asynchronous: true
                            cache: true
                            fillMode: Image.PreserveAspectCrop
                            sourceSize.width: _root.imageWidth
                            sourceSize.height: _root.imageHeight
                            source: _thumbnail.sourcePath
                        }
                    }

                    Component {
                        id: _vidComp
                        Video {
                            fillMode: VideoOutput.PreserveAspectCrop
                            autoPlay: true
                            loops: MediaPlayer.Infinite
                            muted: true
                            source: _thumbnail.sourcePath ? `file://${_thumbnail.sourcePath}` : ""
                        }
                    }

                    Loader {
                        id: _mediaLoader
                        active: false
                        anchors.fill: parent
                        sourceComponent: _thumbnail.isVideo ? _vidComp : _imgComp

                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: _maskRect
                        }
                    }
                }
            }
        }
    }

    ScaleText {
        property string fileName: _root.wallpapers[_root.currentWallpaperIndex] || ""
        property int dotPos: fileName.lastIndexOf(".")
        property string name: dotPos !== -1 ? fileName.substring(0, dotPos) : fileName
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