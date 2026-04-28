import QtQuick

import Quickshell.Hyprland

import "../../components"
import "../../base"
import "../../core"

SimpleButton {
    id: _root

    width: _workspaces.width + 10
    height: _workspaces.height + 10
    clip: true

    Behavior on width {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutQuint
        }
    }

    color: Catppuccin.surface0
    radius: height / 2
    anchors.verticalCenter: parent.verticalCenter

    onWheel: ev => {
        if (ev.angleDelta.y < 0) Workspaces.next();
        else Workspaces.prev();
    }

    onClicked: ev => {
        const x = ev.x - 5; // 5 is the left margin
        const index = Math.min(Math.max(0, Math.floor(x / 25)), Hyprland.workspaces.values.length - 1); // 25 is the workspace size
        Workspaces.set(Hyprland.workspaces.values[index].id);
    }

    Rectangle {
        width: 25
        height: 25
        anchors.verticalCenter: parent.verticalCenter
        color: Catppuccin.surface1
        radius: width / 2
        x: 5.5 + Hyprland.workspaces.values.findIndex(w => w.active) * 25

        Behavior on x {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutBack
            }
        }
    }

    Row {
        id: _workspaces
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.verticalCenter: parent.verticalCenter

        Repeater {
            model: Hyprland.workspaces.values

            Item {
                id: _workspace

                required property HyprlandWorkspace modelData

                width: 25
                height: 25

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutQuint
                    }
                }

                StyledText {
                    anchors.centerIn: parent
                    font.pixelSize: 14
                    text: _workspace.modelData.id % 10
                }
            }
        }
    }
}
