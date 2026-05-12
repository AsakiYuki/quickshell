import QtQuick

Item {
    id: root

    property Component textComponent: StyledText {}
    property Component shaderComponent: ShaderEffectSource {}

    property string text: ""

    readonly property int displayWidth: textStack.displayWidth
    readonly property int displayHeight: textStack.displayHeight

    property int viewWidth: 0
    property int viewHeight: 0
    property int moveSpeed: 350
    property int resizeSpeed: 350
    property int moveEasingType: Easing.OutQuint
    property int resizeEasingType: Easing.OutQuint
    property bool isBottomToTop: false

    property Item topText: sourceText.item

    width: displayWidth
    height: displayHeight
    clip: true

    onTextChanged: {
        if (moveAnim.running) {
            sourceText.width = captureText.width
            sourceText.height = captureText.height
            sourceText?.item.scheduleUpdate()
        }
        captureText.text = text.trim();
        moveAnim.restart();
    }

    Behavior on width {
        NumberAnimation {
            easing.type: root.resizeEasingType
            duration: root.resizeSpeed
        }
    }

    NumberAnimation {
        id: moveAnim
        duration: root.moveSpeed
        easing.type: root.moveEasingType
        from: root.isBottomToTop ? -root.height : 0
        to: root.isBottomToTop ? 0 : -root.height
        target: textStack
        properties: "y"

        onFinished: {
            sourceText.width = captureText.width
            sourceText.height = captureText.height
            sourceText.item?.scheduleUpdate()
            if (sourceText?.item.onUpdate) sourceText.item.onUpdate()
            textStack.y = 0;
        }
    }

    Item {
        id: textStack

        height: displayHeight * 2

        readonly property int displayHeight: root.viewHeight || captureText.item?.height || 0
        readonly property int displayWidth: root.viewWidth || captureText.item?.width || 0

        Item {
            width: sourceText.item?.width || 0
            height: textStack.displayHeight
            anchors.bottom: root.isBottomToTop ? parent.bottom : undefined
            anchors.top: root.isBottomToTop ? undefined : parent.top
            clip: true

            Loader {
                id: sourceText
                anchors.centerIn: parent
                sourceComponent: root.shaderComponent
                onLoaded: {
                    item.sourceItem = captureText.item;
                    item.live = false;
                    if (item.onUpdate) item.onUpdate();
                }
            }
        }

        Item {
            width: captureText.item?.width || 0
            height: textStack.displayHeight
            anchors.bottom: root.isBottomToTop ? undefined : parent.bottom
            anchors.top: root.isBottomToTop ? parent.top : undefined
            clip: true

            Loader {
                id: captureText
                property string text: ""
                anchors.centerIn: parent
                sourceComponent: root.textComponent
                onTextChanged: if (item) item.text = text;
                onLoaded: item.text = text;
            }
        }
    }
}
