import QtQuick

Item {
  id: root

  property Component backgroundComponent: RadiusRectangle {}
  required property Component content;
  
  property bool active: false
  property int verticalPadding: 50
  property int horizontalPadding: 50

  Loader {
    id: bgLoader
    sourceComponent: root.backgroundComponent
    active: root.active

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
}