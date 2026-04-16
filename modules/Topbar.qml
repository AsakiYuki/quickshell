pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes

import Quickshell
import Quickshell.Wayland

import "../components"
import "../base"
import "../elements/topbar"

Variants {
    id: _root

    model: Quickshell.screens

    Scope {
        id: _scope
        required property ShellScreen modelData

        StyledWindow {
            id: _topbar
            name: "topbar"

            anchors.top: true
            anchors.left: true
            anchors.right: true

            margins.bottom: -15

            implicitHeight: 60
            focusable: true

            Shape {
                id: _shape
                anchors.fill: parent

                width: parent.width
                height: parent.height
                antialiasing: true

                ShapePath {
                    strokeWidth: 0
                    fillColor: Catppuccin.base

                    startX: 0
                    startY: 0

                    PathLine {
                        x: _shape.width
                        y: 0
                    }

                    PathLine {
                        x: _shape.width
                        y: _shape.height
                    }

                    PathCubic {
                        x: _shape.width - 15
                        y: _shape.height - 15

                        control1X: _shape.width
                        control1Y: _shape.height - 5

                        control2X: _shape.width - 5
                        control2Y: _shape.height - 15
                    }

                    PathLine {
                        x: 15
                        y: _shape.height - 15
                    }

                    PathCubic {
                        x: 0
                        y: _shape.height
                        control1X: 5
                        control1Y: _shape.height - 15
                        control2X: 0
                        control2Y: _shape.height - 5
                    }

                    PathLine {
                        x: 0
                        y: 0
                    }
                }

                Item {
                    width: parent.width
                    height: parent.height - 15
                    anchors.top: parent.top
                    anchors.left: parent.left

                    Container {}
                }
            }

            Shape {
                anchors.fill: parent
                antialiasing: true

                ShapePath {
                    strokeWidth: 2
                    strokeColor: Catppuccin.surface0
                    fillColor: "transparent"

                    capStyle: ShapePath.RoundCap
                    joinStyle: ShapePath.RoundJoin

                    startX: _shape.width
                    startY: _shape.height

                    PathCubic {
                        x: _shape.width - 15
                        y: _shape.height - 15

                        control1X: _shape.width
                        control1Y: _shape.height - 5

                        control2X: _shape.width - 5
                        control2Y: _shape.height - 15
                    }

                    PathLine {
                        x: 15
                        y: _shape.height - 15
                    }

                    PathCubic {
                        x: 0
                        y: _shape.height

                        control1X: 5
                        control1Y: _shape.height - 15

                        control2X: 0
                        control2Y: _shape.height - 5
                    }
                }
            }
        }
    }
}
