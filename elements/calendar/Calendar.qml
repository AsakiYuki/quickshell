import QtQuick

import "../../core"
import "../../components"

DropPanel {
  id: root
  
  active: SharedState.overlayDropPanelType === 4;
  anchors.horizontalCenter: parent.horizontalCenter
  viewY: 5
  
  content: Item {
    id: rootContent

    readonly property var date: new Date()
    
    function nextMonth() {
      const next = viewMonth + 1;
      if (next > 11) {
        viewYear++;
        viewMonth = 0;
      } else viewMonth = next;
    }

    function prevMonth() {
      const prev = viewMonth - 1;
      if (prev < 0) {
        viewYear--;
        viewMonth = 11;
      } else viewMonth = prev;
    }

    property int viewMonth: date.getMonth()
    property int viewYear: date.getFullYear()
    property int viewDay: date.getDate()

    width: container.width + 50
    height: container.height + 50

    Behavior on height { NumberAnimation { duration: 350; easing.type: Easing.OutExpo } }

    Column {
      id: container
      anchors.top: parent.top
      anchors.topMargin: 30
      anchors.horizontalCenter: parent.horizontalCenter

      Item {
        width: parent.width
        height: 35

        SimpleButton {
          width: 30
          height: 30
          radius: 5
          anchors.left: parent.left
          anchors.leftMargin: 10
          onClicked: rootContent.prevMonth()

          ImageIcon {
            width: 25
            height: 25
            anchors.centerIn: parent
            source: "../assets/icons/chevron_left.png"
          }
        }

        SimpleButton {
          width: 30
          height: 30
          radius: 5
          anchors.right: parent.right
          anchors.rightMargin: 10
          onClicked: rootContent.nextMonth()

          ImageIcon {
            width: 25
            height: 25
            anchors.centerIn: parent
            source: "../assets/icons/chevron_right.png"
          }
        }

        StyledText {
          anchors.centerIn: parent
          anchors.verticalCenterOffset: -5
          font.weight: 1e3
          font.pixelSize: 18
          text: {
            return `${[ "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" ][rootContent.viewMonth]} ${rootContent.viewYear}`
          }
        }
      }

      Row {
        spacing: 5
        Repeater {
          model: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

          Item {
            required property string modelData;
            width: 70
            height: 50

            StyledText {
              anchors.centerIn: parent
              text: parent.modelData;
              font.pixelSize: 15
              font.weight: 1e3
            }
          }
        }
      }

      CalendarMonthView {
        viewMonth: rootContent.viewMonth
        viewYear: rootContent.viewYear
      }
    }
  }
}