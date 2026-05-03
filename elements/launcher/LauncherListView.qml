import QtQuick
import Qt5Compat.GraphicalEffects
import "../../components"
import "../../base"

Item {
    id: _root

    property list<var> model: []
    property int maxView: 10
    property int viewIndex: 0

    onViewIndexChanged: {
        const c = Math.max(0, Math.min(viewIndex, model.length - maxView));
        if (viewIndex !== c) viewIndex = c;
    }

    anchors.horizontalCenter: parent.horizontalCenter
    width: parent.width - 40
    height: Math.min(_list.height, 55 * maxView)
    clip: true

    Column {
        id: _list
        width: parent.width
        y: _root.viewIndex * -55

        Behavior on y {
            NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
        }

        Repeater {
            model: _root.model

            Item {
                id: _item
                required property int index
                required property var modelData

                width: _root.width
                height: 55

                Row {
                    anchors.fill: parent
                    spacing: 10

                    Image {
                        anchors.verticalCenter: parent.verticalCenter
                        height: _item.height - 20
                        width: height
                        source: _item.modelData.icon ?? ""
                        visible: _item.modelData.icon !== undefined
                        asynchronous: true
                        fillMode: Image.PreserveAspectCrop
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - (_item.modelData.icon !== undefined ? _item.height : 0)

                        StyledText {
                            text: _item.modelData.text
                            width: parent.width
                            elide: Text.ElideRight
                        }

                        StyledText {
                            text: _item.modelData.subtext
                            visible: text !== ""
                            color: Catppuccin.subtext0
                            width: parent.width
                            maximumLineCount: 1
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }
    }
}