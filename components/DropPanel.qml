import QtQuick

Item {
  id: root

  property Component backgroundComponent: RadiusRectangle {
    radius: 15
  }

  required property Component content;
  property int viewPadding: 0
  
  property bool active: false
  property int verticalPadding: 0
  property int horizontalPadding: 0

  property int direction: 0

  property int viewX: 0
  property int viewY: 0

  height: bgLoader.height
  width: bgLoader.width

  x: viewX
  y: viewY
  z: active ? 10 : 0

  MouseArea {
    anchors.fill: parent
  }

  Loader {
    id: bgLoader
    sourceComponent: root.backgroundComponent
    active: false

    Binding {
      target: bgLoader.item
      property: "children"
      value: Loader {
        id: contentLoader
        active: bgLoader.active
        anchors.centerIn: parent
        sourceComponent: root.content
      }
    }

    Binding {
      target: bgLoader.item
      property: "width"
      value: (bgLoader.item?.children[0].width || 0) + root.horizontalPadding
    }

    Binding {
      target: bgLoader.item
      property: "height"
      value: (bgLoader.item?.children[0].height || 0) + root.verticalPadding
    }
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
    duration: 400
    easing.type: Easing.OutQuint
    from: -root.height
    to: root.viewY
  }

  NumberAnimation {
    id: closeAnim
    target: root
    properties: "viewPadding"
    duration: 200
    easing.type: Easing.InSine
    from: root.viewY
    to: -root.height
    onFinished: bgLoader.active = false
  }

  anchors.bottom: direction ? parent.bottom : null
  anchors.bottomMargin: direction * viewPadding

  anchors.top: direction ? null : parent.top
  anchors.topMargin: (!direction) * viewPadding

  Component.onCompleted: bgLoader.active = root.active
}