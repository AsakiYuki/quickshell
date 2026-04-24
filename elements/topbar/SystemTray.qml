import QtQuick

import Quickshell

import "../../utils/Utils.js" as Utils

import "../../base"
import "../../core"
import "../../components"

Rectangle{
  id: _root

  width: _tray.width + 15
  height: _tray.height + 10
  radius: height / 2
  clip: true
  
  anchors.verticalCenter: parent.verticalCenter
  
  property int offsetX: 0
  property int offsetY: 0

  property bool isTrayDragging: false

  visible: SystemTray.systemTray.length

  Behavior on width {
    NumberAnimation {
      duration: 200
      easing.type: Easing.OutQuint
    }
  }

  Row {
    id: _tray
    anchors.verticalCenter: parent.verticalCenter
    anchors.right: parent.right
    anchors.rightMargin: 7
    
    Repeater {
      id: _repeater
      model: SystemTray.showTray.length

      Item {
        id: _trayitem
        
        required property int index
        property var modelData: SystemTray.showTray[index]

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

          normalColor: Catppuccin.surface0
          hoverColor: Catppuccin.surface1
          pressedColor: "transparent"

          Image {
            anchors.centerIn: parent
            source: modelData.icon
            mipmap: true
            width: 20
            height: 20
          }

          onDrag: (ev, delta) => {
            if (Math.abs(delta.x) > 1.5 || Math.abs(delta.y) > 1.5) {
              _root.isTrayDragging = true;
              overlay.setDragIcon(`0${modelData.icon}`)
            }

            const {x, y} = this.mapToGlobal(ev.x, ev.y)
            overlay.setOverlayPosition(x - _root.offsetX, y - _root.offsetY)
          }

          onRightClicked: {
            menu.open()
          }

          onPressed: ev => {
            if (ev.button === Qt.LeftButton) {
              _root.offsetX = ev.x
              _root.offsetY = ev.y
            }
          }

          onReleased: ev => {
            if (ev.button === Qt.LeftButton) {
              overlay.setDragIcon("")
              if (_root.isTrayDragging) {
                _root.isTrayDragging = false;
                const {x, y} = this.mapToGlobal(ev.x, ev.y)
                if (Utils.isMouseInsideTargetElement(x, y, 0, 0, _moreTrayButton)) {
                  configuration.hideTrayID.push([modelData.id, modelData.tooltipTitle, modelData.title].join("&"))
                }
              } else {
                modelData.activate()
              }
            }
          }

          onMiddleClicked: modelData.secondaryActivate();
        }
      }
    }
    
    StyledButton {
      id: _moreTrayButton

      property int readX: mapToGlobal(x, y).x; 
      property int readY: mapToGlobal(x, y).y; 

      width: 25
      height: 25
      normalColor: Catppuccin.surface0
      hoverColor: Catppuccin.surface1
      pressedColor: "transparent"

      visible: SystemTray.hideTray.length || _root.isTrayDragging

      ImageIcon {
        anchors.fill: parent
        rotation: (SharedState.overlayDropPanelType === 2) ? -90 : 90
        source: "../assets/icons/chevron_right.png"

        Behavior on rotation {
          NumberAnimation {
            duration: 200
            easing.type: Easing.OutQuint
          }
        }
      }

      onClicked: SharedState.toggleOverlay(2);
    }
  }

  color: Catppuccin.surface0

  Component.onCompleted: {
    topbar.systemTrayElement = this;
  }
}