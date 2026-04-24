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

  property int direction: 0

  function hiddenY() {
    if (direction === 0) {
      return -root.height;
    } else {
      return parent ? parent.height : root.viewY + root.height;
    }
  }

  function showY() {
    if (direction === 0) {
      return root.viewY;
    } else {
      return parent
        ? parent.height - root.height - root.verticalPadding - root.viewY
        : root.viewY;
    }
  }

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
      openAnim.start();
      closeAnim.stop();
    } else {
      openAnim.stop();
      closeAnim.start();
    }
  }

  NumberAnimation {
    id: openAnim
    target: root
    properties: "y"
    duration: 400
    easing.type: Easing.OutQuint
    from: root.hiddenY()
    to: root.showY()
  }

  NumberAnimation {
    id: closeAnim
    target: root
    properties: "y"
    duration: 400
    easing.type: Easing.OutQuint
    from: root.showY()
    to: root.hiddenY()
    onFinished: bgLoader.active = false
  }

  onHeightChanged: y = showY()

  Component.onCompleted: bgLoader.active = root.active
}