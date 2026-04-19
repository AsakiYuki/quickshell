import QtQuick

import "../../components"
import "../../base"

Rectangle {
  id: root

  height: 35
  width: container.width + 10
  radius: height / 2
  anchors.verticalCenter: parent.verticalCenter

  color: Catppuccin.surface0

  Row {
    id: container
    height: 35
    leftPadding: 5
    spacing: 10

    ProgressCircle {
      anchors.verticalCenter: parent.verticalCenter
      width: 25
      height: 25
      lineWidth: 2
      showBackground: true
    }
    
    Item {
      anchors.verticalCenter: parent.verticalCenter
      width: nameText.width
      height: nameText.height

      OverflowScrollText {
        id: nameText
        text: "Hello World"
      }
    }
  }
}