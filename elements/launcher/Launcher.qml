import QtQuick

import "../../components"
import "../../core"
import "../../base"

import "../../commands" as Cmd

DropPanel {
    id: root
    active: SharedState.isLauncherOpened
    direction: 1

    anchors.horizontalCenter: parent.horizontalCenter
    viewY: 7

    content: Item {
        id: _root

        width: _list_container.width
        height: _list_container.height
        clip: true

        readonly property int rowHeight: 55
        readonly property int topOffset: 10
        readonly property int listHeaderArea: 40

        property int viewIndex: 0
        property int selectorIndex: 0

        readonly property var _e: _textField.commandMode ? _cmd_list : _list

        readonly property int count: _e.model ? _e.model.length : 0
        readonly property int maxSelector: Math.min(_e.maxView ?? 0, count)

        onSelectorIndexChanged: {
            const c = Math.max(0, Math.min(selectorIndex, maxSelector - 1));
            if (selectorIndex !== c) selectorIndex = c;
        }

        onViewIndexChanged: {
            const c = Math.max(0, Math.min(count - maxSelector, viewIndex));
            if (viewIndex !== c) viewIndex = c;
            _e.viewIndex = viewIndex;
        }

        function goUp() {
            if (selectorIndex > 0) selectorIndex--;
            else if (viewIndex > 0) viewIndex--;
            else { selectorIndex = maxSelector - 1; viewIndex = count - maxSelector; }
        }

        function goDown() {
            if (selectorIndex < maxSelector - 1) selectorIndex++;
            else if (viewIndex + maxSelector < count) viewIndex++;
            else { selectorIndex = 0; viewIndex = 0; }
        }

        function mouseClick(index) {
            if (selectorIndex === index) execute(viewIndex + selectorIndex);
            else selectorIndex = index;
        }

        function execute(index) {
            if (!_textField.commandMode) {
                SharedState.isLauncherOpened = false;
                const entry = _e.model[index].entry;
                configuration.addSearchScore("application", entry.id)
                entry.execute();
                return;
            }
            const entry = _e.model[index].entry;
            _textField.customPlaceHolder = entry.textfieldPlaceHolder;
            _textField.allowTyping = entry.allowTyping;
            _command_panel.command = entry.target;
            _command_panel.isActive = true;
        }

        function reset() {
            viewIndex = 0;
            selectorIndex = 0;
        }

        function goBack() {
            _command_panel.isActive = false;
            _textField.customPlaceHolder = "";
            _textField.allowTyping = true;
            _textField.text = _textField.searchText;
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: _command_panel.isActive ? Qt.ArrowCursor : Qt.PointingHandCursor
            enabled: !_command_panel.isActive

            onClicked: (mouse) => {
                if (commandContainer.spotMode === 3) return
                if ((mouse.y < 10) || mouse.y >= (height - _root.listHeaderArea)) return;
                _root.mouseClick((mouse.y - 10) / _root.rowHeight >> 0);
            }

            onWheel: (wheel) => {
                if (commandContainer.spotMode === 3) return
                if (wheel.angleDelta.y > 0) _root.goUp();
                else _root.goDown();
            }
        }

        Keys.onPressed: (ev) => {
            if (ev.modifiers === Qt.AltModifier && ev.key === Qt.Key_Left) {
                if (_command_panel.isActive) _root.goBack();
                else if (_textField.text === "") SharedState.isLauncherOpened = false;
                else _textField.text = "";
                ev.accepted = true;
                return;
            }

            if (ev.key === Qt.Key_Escape) {
                SharedState.isLauncherOpened = false;
                ev.accepted = true;
                return;
            }

            if (commandContainer.spotMode === 1) {
                _command_panel.onKeyPressed(ev);
                ev.accepted = true;
                return;
            }


            if (commandContainer.spotMode === 3) {
                if (ev.key === Qt.Key_Return || ev.key === Qt.Key_Enter)
                    _caculator.copyResult()
                return
            }

            if (ev.modifiers > Qt.NoModifier) return;
            
            switch (ev.key) {
            case Qt.Key_Down:
                _root.goDown();
                ev.accepted = true;
                break;
            case Qt.Key_Up:
                _root.goUp();
                ev.accepted = true;
                break;
            case Qt.Key_Return:
            case Qt.Key_Enter:
                _root.execute(viewIndex + selectorIndex);
                ev.accepted = true;
                break;
            }
        }

        RadiusRectangle {
            id: selector_panel
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 20
            height: _root.rowHeight
            color: Catppuccin.surface0
            border.width: 0

            y: _root.topOffset + _root.selectorIndex * _root.rowHeight
            opacity: (_command_panel.isActive || (commandContainer.spotMode === 3)) ? 0 : 1

            Behavior on opacity { NumberAnimation { duration: 120 } }
            Behavior on y { NumberAnimation { duration: 350; easing.type: Easing.OutExpo } }
        }

        Column {
            id: _list_container
            spacing: _command_panel.isActive ? 5 : 10
            topPadding: 10
            bottomPadding: 10
            width: _command_panel.isActive ? (_command_panel.width + 20) : 650

            Behavior on width { NumberAnimation { duration: 350; easing.type: Easing.OutExpo } }

            Item {
                id: commandContainer
                clip: true

                width: parent.width
                height: {
                    switch (spotMode) {
                        case 0: return _list.height - 5
                        case 1: return _command_panel.height;
                        case 2: return _cmd_list.height - 5
                        case 3: return _caculator.height
                    }
                }

                readonly property int spotMode: {
                    if (_command_panel.isActive) return 1;
                    if (_textField.commandMode) return 2;
                    if (_textField.caculatorMode) return 3;
                    return 0;
                } 

                Behavior on height { NumberAnimation { duration: 350; easing.type: Easing.OutExpo } }

                Cmd.CommandPanel {
                    id: _command_panel
                    anchors.horizontalCenter: parent.horizontalCenter
                    opacity: isActive ? 1 : 0
                    enabled: isActive
                    visible: opacity > 0
                    Behavior on opacity { NumberAnimation { duration: 120 } }
                    onIsActiveChanged: if (isActive) _textField.text = "";
                }

                Commands {
                    id: _cmd_list
                    opacity: (commandContainer.spotMode === 2) ? 1 : 0
                    enabled: opacity === 1
                    visible: opacity > 0
                    Behavior on opacity { NumberAnimation { duration: 120 } }
                }

                Applications {
                    id: _list
                    opacity: (commandContainer.spotMode === 0) ? 1 : 0
                    enabled: opacity === 1
                    visible: opacity > 0
                    Behavior on opacity { NumberAnimation { duration: 120 } }
                }

                Caculator {
                    id: _caculator
                    opacity: (commandContainer.spotMode === 3) ? 1 : 0
                    enabled: opacity === 1
                    visible: opacity > 0
                    Behavior on opacity { NumberAnimation { duration: 120 } }
                }
            }

            StyledTextField {
                id: _textField
                width: parent.width - 20
                anchors.horizontalCenter: parent.horizontalCenter

                property string searchText: ""
                property bool isLauncherMode: SharedState.overlayDropPanelType
                readonly property bool commandMode: searchText.startsWith("/")
                readonly property bool caculatorMode: searchText.startsWith("=")
                property string customPlaceHolder: ""

                placeholderText: qsTr(customPlaceHolder || "Looking for something? Type '/' for commands or '=' for calculation...")

                onTextChanged: {
                    if (!_command_panel.isActive) searchText = text.trim();
                    else _command_panel.onTextfieldTyping(text);
                }

                Component.onCompleted: forceActiveFocus()
            }
        }
    }
}