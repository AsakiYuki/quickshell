import QtQuick

Item {
    id: root

    property Component textComponent: StyledText {
        property bool isBottomText
    }
    property string text: ""

    property int viewWidth: 0
    property int viewHeight: 0
    property int moveSpeed: 350
    property int resizeSpeed: 350
    property int moveEasingType: Easing.OutQuint
    property int resizeEasingType: Easing.OutQuint

    property Item topText: loaderTop.item

    width: textStack.displayWidth
    height: textStack.displayHeight
    clip: true

    onTextChanged: {
        loaderTop.text = loaderBottom.text;
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
            loaderTop.text = loaderBottom.text;
            textStack.y = 0;
        }
    }

    Item {
        id: textStack

        width: Math.max(loaderTop.item?.height || 0, loaderBottom.item?.height || 0)
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
                property string text: ""
                anchors.centerIn: parent
                sourceComponent: root.textComponent

                Binding {
                    target: loaderTop.item
                    property: "text"
                    value: loaderTop.text
                }

                Binding {
                    target: loaderTop.item
                    property: "isBottomText"
                    value: false
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

                Binding {
                    target: loaderBottom.item
                    property: "text"
                    value: loaderBottom.text
                }

                Binding {
                    target: loaderBottom.item
                    property: "isBottomText"
                    value: true
                }
            }
        }
    }
}
