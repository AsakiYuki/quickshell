import QtQuick

import "../../components"
import "../../base"

import "./CalcCore.js" as CalcCore

Item {
    id: root
    width: parent.width - 20
    height: 100
    anchors.horizontalCenter: parent.horizontalCenter

    readonly property string input: _textField.text
    onInputChanged: {
        if (!input.startsWith("=")) return;
        try {
            const output = CalcCore.calc(input.slice(1)); 
            inputText.text = input.slice(1).trim();
            outputText.text = output;
            errorText.text = "";
        } catch(err) {
            inputText.text = ""
            outputText.text = `Math Error`
            errorText.text = String(err);
        }
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