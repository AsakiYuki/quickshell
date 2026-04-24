import QtQuick
import Quickshell.Services.UPower

import "../components"
import "../base"
import "../core"

DropPanel {
  id: root

  anchors.right: parent.right
  anchors.rightMargin: 5
  
  active: SharedState.overlayDropPanelType === 1
  viewY: 5

  content: Item {
    width: 205
    height: container.height + 40

    Column {
      id: container
      anchors.centerIn: parent
      spacing: 10

      StyledText {
        text: `Power Profile: ${["Power Saver", "Balanced", "Performance"][PowerProfiles.profile]}`
      }

      Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter

        width: icons.width + 20
        height: icons.height + 20
        radius: height / 2

        color: Catppuccin.crust

        Rectangle {
          anchors.verticalCenter: parent.verticalCenter
          width: 35
          height: 35
          radius: height / 2
          color: Catppuccin.red
          x: 5 + (PowerProfiles.profile * 50)

          Behavior on x {
            NumberAnimation {
              duration: 150
              easing.type: Easing.OutQuint
            }
          }
        }

        Row {
          id: icons
          anchors.centerIn: parent
          spacing: 25

          ImageIcon {
            width: 25
            height: 25
            color: (PowerProfiles.profile === PowerProfile.PowerSaver) ? Catppuccin.base : Catppuccin.text
            source: "../assets/icons/energy_savings_leaf"
            
            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: PowerProfiles.profile = PowerProfile.PowerSaver
            }
          }

          ImageIcon {
            width: 25
            height: 25
            color: (PowerProfiles.profile === PowerProfile.Balanced) ? Catppuccin.base : Catppuccin.text
            source: "../assets/icons/balance"
            
            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: PowerProfiles.profile = PowerProfile.Balanced
            }
          }

          ImageIcon {
            width: 25
            height: 25
            color: (PowerProfiles.profile === PowerProfile.Performance) ? Catppuccin.base : Catppuccin.text
            source: "../assets/icons/rocket_launch"
            
            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: PowerProfiles.profile = PowerProfile.Performance
            }
          }
        }
      }
    }
  }
}