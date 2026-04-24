import QtQuick

import "../components"

Column {
  anchors.right: parent.right
  anchors.bottom: parent.bottom
  
  anchors.rightMargin: 50
  anchors.bottomMargin: 50

  StyledText {
    color: "white"
    opacity: 0.25
    font.pixelSize: 21
    font.weight: 500
    text: "Activate NixOS"
  }

  StyledText {
    color: "white"
    opacity: 0.25
    font.pixelSize: 16
    font.weight: 300
    text: "Go to Settings to activate NixOS."
  }
}
