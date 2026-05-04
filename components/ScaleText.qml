import QtQuick

Item {
    id: root

    property Component textComponent: StyledText {}
    property string text: ""

    property string textAlign: "left"

    property int viewWidth: 0
    property int viewHeight: 0

    property int transitionSpeed: 350
    property int resizeSpeed: 300
    property int transitionEasingType: Easing.OutQuint
    property int resizeEasingType: Easing.OutQuint

    property Item topText: loaderOld.item

    readonly property int displayWidth: root.viewWidth || Math.max(loaderOld.item?.implicitWidth || 0, loaderNew.item?.implicitWidth || 0)
    readonly property int displayHeight: root.viewHeight || Math.max(loaderOld.item?.implicitHeight || 0, loaderNew.item?.implicitHeight || 0)

    width: displayWidth
    height: displayHeight
    clip: true

    function mapAlign(value) {
        switch (value) {
            case "center": return Text.AlignHCenter;
            case "right": return Text.AlignRight;
            default: return Text.AlignLeft;
        }
    }

    onTextChanged: {
        if (loaderNew.text === "") {
            loaderNew.text = text.trim();
            loaderOld.text = text.trim();
            loaderNew.opacity = 1;
            loaderOld.opacity = 0;
        } else {
            loaderOld.text = loaderNew.text;
            loaderNew.text = text.trim();
            transitionAnim.restart();
        }
    }

    Behavior on width {
        NumberAnimation {
            duration: root.resizeSpeed
            easing.type: root.resizeEasingType
        }
    }

    ParallelAnimation {
        id: transitionAnim

        NumberAnimation { target: loaderOld; property: "opacity"; from: 1.0; to: 0; duration: root.transitionSpeed; easing.type: root.transitionEasingType; }
        NumberAnimation { target: loaderOld; property: "scale"; from: 1.0; to: 0.5; duration: root.transitionSpeed; easing.type: root.transitionEasingType; }
        NumberAnimation { target: loaderNew; property: "opacity"; from: 0.0; to: 1.0; duration: root.transitionSpeed; easing.type: root.transitionEasingType; }
        NumberAnimation { target: loaderNew; property: "scale"; from: 0.5; to: 1.0; duration: root.transitionSpeed; easing.type: root.transitionEasingType; }

        onFinished: {
            loaderOld.text = loaderNew.text;
            loaderOld.opacity = 0.0;
            loaderNew.opacity = 1.0;
            loaderOld.scale = 1.0;
            loaderNew.scale = 1.0;
        }
    }

    Loader {
        id: loaderOld
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
        opacity: 0
        property string text: ""
        sourceComponent: root.textComponent

        Binding { target: loaderOld.item; property: "text"; value: loaderOld.text }
        Binding { target: loaderOld.item; property: "horizontalAlignment"; value: root.mapAlign(root.textAlign) }
        Binding { target: loaderOld.item; property: "width"; value: loaderOld.width }
    }

    Loader {
        id: loaderNew
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
        opacity: 1
        property string text: ""
        sourceComponent: root.textComponent

        Binding { target: loaderNew.item; property: "text"; value: loaderNew.text }
        Binding { target: loaderNew.item; property: "horizontalAlignment"; value: root.mapAlign(root.textAlign) }
        Binding { target: loaderNew.item; property: "width"; value: loaderNew.width }
    }
}
