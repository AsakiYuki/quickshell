import QtQuick

import "../../components"
import "../../base"
import "../../core"

import "../../utils/HttpRequest.js" as HttpRequest
import "../../utils/Lyrics.js" as Lyrics

Rectangle {
  id: root

  readonly property var metadata: `${Mpris.current.identity}|${Mpris.current.trackArtists}|${Mpris.current.trackAlbum}`
  readonly property string ciderToken: "rqwqpw7m99wazqxzg05z2em3"
  property list<var> lyrics: []

  property int currentLyricLine: 0
  property double realLength: 0
  property double timeOffset: 0

  property double lyricsDelay: 0.3
  property int fetchId: 0

  onCurrentLyricLineChanged: {
    const lyrics = root.lyrics[currentLyricLine] || { text: "", time: {} };
    lyricText.text = (currentLyricLine & 1 ? "‎" : "") + lyrics.text
  }

  height: 35
  width: container.width + 15
  radius: height / 2
  anchors.verticalCenter: parent.verticalCenter

  color: Catppuccin.surface0
  visible: Mpris.players.length
  clip: true
  onMetadataChanged: {
    root.lyrics = [];
    root.realLength = currentLyricLine = 0;
    if (Mpris.current.identity === "Cider") {
      const currentId = ++root.fetchId;
      root.timeOffset = Mpris.current.position
      HttpRequest.fetchJson("http://localhost:10767/api/v1/playback/now-playing", {
        headers: { apptoken: root.ciderToken },
      }).then(({ info }) => {
        if (currentId !== root.fetchId) return
        
        root.timeOffset -= info.currentPlaybackTime
        root.realLength = info.durationInMillis / 1000

        if (!info.hasLyrics) return;
        
        const id = info.playParams.catalogId || info.playParams.id;
        const name = info.name;
        const artist = info.artistName;
        const album = info.albumName;
        const duration = info.durationInMillis;

        HttpRequest.fetchJson("https://rise.cider.sh/api/v1/lyrics/mxm", {
          method: "POST",
          body: JSON.stringify({ id, name, artist, album, duration })
        }).then(v => {
          if (currentId !== root.fetchId) return
          const lyrics = Lyrics.parse(v.body)
          if (lyrics[0].time.start === 0) root.lyrics = lyrics
          else root.lyrics = [
            {text: "", time: { start: 0, end: lyrics[0].time.start }},
            ...lyrics
          ]
        })
      })
    } else root.timeOffset = 0;
    
    root.updatePositionView();
  }

  function updatePositionView() {
    progressCircle.arcEnd = (((Mpris.current.position - root.timeOffset) / (root.realLength || Mpris.current.length)) * 360) >> 0;
  }
  
  function updateLyrics() {
    const timeCurr = Math.max(0, Mpris.current.position + root.lyricsDelay - root.timeOffset)
    const { time } = root.lyrics[root.currentLyricLine] || {}

    if (time?.start <= timeCurr && timeCurr <= time?.end) return
    if (time?.start > timeCurr) {
      for (let index = root.currentLyricLine; index > -1; index--) {
        const { text, time } = root.lyrics[index];
        if (timeCurr >= time.start && timeCurr <= time.end) {
          root.currentLyricLine = index
          return
        }
      }
    } else if (timeCurr > time?.end) {
      for (let index = root.currentLyricLine; index < root.lyrics.length; index++) {
        const { text, time } = root.lyrics[index];
        if (timeCurr >= time.start && timeCurr <= time.end) {
          root.currentLyricLine = index
          return;
        }
      }
      root.currentLyricLine = root.lyrics.length;
    }
  }

  FrameAnimation {
    running: (Mpris.current && Mpris.current.playbackState === 1) && !Workspaces.current.hasFullscreen
    onTriggered: {
      root.updatePositionView()
      if (root.lyrics.length) root.updateLyrics()
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: Mpris.current.togglePlaying()
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
      lineWidth: 3
      showBackground: true
      arcEnd: 0

      SwitchImageIcon {
        width: (Mpris.current.playbackState !== 1) * 4 + 15
        height: width

        Behavior on width {
          NumberAnimation {
            duration: 150
          }
        }

        anchors.centerIn: parent
        source: Mpris.current.playbackState === 1 ? "../assets/icons/pause.png" : "../assets/icons/play.png"
      }
    }
    
    Item {
      anchors.verticalCenter: parent.verticalCenter
      width:  ((`${lyricText.text}` === "") || (`${lyricText.text}` === "‎") || (Mpris.current.playbackState === 2)) ? nameText.width : lyricText.width
      height: nameText.height

      Behavior on width {
        NumberAnimation {
          duration: 350
          easing.type: Easing.OutQuint
        }
      }

      ScrollText {
        id: lyricText
        viewHeight: 30
        resizeSpeed: 0
        anchors.verticalCenter: parent.verticalCenter
        opacity: 1 - nameText.opacity
      }

      Column {
        id: nameText
        y: -1
        spacing: -2
        opacity: ((`${lyricText.text}` === "") || (`${lyricText.text}` === "‎") || (Mpris.current.playbackState === 2))
        
        Behavior on opacity {
          NumberAnimation {
            duration: 150
          }
        }

        OverflowScrollText {
          text: Mpris.current.trackTitle || "Unknown Track"
          paused: !nameText.opacity
          textComponent: StyledText {
            font.pixelSize: 12
          }
        }

        OverflowScrollText {
          text: `${Mpris.current.trackArtists}${Mpris.current.trackAlbum ? ` - ${Mpris.current.trackAlbum}` : ""}`
          paused: !nameText.opacity
          textComponent: StyledText {
            font.pixelSize: 12
            color: Catppuccin.subtext0
          }
        }
      }
    }
  }
}