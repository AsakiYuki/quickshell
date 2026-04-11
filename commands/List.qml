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
        {
            allowTyping: true,
            name: "Baterry Checker",
            comment: "Topbar currently is not implement right now!",
            icon: "../../assets/icons/images.png",
            textfieldPlaceHolder: "Test, btw",
            target: "PowerProfile"
        },
    ]
}
