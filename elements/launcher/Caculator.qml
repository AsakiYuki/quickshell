import QtQuick

import "../../components"
import "../../base"
import "../../core"

import "./CalcCore.js" as CalcCore

Item {
    id: root
    width: parent.width - 20
    height: 100
    anchors.horizontalCenter: parent.horizontalCenter

    property bool isCopyable: false

    function copyResult() {
        if (!isCopyable) return
        SharedState.isLauncherOpened = false
        chillProcess.exec(["wl-copy", outputText.text])
    }

    readonly property string input: _textField.text
    onInputChanged: {
        if (!input.startsWith("=")) {
            isCopyable = false;
            return;
        }
        try {
            if (input.slice("1").trim() === "") {
                isCopyable = false;
                inputText.text = errorText.text= "";
                outputText.text = "Enter a expression!";
            } else {
                isCopyable = true;
                const output = CalcCore.calc(input.slice(1)); 
                inputText.text = input.slice(1).trim();
                outputText.text = output;
                errorText.text = "";
            }
        } catch(err) {
            isCopyable = true;
            inputText.text = ""
            outputText.text =`Math Error`
            errorText.text = String(err);
        }
    }

    Component.onCompleted: {
        // CalcCore.constant.sw = Screen.width;
        // CalcCore.constant.sh = Screen.height;
    }

    Column {
        anchors.centerIn: parent

        StyledText {
            id: inputText
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 15
            color: Catppuccin.subtext1
        }

        StyledText {
            id: outputText
            font.pixelSize: 20
            font.weight: 1000
            anchors.horizontalCenter: parent.horizontalCenter
        }

        StyledText {
            id: errorText
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 15
            color: Catppuccin.subtext1
        }
    }
}