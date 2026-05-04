pragma Singleton

import Quickshell
import Quickshell.Services.Mpris

Singleton {
    property int index: 0
    readonly property list<MprisPlayer> players: Array.from(Mpris.players.values)
    readonly property MprisPlayer current: players[index]
}