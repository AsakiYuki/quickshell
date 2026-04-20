import QtQuick

import Quickshell

import "../utils/Utils.js" as Utils

import "../components"
import "../base"
import "../core"

DropPanel {
  id: root
  active: SharedState.overlayDropPanelType === 2

  anchors.right: parent.right
  anchors.rightMargin: 5
  viewY: 5

  content: Grid {
    id: _grid
    columns: 5
    padding: 10
    
    Repeater {
      id: _repeater
      model: SystemTray.hideTray.length

      Item {
        id: _trayitem
        required property int index;
        readonly property var modelData: SystemTray.hideTray[index];

        width: 30
        height: 30

        QsMenuAnchor {
            id: menu
            menu: _trayitem.modelData.menu
            anchor.item: _trayitem
            anchor.margins.top: 35
            anchor.edges: Edges.Right
            onClosed: SharedState.overlayDropPanelType = 0
        }

        StyledButton {
          anchors.fill: parent

          property int offsetX;
          property int offsetY;
          property bool trayDrag: false;

          function setDragIcon(icon) {
            overlay.setDragIcon(icon)
          }

          normalColor: Catppuccin.base
          hoverColor: Catppuccin.surface1
          pressedColor: "transparent"

          onDrag: (ev, delta) => {
            if (Math.abs(delta.x) > 1.5 || Math.abs(delta.y) > 1.5) {
              setDragIcon(modelData.icon)
              trayDrag = true;
            }

            const {x, y} = this.mapToGlobal(ev.x, ev.y)
            overlay.setOverlayPosition(x - offsetX, y - offsetY)
          }

          onRightClicked: {
            menu.open()
          }

          onPressed: ev => {
            offsetX = ev.x
            offsetY = ev.y
          }

          onReleased: ev => {
            if (ev.button === Qt.LeftButton) {
              overlay.setDragIcon("");
              
              if (trayDrag) {
                trayDrag = false;
                const {x, y} = this.mapToGlobal(ev.x, ev.y)
                if (!Workspaces.current.hasFullscreen && Utils.isMouseInsideTargetElement(x, y, 0, 0, topbar.systemTrayElement)) {
                  const hideTrayItems = configuration.hideTrayID.filter(v => v !== [modelData.id, modelData.tooltipTitle, modelData.title].join("&"))
                  configuration.hideTrayID = hideTrayItems
                }
              } else {
                modelData.activate()
                SharedState.overlayDropPanelType = 0
              }
            }
          }

          Image {
            anchors.centerIn: parent
            source: modelData.icon
            mipmap: true
            width: 20
            height: 20
          }
        }
      }
    }
  }
}