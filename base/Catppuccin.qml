pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: _root

    // Flavors: latte, frappe, macchiato, mocha
    property string flavors: "mocha"

    Component.onCompleted: {
        if (!["latte", "frappe", "macchiato", "mocha"].includes(_root.flavors)) {
            _root.flavors = "mocha";
        }

        switch (_root.flavors) {
        case "latte":
            {
                _root.rosewater = "#dc8a78";
                _root.flamingo = "#dd7878";
                _root.pink = "#ea76cb";
                _root.mauve = "#8839ef";
                _root.red = "#d20f39";
                _root.maroon = "#e64553";
                _root.peach = "#fe640b";
                _root.yellow = "#df8e1d";
                _root.green = "#40a02b";
                _root.teal = "#179299";
                _root.sky = "#04a5e5";
                _root.sapphire = "#209fb5";
                _root.blue = "#1e66f5";
                _root.lavender = "#7287fd";
                _root.text = "#4c4f69";
                _root.subtext1 = "#5c5f77";
                _root.subtext0 = "#6c6f85";
                _root.overlay2 = "#7c7f93";
                _root.overlay1 = "#8c8fa1";
                _root.overlay0 = "#9ca0b0";
                _root.surface2 = "#acb0be";
                _root.surface1 = "#bcc0cc";
                _root.surface0 = "#ccd0da";
                _root.base = "#eff1f5";
                _root.mantle = "#e6e9ef";
                _root.crust = "#dce0e8";
            }
            break;
        case "frappe":
            {
                _root.rosewater = "#f2d5cf";
                _root.flamingo = "#eebebe";
                _root.pink = "#f4b8e4";
                _root.mauve = "#ca9ee6";
                _root.red = "#e78284";
                _root.maroon = "#ea999c";
                _root.peach = "#ef9f76";
                _root.yellow = "#e5c890";
                _root.green = "#a6d189";
                _root.teal = "#81c8be";
                _root.sky = "#99d1db";
                _root.sapphire = "#85c1dc";
                _root.blue = "#8caaee";
                _root.lavender = "#babbf1";
                _root.text = "#c6d0f5";
                _root.subtext1 = "#b5bfe2";
                _root.subtext0 = "#a5adce";
                _root.overlay2 = '#949cbb';
                _root.overlay1 = "#838ba7";
                _root.overlay0 = "#737994";
                _root.surface2 = "#626880";
                _root.surface1 = "#51576d";
                _root.surface0 = "#414559";
                _root.base = "#303446";
                _root.mantle = "#292c3c";
                _root.crust = "#232634";
            }
            break;
        case "macchiato":
            {
                _root.rosewater = "#f4dbd6";
                _root.flamingo = "#f0c6c6";
                _root.pink = "#f5bde6";
                _root.mauve = "#c6a0f6";
                _root.red = "#ed8796";
                _root.maroon = "#ee99a0";
                _root.peach = "#f5a97f";
                _root.yellow = "#eed49f";
                _root.green = "#a6da95";
                _root.teal = "#8bd5ca";
                _root.sky = "#91d7e3";
                _root.sapphire = "#7dc4e4";
                _root.blue = "#8aadf4";
                _root.lavender = "#b7bdf8";
                _root.text = "#cad3f5";
                _root.subtext1 = "#b8c0e0";
                _root.subtext0 = "#a5adcb";
                _root.overlay2 = '#939ab7';
                _root.overlay1 = "#8087a2";
                _root.overlay0 = "#6e738d";
                _root.surface2 = "#5b6078";
                _root.surface1 = "#494d64";
                _root.surface0 = "#363a4f";
                _root.base = "#24273a";
                _root.mantle = "#1e2030";
                _root.crust = "#181926";
            }
            break;
        case "mocha":
            {
                _root.rosewater = "#f5e0dc";
                _root.flamingo = "#f2cdcd";
                _root.pink = "#f5c2e7";
                _root.mauve = "#cba6f7";
                _root.red = "#f38ba8";
                _root.maroon = "#eba0ac";
                _root.peach = "#fab387";
                _root.yellow = "#f9e2af";
                _root.green = "#a6e3a1";
                _root.teal = "#94e2d5";
                _root.sky = "#89dceb";
                _root.sapphire = "#74c7ec";
                _root.blue = "#89b4fa";
                _root.lavender = "#b4befe";
                _root.text = "#cdd6f4";
                _root.subtext1 = "#bac2de";
                _root.subtext0 = "#a6adc8";
                _root.overlay2 = "#9399b2";
                _root.overlay1 = "#7f849c";
                _root.overlay0 = "#6c7086";
                _root.surface2 = "#585b70";
                _root.surface1 = "#45475a";
                _root.surface0 = "#313244";
                _root.base = "#1e1e2e";
                _root.mantle = "#181825";
                _root.crust = "#11111b";
            }
            break;
        }
    }

    property string rosewater
    property string flamingo
    property string pink
    property string mauve
    property string red
    property string maroon
    property string peach
    property string yellow
    property string green
    property string teal
    property string sky
    property string sapphire
    property string blue
    property string lavender
    property string text
    property string subtext1
    property string subtext0
    property string overlay2
    property string overlay1
    property string overlay0
    property string surface2
    property string surface1
    property string surface0
    property string base
    property string mantle
    property string crust
}
