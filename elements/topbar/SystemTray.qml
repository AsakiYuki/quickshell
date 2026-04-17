import QtQuick

import Quickshell

import "../../base"
import "../../core"
import "../../components"

Rectangle{
  id: _root

  width: _tray.width + 15
  height: _tray.height + 10
  radius: height / 2
  
  anchors.verticalCenter: parent.verticalCenter
  
  property int offsetX: 0
  property int offsetY: 0 

  Row {
    id: _tray
    anchors.centerIn: parent
    
    Repeater {
      id: _repeater
      model: SystemTray.showTray.length
      
      readonly property int hideTrayBtnPos: overlay.width - 25 - 19.5

      Item {
        id: _trayitem
        
        required property int index
        property var modelData: SystemTray.showTray[index]
        
        readonly property int rightOffsetPosition: overlay.width - (_repeater.model - index) * 25 - 32.5

        width: 25
        height: 25

        QsMenuAnchor {
            id: menu
            menu: _trayitem.modelData.menu
            anchor.item: _trayitem
            anchor.margins.top: 35
            anchor.edges: Edges.Right
        }

        StyledButton {
          id: _btn
          anchors.fill: parent
          property bool isHold: false
          property int lastX: 0
          property int lastY: 0

          function getCurrentMousePosition(ev) {
            return [_trayitem.rightOffsetPosition + ev.x - _root.offsetX, ev.y + 12.5 - _root.offsetY]
          }

          normalColor: Catppuccin.surface0
          hoverColor: Catppuccin.surface1
          pressedColor: "transparent"

          Image {
            anchors.centerIn: parent
            source: modelData.icon
            width: 20
            height: 20
          }

          onMouseMoved: ev => {
            if (isHold) {
              const deltaX = lastX - ev.x
              const deltaY = lastY - ev.y

              if (Math.abs(deltaX) > 1.5 || Math.abs(deltaY) > 1.5) {
                _clickDelay.running = false;
                overlay.setDragIcon(modelData.icon)       
              }


              lastX = ev.x
              lastY = ev.y

              overlay.setOverlayPosition(...getCurrentMousePosition(ev))
            }
          }

          onRightClicked: {
            menu.open()
          }

          onPressed: ev => {
            if (ev.button === Qt.LeftButton) {
              lastX = _root.offsetX = ev.x
              lastY = _root.offsetY = ev.y
              _btn.isHold = true
              _clickDelay.start()
            }
          }

          onReleased: ev => {
            if (ev.button === Qt.LeftButton) {
              _btn.isHold = false
              overlay.setDragIcon("")
              if (_clickDelay.running) {
                _clickDelay.stop()
                modelData.activate()
              } else {
                const [x, y] = getCurrentMousePosition(ev)

                if ((_repeater.hideTrayBtnPos < x &&  (_repeater.hideTrayBtnPos + 25) > x) && (32.5 > y)) {
                  configuration.hideTrayID.push([modelData.id, modelData.tooltipTitle, modelData.title].join("&"))
                }
              }
            }
          }

          onMiddleClicked: modelData.secondaryActivate();

          Timer {
            id: _clickDelay
            running: false
            interval: 250
          }
        }
      }
    }
    
    StyledButton {
      id: _moreTrayButton

      width: 25
      height: 25
      normalColor: Catppuccin.surface0
      hoverColor: Catppuccin.surface1
      pressedColor: "transparent"

      ImageIcon {
        anchors.fill: parent
        rotation: SharedState.isMoreTrayOpened ? -90 : 90
        source: "../assets/icons/chevron_right.png"

        Behavior on rotation {
          NumberAnimation {
            duration: 200
            easing.type: Easing.OutQuint
          }
        }
      }

      onClicked: {
        SharedState.isMoreTrayOpened = !SharedState.isMoreTrayOpened;
      }
    }
  }

  color: Catppuccin.surface0
}