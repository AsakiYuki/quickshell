import QtQuick

import Quickshell
import Quickshell.Services.UPower

import "../components"

Item {
    StyledText {
        text: `Baterry: ${(UPower.displayDevice.percentage * 100) >> 0}%`
    }
}
