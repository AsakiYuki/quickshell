import QtQuick
import Quickshell

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
        readonly property int listHeaderArea: 0

        property int viewIndex: 0
        property int selectorIndex: 0

        readonly property var _e: _textField.commandMode ? _cmd_list : _list

        property int count: _e.model ? _e.model.length : 0
        property int maxSelector: Math.min(_e.maxView || 0, count)

        
        onSelectorIndexChanged: {
            let clamped = Math.max(0, Math.min(selectorIndex, maxSelector - 1));
            if (selectorIndex !== clamped) selectorIndex = clamped;
        }

        onViewIndexChanged: {
            let clamped = Math.max(0, Math.min(count - maxSelector, viewIndex));
            if (viewIndex !== clamped) {
                viewIndex = clamped;
            }
            _e.viewIndex = viewIndex;
        }

        function goUp() {
            if (selectorIndex < 1) {
                if (viewIndex === 0) {
                    selectorIndex = maxSelector - 1;
                    viewIndex = count;
                } else {
                    viewIndex--;
                }
            } else {
                selectorIndex--;
            }
        }

        function goDown() {
            if (selectorIndex > maxSelector - 2) {
                if (viewIndex + maxSelector >= count) { 
                    selectorIndex = 0;
                    viewIndex = 0;
                } else {
                    viewIndex++;
                }
            } else {
                selectorIndex++;
            }
        }

        function mouseClick(index) {
            if (selectorIndex === index) {
                execute(viewIndex + selectorIndex);
            } else {
                selectorIndex = index;
            }
        }

        function execute(index) {
            if (!_textField.commandMode) {
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
            viewIndex = 0;
            selectorIndex = 0;
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: _command_panel.isActive ? Qt.ArrowCursor : Qt.PointingHandCursor
            enabled: !_command_panel.isActive

            onClicked: (mouse) => {
                if (mouse.y <= _root.listHeaderArea) return;
                
                let clickedIndex = (mouse.y / _root.rowHeight >> 0);
                _root.mouseClick(clickedIndex);
            }

            onWheel: (wheel) => {
                if (wheel.angleDelta.y > 0) _root.goUp();
                else _root.goDown();
            }
        }

        
        Keys.onPressed: (ev) => {
            if (ev.modifiers === Qt.AltModifier && ev.key === Qt.Key_Left) {
                if (_command_panel.isActive) {
                    _command_panel.isActive = false;
                    _textField.customPlaceHolder = "";
                    _textField.allowTyping = true;
                    _textField.text = _textField.searchText;
                } else if (_textField.text === "") {
                    SharedState.isLauncherOpened = false;
                } else {
                    _textField.text = "";
                }
                ev.accepted = true;
                return;
            } 
            
            if (ev.key === Qt.Key_Escape) {
                SharedState.isLauncherOpened = false;
                ev.accepted = true;
                return;
            }

            if (_command_panel.isActive) {
                _command_panel.onKeyPressed(ev);
                ev.accepted = true;
                return;
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
                case Qt.Key_Enter:
                case Qt.Key_Return:
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
            
            
            y: _root.topOffset + _root.selectorIndex * _root.rowHeight
            border.width: 0

            opacity: _command_panel.isActive ? 0 : 1
            Behavior on opacity { NumberAnimation { duration: 120 } }
            Behavior on y { NumberAnimation { duration: 350; easing.type: Easing.OutExpo } }
        }

        Column {
            id: _list_container
            spacing: 10
            topPadding: 10
            bottomPadding: 10
            width: _command_panel.isActive ? (_command_panel.width + 20) : 650

            Behavior on width { NumberAnimation { duration: 350; easing.type: Easing.OutExpo } }

            Item {
                width: parent.width
                height: _command_panel.isActive ? _command_panel.height : (_textField.commandMode ? _cmd_list.height : _list.height) - 5
                clip: true

                Behavior on height { NumberAnimation { duration: 350; easing.type: Easing.OutExpo } }

                Cmd.CommandPanel {
                    id: _command_panel
                    anchors.horizontalCenter: parent.horizontalCenter
                    opacity: isActive ? 1 : 0
                    
                    
                    enabled: isActive
                    visible: opacity > 0

                    Behavior on opacity { NumberAnimation { duration: 120 } }
                    
                    onIsActiveChanged: {
                        if (isActive) _textField.text = "";
                    }
                }

                Commands {
                    id: _cmd_list
                    opacity: (_textField.commandMode && !_command_panel.isActive) ? 1 : 0
                    enabled: opacity === 1 
                    visible: opacity > 0   
                    Behavior on opacity { NumberAnimation { duration: 120 } }
                }

                Applications {
                    id: _list
                    opacity: (!_textField.commandMode && !_command_panel.isActive) ? 1 : 0
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
                property string customPlaceHolder: ""

                placeholderText: qsTr(customPlaceHolder === "" ? "Type '/' to enter a command..." : customPlaceHolder)

                onTextChanged: {
                    if (!_command_panel.isActive) {
                        searchText = text.trim();
                    }
                }

                Component.onCompleted: forceActiveFocus()
            }
        }
    }
}