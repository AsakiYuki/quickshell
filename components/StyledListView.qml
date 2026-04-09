import QtQuick

ListView {
    id: _root
    clip: true

    maximumFlickVelocity: 3000
    highlightMoveDuration: 150
    highlightMoveVelocity: -1

    rebound: Transition {
        NumberAnimation {
            duration: 500
            easing.type: Easing.BezierSpline
        }
    }
}
