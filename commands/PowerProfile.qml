import QtQuick

import Quickshell
import Quickshell.Services.UPower

import "../components"

Item {
    width: 100
    height: 100

    StyledText {
        text: UPower.displayDevice.percentage
    }
}
