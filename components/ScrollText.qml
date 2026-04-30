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

    property Item topText: loaderTop.item

    width: displayWidth
    height: displayHeight
    clip: true

    onTextChanged: {
        loaderBottom.text = text.trim();
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
        from: 0
        to: -root.height
        target: textStack
        properties: "y"

        onFinished: {
            loaderTop.width = loaderBottom.width
            loaderTop.height = loaderBottom.height
            loaderTop.item?.scheduleUpdate()
            if (loaderTop?.item.onUpdate) loaderTop.item.onUpdate()
            textStack.y = 0;
        }
    }

    Item {
        id: textStack

        height: displayHeight * 2

        readonly property int displayHeight: root.viewHeight || loaderBottom.item?.height || 0
        readonly property int displayWidth: root.viewWidth || loaderBottom.item?.width || 0

        Item {
            width: loaderTop.item?.width || 0
            height: textStack.displayHeight
            anchors.top: parent.top
            clip: true

            Loader {
                id: loaderTop
                anchors.centerIn: parent
                sourceComponent: root.shaderComponent
                onLoaded: {
                    item.sourceItem = loaderBottom;
                    item.live = false;
                    if (item.onUpdate) item.onUpdate();
                }
            }
        }

        Item {
            width: loaderBottom.item?.width || 0
            height: textStack.displayHeight
            anchors.bottom: parent.bottom
            clip: true

            Loader {
                id: loaderBottom
                property string text: ""
                anchors.centerIn: parent
                sourceComponent: root.textComponent
                onTextChanged: if (item) item.text = text;
                onLoaded: item.text = text;
            }
        }
    }
}
