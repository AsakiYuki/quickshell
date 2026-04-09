import QtQuick
import Qt5Compat.GraphicalEffects

import "../../core"

Item {
    id: _root

    property bool enabled: false
    property list<string> wallpapers: []
    property int currentIndex: wallpapers.findIndex(wallpaper => wallpaper === configuration.wallpaper)

    width: enabled * (_list.width + 20)
    height: enabled * 260 / 16 * 9 + 20

    onEnabledChanged: {
        if (enabled) {
            fs.readdir("/home/asakiyuki/.config/quickshell/assets/wallpapers").then(files => wallpapers = files.filter(file => /.(png|jpg|jpeg)$/.test(file)));
        } else
            wallpapers = [];
    }

    focus: enabled

    Keys.onPressed: ev => {
        if (ev.key === Qt.Key_Escape)
            SharedState.isLauncherOpened = false;

        if (ev.key === Qt.Key_Left)
            configuration.wallpaper = _root.wallpapers[currentIndex = currentIndex ? currentIndex - 1 : wallpapers.length - 1];

        if (ev.key === Qt.Key_Right)
            configuration.wallpaper = _root.wallpapers[currentIndex = currentIndex == (wallpapers.length - 1) ? 0 : currentIndex + 1];
    }

    Row {
        id: _list

        spacing: 10
        anchors.centerIn: parent

        Repeater {
            model: _root.wallpapers.length

            Image {
                required property int index

                asynchronous: true
                cache: true
                fillMode: Image.PreserveAspectCrop
                smooth: true
                width: (_root.currentIndex === index) ? 260 : 240
                height: ((_root.currentIndex === index) ? 260 : 240) / 16 * 9
                retainWhileLoading: true

                Behavior on width {
                    NumberAnimation {
                        duration: 350
                        easing.type: Easing.OutExpo
                    }
                }

                Behavior on height {
                    NumberAnimation {
                        duration: 350
                        easing.type: Easing.OutExpo
                    }
                }

                source: `../../assets/wallpapers/${_root.wallpapers[index]}`
                anchors.verticalCenter: parent.verticalCenter

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        configuration.wallpaper = _root.wallpapers[index];
                    }
                }

                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: 240
                        height: 240 / 16 * 9
                        radius: 10
                    }
                }
            }
        }
    }
}
