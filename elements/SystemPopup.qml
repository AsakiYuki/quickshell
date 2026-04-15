import QtQuick
import "../components"

Loader {
    id: _loader

    property string icon: ""
    property string notifyText: ""

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 250

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
            spacing: 20
            anchors.centerIn: parent

            Item {
                width: 30
                height: 30

                property string icon: _loader.icon
                onIconChanged: {
                    _firsticon.source = _secondicon.source;
                    _firsticon.opacity = 1;
                    _secondicon.opacity = 0;
                    _secondicon.source = `../assets/icons/${icon}`;
                    iconAnim.restart();
                }

                ParallelAnimation {
                    id: iconAnim

                    ScaleAnimator {
                        target: _firsticon
                        from: 1
                        to: 0.5
                        duration: 250
                        easing.type: Easing.OutQuart
                    }

                    OpacityAnimator {
                        target: _firsticon
                        from: 1
                        to: 0
                        duration: 200
                    }

                    ScaleAnimator {
                        target: _secondicon
                        from: 0.5
                        to: 1
                        duration: 350
                        easing.type: Easing.OutBack
                    }

                    OpacityAnimator {
                        target: _secondicon
                        from: 0
                        to: 1
                        duration: 250
                    }
                }

                Image {
                    id: _firsticon
                    anchors.fill: parent
                    source: ""
                }

                Image {
                    id: _secondicon
                    anchors.fill: parent
                    source: ""
                }
            }

            Item {
                anchors.verticalCenter: parent.verticalCenter
                width: _textStack.width
                height: _text.height
                clip: true

                property string notifyText: _loader.notifyText
                onNotifyTextChanged: {
                    _text.text = _text2.text;
                    _text2.text = notifyText;

                    _textStack.y = 0;
                    _textScrollAnim.restart();
                    _popup_timeout.restart();
                    if (exitAnim.running) {
                        exitAnim.running = false;
                        enterAnim.running = true;
                    }
                }

                YAnimator {
                    id: _textScrollAnim
                    target: _textStack
                    from: 0
                    to: -41
                    duration: 400
                    easing.type: Easing.OutBack
                }

                Column {
                    id: _textStack
                    width: _text2.width
                    spacing: 25

                    Behavior on width {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.OutExpo
                        }
                    }

                    StyledText {
                        id: _text
                        font.pixelSize: 15
                        font.weight: 1000
                        text: " "
                    }

                    StyledText {
                        id: _text2
                        font.pixelSize: 15
                        font.weight: 1000
                        text: " "
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
