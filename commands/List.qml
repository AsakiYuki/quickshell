pragma Singleton

import Quickshell

Singleton {
    readonly property list<var> commands: [
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
