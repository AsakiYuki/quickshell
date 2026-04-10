import QtQuick

import "../components"

Item {
    id: _root

    width: 1600
    height: 600

    Rectangle {
        id: test
        width: 50
        height: 50
    }

    StyledText {
        id: bskvvl
        anchors.centerIn: parent
        font.pixelSize: 20
        text: "Bao sao Kiet VIP vai lon"
    }

    RotationAnimation {
        id: testAnim2
        duration: 2500
        from: 0
        to: 360
        target: bskvvl
        running: true
        onFinished: {
            testAnim2.restart();
        }
    }

    SequentialAnimation {
        id: testAnim
        running: true

        onFinished: {
            testAnim.restart();
        }

        NumberAnimation {
            duration: 1700
            target: test
            properties: "x"
            from: 0
            to: 1550
        }

        NumberAnimation {
            duration: 1000
            target: test
            properties: "y"
            from: 0
            to: 550
        }

        NumberAnimation {
            duration: 1700
            target: test
            properties: "x"
            from: 1550
            to: 0
        }

        NumberAnimation {
            duration: 1000
            target: test
            properties: "y"
            from: 550
            to: 0
        }
    }
}
