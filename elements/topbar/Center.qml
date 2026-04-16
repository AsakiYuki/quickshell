import QtQuick

Row {
    height: parent.height
    width: _clock.width
    anchors.centerIn: parent

    Clock {
        id: _clock
    }
}
