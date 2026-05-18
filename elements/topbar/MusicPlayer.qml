import QtQuick

import "../../components"
import "../../base"
import "../../core"

import "../../utils/HttpRequest.js" as HttpRequest
import "../../utils/Lyrics.js" as Lyrics
import "../../utils/Color.js" as ColorUtils

SimpleButton {
    id: root

    readonly property var metadata: `${Mpris.current?.identity}|${Mpris.current?.trackArtists}|${Mpris.current?.trackAlbum}`
    readonly property string ciderToken: "rqwqpw7m99wazqxzg05z2em3"
    property list<var> lyrics: []

    property string trackTitle: ""
    property string trackArtists: ""
    property string trackAlbum: ""

    property int currentLyricLine: 0
    property double realLength: 0
    property double timeOffset: 0

    property double position: 0
    property double length: realLength || Mpris.current?.length || 0

    property double lyricsDelay: 0.3
    property int fetchId: 0

    property int arcEnd: 0

    function fetchAppleMxmLyrics(data) {
        return HttpRequest.fetchJson("https://rise.cider.sh/api/v1/lyrics/mxm", {
            method: "POST",
            body: JSON.stringify(data)
        }).then(data => {
            const lyrics = Lyrics.parseMxm(data.body);
            if (lyrics[0].time.start === 0) return lyrics;
            else return [{ text: "", time: { start: 0, end: lyrics[0].time.start }}, ...lyrics];
        });
    }

    function fetchLrclibLyrics(data) {
        return HttpRequest.fetchJson(`https://lrclib.net/api/get${Utils.buildSearchQuery(data)}`).then(v => {
            const lyrics = Lyrics.parseLrclib(v.syncedLyrics);
            if (lyrics[0].time.start === 0) return lyrics;
            else return [{ text: "", time: { start: 0, end: lyrics[0].time.start }}, ...lyrics];
        });
    }

    onCurrentLyricLineChanged: {
        const lyrics = root.lyrics[currentLyricLine] || { text: "", time: {} };
        lyricText.text = (currentLyricLine & 1 ? "‎" : "") + lyrics.text;
        if (lyrics.text) console.info(`Lyrics ${currentLyricLine} ${lyrics.time.start.toFixed(2)}-${lyrics.time.end.toFixed(2)}: ${lyricText.text}`);
    }

    height: 35
    width: container.width + 15
    radius: height / 2
    anchors.verticalCenter: parent.verticalCenter

    visible: Mpris.players.length
    clip: true
    onVisibleChanged: if (!visible) SharedState.overlayDropPanelType = 0;
    onMetadataChanged: {
        root.lyrics = [];
        root.realLength = currentLyricLine = 0;

        root.trackTitle = Mpris.current?.trackTitle || ""
        root.trackArtists = Mpris.current?.trackArtists || ""
        root.trackAlbum = Mpris.current?.trackAlbum || ""

        if (Mpris.current?.identity === "Cider") {
            const currentId = ++root.fetchId;
            root.timeOffset = Mpris.current?.position;
            HttpRequest.fetchJson("http://localhost:10767/api/v1/playback/now-playing", { headers: { apptoken: root.ciderToken }}).then(({ info }) =>
            {
                if (currentId !== root.fetchId) return;

                root.timeOffset -= info.currentPlaybackTime;
                root.realLength = info.durationInMillis / 1000;

                const id = info.playParams.catalogId || info.playParams.id;
                const name = info.name;
                const artist = info.artistName;
                const album = info.albumName;
                const duration = info.durationInMillis;

                root.trackTitle = name;
                root.trackArtists = artist;
                root.trackAlbum = album;
                // root.bigTrackArtUrl = info.artwork.url;

                if (!info.hasLyrics)
                    return;

                console.info(`Fetching lyrics for ${name} - ${artist}`);
                const callback = () => fetchAppleMxmLyrics({ id, name, artist, album, duration }).then(v => { if (currentId === root.fetchId) root.lyrics = v; });
                
                callback().then(() => {
                    if (currentId !== root.fetchId) return;
                    console.info(`Found lyrics for ${name} - ${artist}`);
                }).catch(() => {
                    if (currentId !== root.fetchId) return;
                    console.info(`Fetch lyrics for ${name} - ${artist} failed, retry!`);
                    return callback().then(() => {
                        if (currentId !== root.fetchId) return;
                        console.info(`Found lyrics for ${name} - ${artist}`);
                    }).catch(() => {
                        if (currentId !== root.fetchId) return;
                        console.info(`Lyrics for ${name} - ${artist} not found!`);
                        console.info(`Try to fetch the lyrics from lrclib!`);

                        return fetchLrclibLyrics({
                            artist_name: artist,
                            track_name: name,
                            duration: duration / 1000 >> 0
                        }).then(v => {
                            if (currentId !== root.fetchId) return;
                            console.info(`Found lyrics for ${name} - ${artist}`);
                            root.lyrics = v;
                        }).catch(() => {
                            console.info(`Lyrics for ${name} - ${artist} not found!`);
                        });
                    });
                }).then(v => {
                    if (currentId !== root.fetchId) return;
                    if (currentId === root.fetchId) console.info(`DONE!`);
                    else console.info("CANCELED!");
                });
            });
        } else root.timeOffset = 0;

        root.updatePositionView();
    }

    function updatePositionView() {
        root.position = Mpris.current?.position - root.timeOffset;
        root.arcEnd = ((root.position / root.length) * 360) >> 0;
        if (!Workspaces.current?.hasFullscreen) {
            progressCircle.arcEnd = root.arcEnd;
        }
    }

    function updateLyrics() {
        const timeCurr = Math.max(0, Mpris.current?.position + root.lyricsDelay - root.timeOffset);
        const { time } = root.lyrics[root.currentLyricLine] || {};

        if (time?.start <= timeCurr && timeCurr <= time?.end) return;
        if (time?.start > timeCurr) {
            for (let index = root.currentLyricLine; index > -1; index--) {
                const { text, time } = root.lyrics[index];
                if (timeCurr >= time.start && timeCurr <= time.end) {
                    root.currentLyricLine = index;
                    return;
                }
            }
        } else if (timeCurr > time?.end) {
            for (let index = root.currentLyricLine; index < root.lyrics.length; index++) {
                const { text, time } = root.lyrics[index];
                if (timeCurr >= time.start && timeCurr <= time.end) {
                    root.currentLyricLine = index;
                    return;
                }
            }
            root.currentLyricLine = root.lyrics.length;
        }
    }

    FrameAnimation {
        running: (Mpris.current && Mpris.current?.playbackState === 1) && !Workspaces.current?.hasFullscreen || (SharedState.overlayDropPanelType === 3)
        onTriggered: {
            root.updatePositionView();
            if (root.lyrics.length && !Workspaces.current?.hasFullscreen) root.updateLyrics();
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: SharedState.toggleOverlay(3)
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

            SwitchImageIcon {
                width: 15
                height: width

                Behavior on width { NumberAnimation { duration: 150 }}

                anchors.centerIn: parent
                source: Mpris.current?.playbackState === 1 ? "../assets/icons/pause.png" : "../assets/icons/play.png"
            }
        }

        Item {
            anchors.verticalCenter: parent.verticalCenter
            width: ((`${lyricText.text}` === "") || (`${lyricText.text}` === "‎") || (Mpris.current?.playbackState === 2)) ? nameText.width : lyricText.width
            height: nameText.height

            Behavior on width { NumberAnimation { duration: 350; easing.type: Easing.OutQuint } }

            ScrollText {
                id: lyricText
                viewHeight: parent.height
                resizeSpeed: 0
                anchors.verticalCenter: parent.verticalCenter
                opacity: 1 - nameText.opacity
                
                width: ((displayWidth - 225) > 25) ? 225 : displayWidth

                shaderComponent: ShaderEffectSource {
                    id: shader

                    readonly property int duration: (((root.lyrics[currentLyricLine]?.time.end || 0) - (root.lyrics[currentLyricLine]?.time.start || 0)) * 1000)
                    readonly property bool isOverflow: (width >> 0) > lyricText.width
                    readonly property bool isPlaying: Mpris.current?.playbackState === 1

                    onIsPlayingChanged: if (isOverflow) { if (isPlaying) moveLyricsAnim.pause(); else moveLyricsAnim.resume(); }

                    function onUpdate() {
                        if (isOverflow) {
                            moveLyricsAnim.to = -(width - lyricText.width);
                            moveLyricsAnim.restart();
                        } else moveLyricsAnim.stop();
                        x = 0;
                    }

                    NumberAnimation {
                        id: moveLyricsAnim
                        target: shader
                        running: false
                        properties: "x"
                        from: 0
                        to: 0
                        easing.type: Easing.InOutSine
                        duration: shader.duration * 0.7
                    }
                }
            }

            Column {
                id: nameText
                y: -1
                spacing: -2
                opacity: ((`${lyricText.text}` === "") || (`${lyricText.text}` === "‎") || (Mpris.current?.playbackState === 2))

                Behavior on opacity { NumberAnimation { duration: 150 } }

                OverflowScrollText {
                    text: root.trackTitle || "Unknown Track"
                    paused: !nameText.opacity
                    textComponent: StyledText { font.pixelSize: 12 }
                }

                OverflowScrollText {
                    text: `${root.trackArtists}${root.trackAlbum ? ` - ${root.trackAlbum}` : ""}`
                    paused: !nameText.opacity
                    textComponent: StyledText { font.pixelSize: 12; color: Catppuccin.subtext0 }
                }
            }
        }
    }

    Component.onCompleted: { topbar.musicPlayer = this; }
}
