import QtQuick
import Quickshell

import "../components"
import "../core"

import "../utils/FuzzySort.js" as FuzzySort

Item {
    id: _root

    width: _container.width
    height: _container.height

    anchors.horizontalCenter: parent.horizontalCenter
    readonly property bool opened: SharedState.isLauncherOpened

    y: opened ? 5 : -_container.height - 5

    onOpenedChanged: {
        anim.duration = 350;
        timeout.running = false;
        if (!opened) {
            timeout.running = true;
            _app_list.currentIndex = 0;
        }
    }

    Behavior on y {
        NumberAnimation {
            id: anim
            duration: 350
            easing.type: Easing.OutQuart
        }
    }

    Timer {
        id: timeout
        running: false
        interval: 150
        onTriggered: {
            anim.duration = 0;
            _textField.text = "";
            _command_panel.isShow = false;
            _command_panel.commandId = -1;
            _textField.focus = true;
        }
    }

    function exit() {
        SharedState.isLauncherOpened = false;
    }

    RadiusRectangle {
        id: _container

        width: _command_panel.isShow ? _command_panel.width : 650
        height: _command_panel.isShow ? _command_panel.height : _textField.height + 30 + (_textField.text[0] === "/" ? _command_list.height : _app_list.height)

        clip: true

        Behavior on height {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutQuart
            }
        }

        Behavior on width {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutQuart
            }
        }

        StyledTextField {
            id: _textField
            y: 10
            width: parent.width - 20
            anchors.horizontalCenter: parent.horizontalCenter
            placeholderText: "Type '/' to enter a command..."
            Component.onCompleted: _textField.forceActiveFocus()

            opacity: Number(!_command_panel.isShow)
            scale: !_command_panel.isShow ? 1 : 0.9
            visible: opacity > 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.OutQuart
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.OutQuart
                }
            }
        }

        LauncherList {
            id: _command_list

            opacity: (!_command_panel.isShow) * Number(_textField.text[0] === "/")
            scale: (!_command_panel.isShow && _textField.text[0] === "/") ? 1 : 0.9
            visible: opacity > 0

            width: parent.width - 20
            anchors.horizontalCenter: parent.horizontalCenter
            y: _textField.height + 15

            model: [
                {
                    name: "Wallpaper",
                    description: "Change your wallpaper",
                    icon: "/home/asakiyuki/.config/quickshell/assets/icons/images.png"
                }
            ]

            execute: index => {
                _command_panel.isShow = true;
                _textField.focus = false;
                _command_panel.commandId = _command_list.index;
            }
        }

        LauncherList {
            id: _app_list

            opacity: Number(_textField.text[0] !== "/")
            scale: _textField.text[0] === "/" ? 0.9 : 1
            visible: opacity > 0

            width: parent.width - 20
            anchors.horizontalCenter: parent.horizontalCenter
            y: _textField.height + 15

            readonly property list<var> desktopEntries: DesktopEntries.applications.values.filter(a => !a.noDisplay).sort((a, b) => a.name.localeCompare(b.name)).map(a => ({
                        name: FuzzySort.prepare(a.name),
                        comment: FuzzySort.prepare(a.comment),
                        entry: a
                    }))

            function query(search) {
                if (search[0] === "/")
                    return queryList;

                return FuzzySort.go(search, desktopEntries, {
                    all: true,
                    keys: ["name", "comment"],
                    scoreFn: r => (r[0].score > 0) ? r[0].score * 0.9 + r[1].score * 0.1 : 0
                }).map(r => r.obj);
            }

            execute: index => {
                _app_list.queryList[index].entry.execute();
                _root.exit();
            }

            readonly property list<var> queryList: query(_textField.text)

            model: queryList.length ? queryList.map(v => ({
                        name: v.entry.name,
                        description: v.entry.comment,
                        icon: v.entry.icon[0] == "/" ? v.entry.icon : "image://icon/" + v.entry.icon
                    })) : [
                {
                    icon: "",
                    name: "No results",
                    description: "Try again"
                }
            ]
        }

        CommandPanel {
            id: _command_panel
        }
    }

    Keys.onPressed: ev => {
        if (!_command_panel.isShow) {
            if (ev.key === Qt.Key_Escape)
                _root.exit();

            if (ev.key == Qt.Key_Down)
                _app_list.incrementCurrentIndex();

            if (ev.key == Qt.Key_Up)
                _app_list.decrementCurrentIndex();

            if (ev.key === Qt.Key_Enter || ev.key == Qt.Key_Return) {
                if (_textField.text[0] === "/") {
                    _command_panel.isShow = true;
                    _textField.focus = false;
                    _command_panel.commandId = _command_list.currentIndex;
                } else {
                    _app_list.queryList[_app_list.currentIndex].entry.execute();
                    _root.exit();
                }
            }
        }
    }
}
