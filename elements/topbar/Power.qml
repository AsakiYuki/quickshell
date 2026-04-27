import QtQuick
import Quickshell.Services.UPower

import "../../components"
import "../../core"
import "../../base"

SimpleButton {
  width: viewer.width + 30
  height: 35
  color: Catppuccin.surface0
  radius: height / 2
  anchors.verticalCenter: parent.verticalCenter

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: SharedState.toggleOverlay(1)
  }

  Row {
    id: viewer
    anchors.centerIn: parent
    spacing: 2

    ScrollText {
      anchors.verticalCenter: parent.verticalCenter
      text: `${(UPower.displayDevice.percentage * 100) >> 0}`
    }

    ImageIcon {
      anchors.verticalCenter: parent.verticalCenter
      width: 20
      height: 20

      source: {
        if (UPower.onBattery) {
          switch (true) {
            case (UPower.displayDevice.percentage === 1): return "../assets/icons/battery_100";
            case (UPower.displayDevice.percentage >= 0.8): return "../assets/icons/battery_80";
            case (UPower.displayDevice.percentage >= 0.6): return "../assets/icons/battery_60";
            case (UPower.displayDevice.percentage >= 0.5): return "../assets/icons/battery_50";
            case (UPower.displayDevice.percentage >= 0.4): return "../assets/icons/battery_40";
            case (UPower.displayDevice.percentage >= 0.2): return "../assets/icons/battery_20";
            case (UPower.displayDevice.percentage >= 0.1): return "../assets/icons/battery_10";
            case (UPower.displayDevice.percentage >= 0): return "../assets/icons/battery_0";
          }
        } else {
          switch (true) {
            case (UPower.displayDevice.percentage === 1): return "../assets/icons/battery_charging_100";
            case (UPower.displayDevice.percentage >= 0.9): return "../assets/icons/battery_charging_90";
            case (UPower.displayDevice.percentage >= 0.8): return "../assets/icons/battery_charging_80";
            case (UPower.displayDevice.percentage >= 0.6): return "../assets/icons/battery_charging_60";
            case (UPower.displayDevice.percentage >= 0.5): return "../assets/icons/battery_charging_50";
            case (UPower.displayDevice.percentage >= 0.2): return "../assets/icons/battery_charging_20";
            case (UPower.displayDevice.percentage >= 0): return "../assets/icons/battery_charging_0";
          }
        }
      }
    }
  }
}