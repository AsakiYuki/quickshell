import QtQuick

Item {
  id: root
  
  property Component textComponent: StyledText { }
  property string text: ""

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

  onTextChanged: {
    loaderTop.text = loaderBottom.text
    loaderBottom.text = text
    moveAnim.restart()
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
      loaderTop.text = loaderBottom.text
      textStack.y = 0
    }
  }

  Column {
    id: textStack

    readonly property int displayHeight: root.viewHeight || Math.max(loaderTop.item?.height || 0, loaderBottom.item?.height || 0)
    readonly property int displayWidth: root.viewWidth || loaderBottom.item?.width || 0

    Item {
      width: loaderTop.item?.width || 0
      height: textStack.displayHeight
      clip: true

      Loader {
        id: loaderTop
        anchors.centerIn: parent
        property string text: ""
        sourceComponent: root.textComponent
        Binding { target: loaderTop.item; property: "text"; value: loaderTop.text || " "; restoreMode: Binding.RestoreBinding }
      }
    }

    Item {
      width: loaderBottom.item?.width || 0
      height: textStack.displayHeight
      clip: true

      Loader {
        id: loaderBottom
        anchors.centerIn: parent
        property string text: ""
        sourceComponent: root.textComponent
        Binding { target: loaderBottom.item; property: "text"; value: loaderBottom.text || " "; restoreMode: Binding.RestoreBinding }
      }
    }
  }
}