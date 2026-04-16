pragma ComponentBehavior: Bound

import QtQuick
import Qt5Compat.GraphicalEffects

import "../components"
import "../core"

Item {
    id: _root

    width: imageWidth * Math.min(wallpapers.length, 5) + Math.min(wallpapers.length, 5) * 4 + 20
    height: imageHeight + 20

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
        interval: 250
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

        width: _row.widdth
        height: _row.height
        anchors.verticalCenter: _img.verticalCenter
        x: 10 + Math.max(Math.min(_root.currentWallpaperIndex - 2, _root.wallpapers.length - 5), 0) * (-_root.imageWidth - 5)

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

                    scale: _root.isLoaded && _root.currentWallpaperIndex === index ? 1 : 0.8
                    Behavior on scale {
                        NumberAnimation {
                            duration: 350
                            easing.type: Easing.OutBack
                        }
                    }

                    NumberAnimation on opacity {
                        running: _img.status === Image.Ready
                        duration: 250
                        from: 0
                        to: 1
                    }

                    asynchronous: true
                    mipmap: true
                    fillMode: Image.PreserveAspectCrop
                    source: `${Paths.wallpapers}/${_root.wallpapers[index]}`

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

    Component.onCompleted: {
        fs.readdir(Paths.wallpapers).then(v => {
            _root.wallpapers = v;
            _root.isLoaded = true;
            _xAnim.duration = 500;
        });
    }
}
