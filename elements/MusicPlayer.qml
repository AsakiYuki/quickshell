import QtQuick

import "../components"
import "../base"
import "../core"

import "../utils/Utils.js" as Utils

DropPanel {
  id: root

  active: SharedState.overlayDropPanelType === 3
  viewX: 5
  viewY: 5
  direction: 2

  openDuration: 500

  verticalPadding: 40
  horizontalPadding: verticalPadding

  content: Item {
    width: 420
    height: contents.height

    Row {
      id: contents
      anchors.centerIn: parent
      spacing: 15

      RadiusImage {
        radius: 5
        source: Mpris.current.trackArtUrl || "../assets/fallback.jpg"
        width: 100
        height: 100
        fillMode: Image.PreserveAspectCrop
      }

      Item {
        height: parent.height
        width: textContents.width

        Column {
          id: textContents
          width: 300

          OverflowScrollText {
            text: Mpris.current.trackTitle || "Unknown Track"
            maxWidth: 300

            textComponent: StyledText {
              font.pixelSize: 18
              font.weight: 1000
            }
          }

          OverflowScrollText {
            text: `${Mpris.current.trackArtists}${Mpris.current.trackAlbum ? ` - ${Mpris.current.trackAlbum}` : ""}`
            maxWidth: 300

            textComponent: StyledText {
              color: Catppuccin.subtext0
            }
          }
        }

        Item {
          height: 35
          width: parent.width
          anchors.bottom: parent.bottom

          StyledButton {
            height: parent.height
            width: height
            radius: 5
            normalColor: Catppuccin.base
            hoverColor: Catppuccin.surface0
            pressedColor: Catppuccin.surface2

            onClicked: Mpris.current.previous()

            ImageIcon {
              width: 30
              height: width
              anchors.centerIn: parent
              source: "../assets/icons/skip_previous.png"
            }
          }

          StyledButton {
            height: parent.height
            width: height
            radius: 5
            x: 45
            normalColor: Catppuccin.base
            hoverColor: Catppuccin.surface0
            pressedColor: Catppuccin.surface2

            onClicked: Mpris.current.next()

            ImageIcon {
              width: 30
              height: width
              anchors.centerIn: parent
              source: "../assets/icons/skip_next.png"
            }
          }

          ProgressCircle {
            width: 40
            height: 40
            lineWidth: 3
            showBackground: true
            arcEnd: topbar.musicPlayer.arcEnd
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            StyledButton {
              anchors.centerIn: parent
              height: 34
              width: 34
              radius: 20
           
              normalColor: Catppuccin.base
              hoverColor: Catppuccin.surface0
              pressedColor: Catppuccin.surface2

              onClicked: Mpris.current.togglePlaying()

              SwitchImageIcon {
                width: 26
                height: 26
                anchors.centerIn: parent
                source: Mpris.current.playbackState === 1 ? "../assets/icons/pause.png" : "../assets/icons/play.png"
              }
            }
          }

          Row {
            spacing: 5
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 56

            StyledText {
              text: Utils.secondsToTime(topbar.musicPlayer.position)
              font.weight: 1000
            }

            StyledText {
              text: "/"
              font.weight: 1000
            }

            StyledText {
              text: Utils.secondsToTime(topbar.musicPlayer.length)
              font.weight: 1000
            }
          }
        }
      }
    }
  }
}