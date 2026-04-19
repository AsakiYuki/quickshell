import QtQuick

import "../../components"
import "../../base"
import "../../core"

Rectangle {
  id: root

  readonly property var metadata: Mpris.current.metadata

  height: 35
  width: container.width + 15
  radius: height / 2
  anchors.verticalCenter: parent.verticalCenter

  color: Catppuccin.surface0
  visible: Mpris.players.length

  FrameAnimation {
    running: Mpris.current && Mpris.current.playbackState === 1
    onTriggered: {
      progressCircle.arcEnd = ((Mpris.current.position / Mpris.current.length) * 360) >> 0;
    }
  }

  clip: true

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor

    onClicked: {
      Mpris.current.togglePlaying()
    }
  }

  Row {
    id: container
    height: 35
    leftPadding: 5
    spacing: 5

    ProgressCircle {
      id: progressCircle
      anchors.verticalCenter: parent.verticalCenter
      width: 25
      height: 25
      lineWidth: 2
      showBackground: true
      arcEnd: 0

      ImageIcon {
        width: (Mpris.current.playbackState !== 1) * 4 + 16
        height: width
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: (Mpris.current.playbackState !== 1) * -1
        source: Mpris.current.playbackState === 1 ? "../assets/icons/pause.png" : "../assets/icons/play.png"
      }
    }
    
    Item {
      anchors.verticalCenter: parent.verticalCenter
      width: nameText.width
      height: nameText.height

      Behavior on width {
        NumberAnimation {
          duration: 350
          easing.type: Easing.OutQuint
        }
      }

      Column {
        id: nameText
        y: -1
        spacing: -2

        OverflowScrollText {
          text: Mpris.current.trackTitle || "Unknown Track"
          moveSpeed: 1500
          delayRepeat: 1000
          textComponent: StyledText {
            font.pixelSize: 12
          }
        }

        OverflowScrollText {
          text: `${Mpris.current.trackArtists}${Mpris.current.trackAlbum ? ` - ${Mpris.current.trackAlbum}` : ""}`
          moveSpeed: 1500
          delayRepeat: 1000
          textComponent: StyledText {
            font.pixelSize: 12
            color: Catppuccin.subtext0
          }
        }
      }
    }
  }

  onMetadataChanged: {
    console.log(JSON.stringify(metadata))
  }
}