import QtQuick

import "../components"

Column {
  anchors.right: parent.right
  anchors.bottom: parent.bottom
  
  anchors.rightMargin: 50
  anchors.bottomMargin: 60

  StyledText {
    color: "white"
    opacity: 0.15
    font.pixelSize: 20
    font.weight: 500
    text: "Activate NixOS"
  }

  StyledText {
    color: "white"
    opacity: 0.15
    font.pixelSize: 15
    font.weight: 300
    text: "Go to Settings to activate NixOS."
  }
}
