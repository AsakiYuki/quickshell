pragma ComponentBehavior: Bound

import QtQuick
import Qt5Compat.GraphicalEffects

import "../components"
import "../core"

Item {
    id: _root

    width: imageWidth * Math.min(wallpapers.length, 5) + Math.min(wallpapers.length, 5) * 4 + 20
    height: imageHeight + 28

    property list<string> wallpapers: []

    property bool isLoaded: false
    property int currentWallpaperIndex: wallpapersMap[configuration.wallpaper] ?? 0
    onCurrentWallpaperIndexChanged: {
        if (currentWallpaperIndex > wallpapers.length - 1)
            currentWallpaperIndex = 0;
        else if (currentWallpaperIndex < 0)
            currentWallpaperIndex = wallpapers.length - 1;

        _changeWallpaperDelay.running = false;
        _changeWallpaperDelay.running = true;
    }

    Timer {
        id: _changeWallpaperDelay
        running: false
        interval: 300
        onTriggered: {
            configuration.wallpaper = _root.wallpapers[_root.currentWallpaperIndex];
        }
    }

    readonly property var wallpapersMap: {
        const obj = {};
        wallpapers.forEach((v, k) => obj[v] = k);
        return obj;
    }

    readonly property int imageWidth: 300
    readonly property int imageHeight: imageWidth / 16 * 9

    function onKeyPressed(ev) {
        if (ev.key === Qt.Key_Left)
            currentWallpaperIndex--;
        else if (ev.key === Qt.Key_Right)
            currentWallpaperIndex++;
    }

    Loader {
        id: _loader
        active: _root.wallpapers.length > 0

        width: _row.width
        height: _row.height

        readonly property int currentViewPos: Math.max(Math.min(_root.currentWallpaperIndex - 2, _root.wallpapers.length - 5), 0)
        readonly property int endViewPos: Math.min(currentViewPos + 4, _root.wallpapers.length - 1)

        x: 10 + currentViewPos * (-_root.imageWidth - 5)

        Behavior on x {
            NumberAnimation {
                id: _xAnim
                duration: 0
                easing.type: Easing.OutQuint
            }
        }

        Row {
            id: _row
            spacing: 5
            Repeater {
                model: _root.wallpapers.length

                Image {
                    id: _img
                    required property int index
                    readonly property int shouldLoad: _loader.currentViewPos <= index && index <= _loader.endViewPos

                    scale: _root.isLoaded && _root.currentWallpaperIndex === index ? 1 : 0.8

                    Behavior on scale {
                        NumberAnimation {
                            duration: 350
                            easing.type: Easing.OutQuint
                        }
                    }

                    NumberAnimation on scale {
                        running: _img.status === Image.Ready
                        from: 0
                        to: _root.isLoaded && _root.currentWallpaperIndex === _img.index ? 1 : 0.8
                        duration: 350
                        easing.type: Easing.OutQuint
                    }

                    NumberAnimation on opacity {
                        running: _img.status === Image.Ready
                        duration: 250
                        from: 0
                        to: 1
                    }

                    asynchronous: true
                    mipmap: true
                    cache: true
                    fillMode: Image.PreserveAspectCrop
                    source: ""

                    Timer {
                        running: _img.shouldLoad
                        interval: 0
                        onTriggered: {
                            _img.source = `${Paths.wallpapers}/${_root.wallpapers[index]}`;
                        }
                    }

                    Timer {
                        running: !_img.shouldLoad
                        interval: 150
                        onTriggered: {
                            _img.source = "";
                        }
                    }

                    sourceSize.width: _root.imageWidth
                    sourceSize.height: _root.imageHeight

                    width: _root.imageWidth
                    height: _root.imageHeight

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

    ScaleText {
        text: _root.wallpapers[_root.currentWallpaperIndex].replace(/\.\w*/, "")
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        resizeSpeed: 0
        textAlign: "center"

        textComponent: StyledText {
            font.pixelSize: 15
        }
    }

    Component.onCompleted: {
        fs.readdir(Paths.wallpapers).then(v => {
            _root.wallpapers = v;
            _root.isLoaded = true;
            _xAnim.duration = 350;
        });
    }
}
