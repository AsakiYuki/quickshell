pragma Singleton

import Quickshell

Singleton {
    readonly property list<var> commands: [
        {
            allowTyping: true,
            name: "Steam game launcher",
            comment: "Quickly launch your favorite Steam games",
            icon: "../../assets/services/steam.png",
            textfieldPlaceHolder: "Find a game to play...",
            target: "GameLauncher"
        },
        {
            allowTyping: true,
            name: "Waydroid",
            comment: "Quickly launch your android applications",
            icon: "../../assets/icons/android.png",
            textfieldPlaceHolder: "Search a adnroid app...",
            target: "Waydroid"
        },
        {
            allowTyping: true,
            name: "Open recent code project",
            comment: "Quickly open your recent VSCode projects",
            icon: "../../assets/icons/folder_code.png",
            textfieldPlaceHolder: "Search projects...",
            target: "VSCodeLauncher"
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