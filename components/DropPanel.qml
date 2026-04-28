import QtQuick

Item {
    id: root

    property Component backgroundComponent: RadiusRectangle {
        radius: 15
    }

    required property Component content
    property int viewPadding: 0

    property bool active: false
    property int verticalPadding: 0
    property int horizontalPadding: 0

    property int direction: 0

    property int viewX: 0
    property int viewY: 0

    property int activeIndex: 10
    property int inactiveIndex: 0

    property int openDuration: 400
    property int openEasingType: Easing.OutQuint
    property int closeDuration: 180
    property int closeEasingType: Easing.InSine

    height: bgLoader.height
    width: bgLoader.width

    x: viewX
    y: viewY
    z: active ? activeIndex : inactiveIndex

    MouseArea {
        anchors.fill: parent
    }

    Loader {
        id: bgLoader
        sourceComponent: root.backgroundComponent
        active: false

        Binding {
            target: bgLoader.item
            property: "width"
            value: contentLoader.width + root.horizontalPadding
            when: bgLoader.item !== null
        }

        Binding {
            target: bgLoader.item
            property: "height"
            value: contentLoader.height + root.verticalPadding
            when: bgLoader.item !== null
        }
    }

    Loader {
        id: contentLoader
        sourceComponent: root.content
        active: bgLoader.active
        parent: bgLoader.item ? bgLoader.item : root
        anchors.centerIn: parent
    }

    onActiveChanged: {
        if (active) {
            bgLoader.active = true;
            closeAnim.stop();
            openAnim.start();
        } else {
            openAnim.stop();
            closeAnim.start();
        }
    }

    NumberAnimation {
        id: openAnim
        target: root
        properties: "viewPadding"
        duration: root.openDuration
        easing.type: root.openEasingType
        from: (root.direction > 1) ? -root.width : -root.height
        to: (root.direction > 1) ? root.viewX : root.viewY
    }

    NumberAnimation {
        id: closeAnim
        target: root
        properties: "viewPadding"
        duration: root.closeDuration
        easing.type: root.closeEasingType
        from: (root.direction > 1) ? root.viewX : root.viewY
        to: (root.direction > 1) ? -root.width : -root.height
        onFinished: bgLoader.active = false
    }

    anchors.top: (direction === 0) ? parent.top : undefined
    anchors.topMargin: (direction === 0) * viewPadding

    anchors.bottom: (direction === 1) ? parent.bottom : undefined
    anchors.bottomMargin: (direction === 1) * viewPadding

    anchors.left: (direction === 2) ? parent.left : undefined
    anchors.leftMargin: (direction === 2) * viewPadding

    anchors.right: (direction === 3) ? parent.right : undefined
    anchors.rightMargin: (direction === 3) * viewPadding

    Component.onCompleted: bgLoader.active = root.active
}
