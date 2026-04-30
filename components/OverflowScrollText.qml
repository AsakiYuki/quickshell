import QtQuick

Item {
    id: root

    property Component textComponent: StyledText { } 
    property string text: "Hello Overflow Scrolltext"
    
    property bool scrollToRight: false
    property bool moveFirst: false
    property bool paused: false

    property int spacing: 50
    property int maxWidth: 200
    property int delayRepeat: 1500
    property int durationPerPixel: 25
    property int easingType: Easing.InOutSine 

    onPausedChanged: {
        if (!shouldScroll) return
        if (paused) scrollAnimation.pause()
        else scrollAnimation.resume() 
    }

    property Item loaderText: loaderTextViewer.item

    readonly property real textWidth: loaderText ? loaderText.implicitWidth : 0
    readonly property real textHeight: loaderText ? loaderText.implicitHeight : 0
    readonly property real scrollDistance: textWidth + root.spacing
    readonly property bool shouldScroll: textWidth > root.maxWidth

    width: Math.min(textWidth, root.maxWidth)
    height: textHeight
    clip: true

    Row {
        id: textStack
        spacing: root.spacing
        
        Loader {
            id: loaderTextViewer
            sourceComponent: root.textComponent
            onLoaded: item.text = root.text.trim()
        }

        ShaderEffectSource {
            live: false
            recursive: true
            id: textShader
            width: loaderTextViewer.item?.implicitWidth
            height: loaderTextViewer.item?.implicitHeight
            sourceItem: loaderTextViewer.item
        }
    }

    SequentialAnimation {
        id: scrollAnimation
        running: root.shouldScroll
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
            duration: root.scrollDistance * root.durationPerPixel
            easing.type: root.easingType
        }

        PauseAnimation {
            duration: root.moveFirst ? root.delayRepeat : 0
        }
    }

    onTextChanged: {
        textStack.x = 0;
        if (loaderText) loaderText.text = text.trim();
        if (scrollAnimation.running) {
            scrollAnimation.restart();
            textShader.scheduleUpdate();
        }
    }
}