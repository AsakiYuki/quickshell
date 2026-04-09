import QtQuick
import Qt5Compat.GraphicalEffects

import "../components"
import "../base"

StyledListView {
    id: _root

    property var execute: index => {}

    Behavior on opacity {
        OpacityAnimator {
            duration: 180
            easing.type: Easing.OutQuart
        }
    }

    Behavior on scale {
        ScaleAnimator {
            duration: 180
            easing.type: Easing.OutQuart
        }
    }

    width: 180
    height: Math.min(count, 10) * 45

    model: [
        {
            icon: "",
            name: "Hello World!",
            description: "Hello World"
        },
    ]

    highlight: RadiusRectangle {
        width: _root.width
        color: Catppuccin.mantle
    }

    delegate: MouseArea {
        required property string name
        required property string description
        required property string icon
        required property int index

        cursorShape: Qt.PointingHandCursor

        width: _root.width
        height: 45

        onClicked: {
            if (_root.currentIndex === index)
                _root.execute(index);
            else
                _root.currentIndex = index;
        }

        Row {
            anchors.fill: parent

            Image {
                anchors.verticalCenter: parent.verticalCenter
                cache: true
                width: 30
                height: 30
                source: icon
                visible: icon !== ""

                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: 30
                        height: 30
                        radius: 5
                    }
                }
            }

            leftPadding: 15
            rightPadding: 15

            Column {
                leftPadding: (icon !== "") * 10
                anchors.verticalCenter: parent.verticalCenter

                StyledText {
                    text: name
                }

                StyledText {
                    text: description
                    color: Catppuccin.subtext0
                }
            }
        }
    }
}
