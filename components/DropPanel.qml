import QtQuick

Item {
  id: root

  property Component backgroundComponent: RadiusRectangle {
    radius: 15
  }
  required property Component content;
  
  property bool active: false
  property int verticalPadding: 0
  property int horizontalPadding: 0

  property int viewX: 0
  property int viewY: 0

  height: bgLoader.height
  width: bgLoader.width

  x: viewX
  y: viewY

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
      openAnim.start();
    } else closeAnim.start();
  }

  NumberAnimation {
    id: openAnim
    target: root
    properties: "y"
    duration: 350
    easing.type: Easing.OutQuint
    from: -root.height - 10
    to: root.viewY
  }

  NumberAnimation {
    id: closeAnim
    target: root
    properties: "y"
    duration: 350
    easing.type: Easing.OutQuint
    from: root.viewY
    to: -root.height - 10
    onFinished: bgLoader.active = false
  }

  Component.onCompleted: bgLoader.active = root.active
}