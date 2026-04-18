import QtQuick
import Quickshell

import "../../components"
import "../../core"
import "../../base"

import "../../commands" as Cmd

Loader {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    anchors.topMargin: 7

    id: launcher
    active: false

    Timer {
        running: !SharedState.isLauncherOpened
        interval: 150
        onTriggered: {
            launcher.active = false;
        }
    }

    Timer {
        running: SharedState.isLauncherOpened
        interval: 0
        onTriggered: {
            launcher.active = true;
        }
    }

    sourceComponent: RadiusRectangle {
        id: _root

        width: _list_container.width
        height: _list_container.height
        clip: true

        Behavior on height {
            NumberAnimation {
                duration: 350
                easing.type: Easing.OutExpo
            }
        }

        property int viewIndex: 0
        property int selectorIndex: 0

        readonly property var _e: _textField.commandMode ? _cmd_list : _list

        property int count: _e.model.length
        property int maxSelector: Math.min(_e.maxView, count)

        NumberAnimation {
            running: true
            target: _root
            properties: "y"
            from: -20 - _root.height
            to: 0
            easing.type: Easing.OutQuint
            duration: 350
        }

        NumberAnimation {
            running: !SharedState.isLauncherOpened
            target: _root
            properties: "y"
            from: _root.y
            to: -20 - _root.height
            easing.type: Easing.OutQuint
            duration: 350
        }

        onVisibleChanged: {
            if (SharedState.isLauncherOpened) {
                openAnim.start();
            } else {
                closeAnim.start();
            }
        }

        onSelectorIndexChanged: {
            selectorIndex = Math.max(0, Math.min(selectorIndex, maxSelector - 1));
        }

        onViewIndexChanged: {
            _e.viewIndex = viewIndex = Math.max(0, Math.min(count - maxSelector, viewIndex));
        }

        function goUp() {
            if (selectorIndex < 1) {
                if (viewIndex === 0) {
                    selectorIndex = maxSelector - 1;
                    viewIndex = count;
                } else
                    viewIndex--;
            } else
                selectorIndex--;
        }

        function goDown() {
            if (selectorIndex > maxSelector - 2) {
                if (viewIndex + maxSelector === count) {
                    selectorIndex = 0;
                    viewIndex = 0;
                } else
                    viewIndex++;
            } else
                selectorIndex++;
        }

        function mouseClick(index) {
            if (selectorIndex === index) {
                execute(viewIndex + selectorIndex);
            } else
                selectorIndex = index;
        }

        function execute(index) {
            if (!_textField.searchText.trim().startsWith("/")) {
                _e.model[index].entry.execute();
                SharedState.isLauncherOpened = false;
                return;
            }

            const entry = _e.model[index].entry;
            _textField.customPlaceHolder = entry.textfieldPlaceHolder;
            _textField.allowTyping = entry.allowTyping;
            _command_panel.command = entry.target;
            _command_panel.isActive = true;
        }

        function reset() {
            _root.viewIndex = 0;
            selectorIndex = 0;
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: _command_panel.isActive ? Qt.ArrowCursor : Qt.PointingHandCursor
            enabled: !_command_panel.isActive

            onClicked: ({
                    x,
                    y
                }) => {
                if (y <= 50)
                    return;
                _root.mouseClick((y / 55 >> 0) - 1);
            }

            onWheel: ({
                    angleDelta
                }) => {
                const isScrollUp = angleDelta.y > 0;
                if (isScrollUp)
                    _root.goUp();
                else
                    _root.goDown();
            }
        }

        Keys.onPressed: ev => {
            if (ev.modifiers === Qt.AltModifier && ev.key === Qt.Key_Left) {
                if (_command_panel.isActive) {
                    _command_panel.isActive = false;
                    _textField.customPlaceHolder = "";
                    _textField.allowTyping = true;
                    _textField.text = _textField.searchText;
                } else if (_textField.text === "")
                    SharedState.isLauncherOpened = false;
                else
                    _textField.text = "";
            } else if (ev.key === Qt.Key_Escape)
                SharedState.isLauncherOpened = false;

            if (_command_panel.isActive) {
                _command_panel.onKeyPressed(ev);
                return;
            }

            if (ev.modifiers > Qt.NoModifier)
                return;

            if (ev.key === Qt.Key_Down) 
                _root.goDown();
            else if (ev.key === Qt.Key_Up)
                _root.goUp();
            else if (ev.key === Qt.Key_Enter || ev.key === Qt.Key_Return) {
                _root.execute(viewIndex + selectorIndex);
            }
        }

        RadiusRectangle {
            id: selector_panel
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 20
            height: 55
            color: Catppuccin.surface0
            y: 45 + _root.selectorIndex * 55
            border.width: 0

            opacity: _command_panel.isActive ? 0 : 1
            Behavior on opacity {
                NumberAnimation {
                    duration: 120
                }
            }

            Behavior on y {
                NumberAnimation {
                    duration: 350
                    easing.type: Easing.OutExpo
                }
            }
        }

        Column {
            id: _list_container

            spacing: 10
            topPadding: 10
            bottomPadding: 10
            width: _command_panel.isActive ? (_command_panel.width + 20) : 650
            Behavior on width {
                NumberAnimation {
                    duration: 350
                    easing.type: Easing.OutExpo
                }
            }

            StyledTextField {
                id: _textField

                width: parent.width - 20

                property string searchText: ""
                onTextChanged: {
                    if (!_command_panel.isActive) {
                        searchText = text.trim();
                    }
                }

                anchors.horizontalCenter: parent.horizontalCenter
                readonly property bool commandMode: searchText[0] === "/"

                property string customPlaceHolder: ""
                placeholderText: qsTr(customPlaceHolder === "" ? "Type '/' to enter a command..." : customPlaceHolder)
                Component.onCompleted: _textField.forceActiveFocus()


            }

            Item {
                width: parent.width
                height: _command_panel.isActive ? _command_panel.height : (_textField.commandMode ? _cmd_list.height : _list.height) - 5

                Cmd.CommandPanel {
                    id: _command_panel
                    anchors.horizontalCenter: parent.horizontalCenter
                    opacity: Number(isActive)
                    visible: opacity > 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 120
                        }
                    }
                    onIsActiveChanged: {
                        if (isActive)
                            _textField.text = "";
                    }
                }

                Commands {
                    id: _cmd_list
                    y: -5
                    opacity: (_textField.commandMode && !_command_panel.isActive) ? 1 : 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 120
                        }
                    }
                }

                Applications {
                    id: _list
                    y: -5
                    opacity: (!_textField.commandMode && !_command_panel.isActive) ? 1 : 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 120
                        }
                    }
                }
            }
        }
    }
}
