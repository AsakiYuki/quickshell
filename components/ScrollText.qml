import QtQuick

Item {
    id: root

    property Component textComponent: StyledText {}
    property string text: ""

    property string textAlign: "left"

    property int viewWidth: 0
    property int viewHeight: 0
    property int moveSpeed: 500
    property int resizeSpeed: 350
    property int moveEasingType: Easing.OutQuint
    property int resizeEasingType: Easing.OutQuint

    property Item topText: loaderTop.item

    width: textStack.displayWidth
    height: textStack.displayHeight
    clip: true

    function mapAlign(value) {
        switch (value) {
        case "center":
            return Text.AlignHCenter;
        case "right":
            return Text.AlignRight;
        default:
            return Text.AlignLeft;
        }
    }

    onTextChanged: {
        loaderTop.text = loaderBottom.text;
        loaderBottom.text = text.trim();
        moveAnim.restart();
    }

    Behavior on width {
        NumberAnimation {
            duration: root.resizeSpeed
            easing.type: root.resizeEasingType
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

        width: Math.max(loaderTop.item?.implicitWidth || 0, loaderBottom.item?.implicitWidth || 0)

        height: displayHeight * 2

        readonly property int displayHeight: root.viewHeight || (loaderBottom.item?.implicitHeight || 0)
        readonly property int displayWidth: root.viewWidth || width

        Item {
            anchors.top: parent.top
            width: parent.width
            height: textStack.displayHeight
            clip: true

            Loader {
                id: loaderTop
                anchors.fill: parent
                property string text: ""
                sourceComponent: root.textComponent

                Binding {
                    target: loaderTop.item
                    property: "text"
                    value: loaderTop.text
                }

                Binding {
                    target: loaderTop.item
                    property: "horizontalAlignment"
                    value: root.mapAlign(root.textAlign)
                }

                Binding {
                    target: loaderTop.item
                    property: "width"
                    value: loaderTop.width
                }
            }
        }

        Item {
            anchors.bottom: parent.bottom
            width: parent.width
            height: textStack.displayHeight
            clip: true

            Loader {
                id: loaderBottom
                anchors.fill: parent
                property string text: ""
                sourceComponent: root.textComponent

                Binding {
                    target: loaderBottom.item
                    property: "text"
                    value: loaderBottom.text
                }

                Binding {
                    target: loaderBottom.item
                    property: "horizontalAlignment"
                    value: root.mapAlign(root.textAlign)
                }

                Binding {
                    target: loaderBottom.item
                    property: "width"
                    value: loaderBottom.width
                }
            }
        }
    }
}
