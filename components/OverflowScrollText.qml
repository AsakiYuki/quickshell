import QtQuick

Item {
    id: root

    property Component textComponent: Component { StyledText {} }
    property string text: "Hello Overflow Scrolltext"
    
    property bool scrollToRight: false
    property bool moveFirst: false
    property bool paused: false

    property int spacing: 50
    property int maxWidth: 200
    property int delayRepeat: 2500
    property int moveSpeed: 1000
    property int easingType: Easing.InOutSine 

    property Item leftText: loaderLeft.item
    property Item rightText: loaderRight.item

    readonly property real textWidth: leftText ? leftText.width : 0
    readonly property real textHeight: leftText ? leftText.height : 0
    readonly property real scrollDistance: textWidth + root.spacing
    readonly property bool shouldScroll: textWidth > root.maxWidth

    width: Math.min(textWidth, root.maxWidth)
    height: textHeight
    clip: true

    Row {
        id: textStack
        spacing: root.spacing
        
        Loader {
            id: loaderLeft
            sourceComponent: root.textComponent
            Binding { target: loaderLeft.item; property: "text"; value: root.text.trim(); restoreMode: Binding.RestoreBinding }
        }

        Loader {
            id: loaderRight
            sourceComponent: root.textComponent
            active: scrollAnimation.running
            Binding { target: loaderRight.item; property: "text"; value: root.text.trim(); restoreMode: Binding.RestoreBinding }
        }
    }

    SequentialAnimation {
        id: scrollAnimation
        running: root.shouldScroll
        paused: root.paused
        loops: Animation.Infinite

        PropertyAction {
            target: textStack
            property: "x"
            value: root.scrollToRight ? -root.scrollDistance : 0
        }

        PauseAnimation {
            duration: root.moveFirst ? 0 : root.delayRepeat
        }

        NumberAnimation {
            target: textStack
            property: "x"
            from: root.scrollToRight ? -root.scrollDistance : 0
            to: root.scrollToRight ? 0 : -root.scrollDistance
            duration: root.scrollDistance * (root.moveSpeed / 100)
            easing.type: root.easingType
        }

        PauseAnimation {
            duration: root.moveFirst ? root.delayRepeat : 0
        }
    }

    onTextChanged: {
        if (scrollAnimation.running) {
            scrollAnimation.restart()
        }
    }
}