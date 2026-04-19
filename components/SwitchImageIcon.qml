import QtQuick

import "../base"

Item {
  id: root

  width: 48
  height: 48

  property bool toggle: false
  property string source: "image.png"
  property color color: Catppuccin.text

  onSourceChanged: {
    toggle = !toggle

    if (toggle) {
      firstImage.source = source
    } else {
      secondImage.source = source
    }
  }

  states: [
    State {
      name: "firstActive"
      when: root.toggle

      PropertyChanges {
        target: firstImage
        scale: 1
        opacity: 1
      }

      PropertyChanges {
        target: secondImage
        scale: 0.2
        opacity: 0
      }
    },

    State {
      name: "secondActive"
      when: !root.toggle

      PropertyChanges {
        target: firstImage
        scale: 0.2
        opacity: 0
      }

      PropertyChanges {
        target: secondImage
        scale: 1
        opacity: 1
      }
    }
  ]

  transitions: [
    Transition {
      NumberAnimation {
        properties: "scale,opacity"
        duration: 300
        easing.type: Easing.OutQuint
      }
    }
  ]

  ImageIcon {
    id: firstImage
    width: root.width
    height: root.height
    color: root.color
    anchors.centerIn: parent
    scale: 1
    opacity: 1
  }

  ImageIcon {
    id: secondImage
    width: root.width
    height: root.height
    color: root.color
    anchors.centerIn: parent
    scale: 0.2
    opacity: 0
  }

  Component.onCompleted: {
    firstImage.source = root.source
  }
}