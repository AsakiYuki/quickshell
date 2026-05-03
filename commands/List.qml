pragma Singleton

import Quickshell

Singleton {
    readonly property list<var> commands: [
        {
            allowTyping: true,
            name: "Steam Game Launcher",
            comment: "Launch your Steam game",
            icon: "../../assets/services/steam.png",
            textfieldPlaceHolder: "Search a game...",
            target: "GameLauncher"
        },
        {
            allowTyping: false,
            name: "Wallpaper",
            comment: "Change your current wallpaper",
            icon: "../../assets/icons/images.png",
            textfieldPlaceHolder: "Choose your wallpaper",
            target: "Wallpapers"
        },
    ]
}
