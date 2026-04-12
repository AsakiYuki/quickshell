import QtQuick
import Qt5Compat.GraphicalEffects

import "../../components"
import "../../base"

Item {
    id: _root

    // <text> <subtext> [icon]
    property list<var> model: []
    property int maxView: 10
    property int viewIndex: 0

    onViewIndexChanged: {
        viewIndex = Math.min(Math.max(viewIndex, 0), model.length - maxView);
    }

    anchors.horizontalCenter: parent.horizontalCenter

    width: parent.width - 40
    height: Math.min(_list.height, 55 * maxView)

    clip: true

    Column {
        id: _list

        y: _root.viewIndex * -55

        Behavior on y {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }

        width: parent.width

        Repeater {
            model: _root.model

            Item {
                id: _item
                width: _root.width
                height: 55

                required property int index

                Row {
                    anchors.fill: parent
                    spacing: 10

                    Image {
                        anchors.verticalCenter: parent.verticalCenter

                        height: _item.height - 20
                        width: height
                        source: _root.model[_item.index].icon
                        visible: (_root.model[_item.index].icon !== undefined)
                        asynchronous: true

                        fillMode: Image.PreserveAspectCrop
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - (_root.model[_item.index].icon !== undefined) * _item.height

                        StyledText {
                            text: _root.model[_item.index].text
                            width: parent.width
                            elide: Text.ElideRight
                        }

                        StyledText {
                            text: _root.model[_item.index].subtext
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
