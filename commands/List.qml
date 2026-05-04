pragma Singleton

import Quickshell

Singleton {
    readonly property list<var> commands: [
        {
            allowTyping: true,
            name: "Steam Game Launcher",
            comment: "Quickly launch your favorite Steam games",
            icon: "../../assets/services/steam.png",
            textfieldPlaceHolder: "Find a game to play...",
            target: "GameLauncher"
        },
        {
            allowTyping: false,
            name: "Wallpaper",
            comment: "Personalize your desktop background",
            icon: "../../assets/icons/images.png",
            textfieldPlaceHolder: "Choose a wallpaper...",
            target: "Wallpapers"
        },
    ]
}