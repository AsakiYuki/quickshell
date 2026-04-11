pragma Singleton

import Quickshell

Singleton {
    readonly property list<var> commands: [
        {
            name: "Wallpaper",
            comment: "Change your current wallpaper",
            icon: "../../assets/icons/images.png",
            textfieldPlaceHolder: "Choose your wallpaper",
            allowTyping: false,
            target: "Wallpapers"
        },
        {
            name: "Power Profiles",
            comment: "Test",
            icon: "../../assets/icons/images.png",
            textfieldPlaceHolder: "Test, btw",
            allowTyping: true,
            target: "PowerProfile"
        },
    ]
}
