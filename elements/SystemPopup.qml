import QtQuick

import "../components"

Loader {
    id: _loader

    property string icon: ""
    property string notifyText: ""

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 250
    
    property bool isFirstLoad: true

    readonly property bool touchpad: configuration.touchpad
    onTouchpadChanged: {
        if (touchpad)
            setPopup("touchpad_mouse.png", "Touchpad enabled");
        else
            setPopup("touchpad_mouse_off.png", "Touchpad disabled");
    }

    readonly property bool capslock: configuration.capsLock
    onCapslockChanged: {
        if (capslock)
            setPopup("shift_lock.png", "Caps Lock is on");
        else
            setPopup("shift_lock_off.png", "Caps Lock is off");
    }

    readonly property bool hdr: configuration.hdr
    onHdrChanged: {
        if (hdr)
            setPopup("hdr_on.png", "HDR is on");
        else
            setPopup("hdr_off.png", "HDR is off");
    }

    function setPopup(_icon, _message) {
        if (isFirstLoad) {
            isFirstLoad = false;
            return;
        }

        icon = _icon;
        notifyText = _message;
        active = true;
    }

    Timer {
        running: true
        interval: 50
        onTriggered: {
            _loader.isFirstLoad = false;
        }
    }

    active: false
    sourceComponent: RadiusRectangle {
        id: _root
        clip: true

        width: _notification_panel.width + 60
        height: 50

        Behavior on width {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutExpo
            }
        }

        Row {
            id: _notification_panel
            spacing: 15
            anchors.centerIn: parent

            Item {
                width: 30
                height: 30

                SwitchImageIcon {
                    anchors.fill: parent
                    source: `../assets/icons/${_loader.icon}`;
                }
            }

            Item {
                anchors.verticalCenter: parent.verticalCenter
                width: _text.width
                height: _text.height
                clip: true

                ScrollText {
                    id: _text
                    text: _loader.notifyText

                    textComponent: StyledText {
                        font.pixelSize: 16
                        font.weight: 500
                    }
                }
            }
        }

        ParallelAnimation {
            id: enterAnim
            running: true

            YAnimator {
                target: _root
                from: 25
                to: 0
                duration: 400
                easing.type: Easing.OutExpo
            }

            OpacityAnimator {
                target: _root
                from: 0
                to: 1
                duration: 300
            }
        }

        ParallelAnimation {
            id: exitAnim

            YAnimator {
                target: _root
                from: 0
                to: 25
                duration: 300
                easing.type: Easing.InCubic
            }

            OpacityAnimator {
                target: _root
                from: 1
                to: 0
                duration: 300
            }

            onFinished: {
                _loader.active = false;
            }
        }

        Timer {
            id: _popup_timeout
            interval: 2500
            running: true
            onTriggered: {
                exitAnim.start();
            }
        }
    }
}
