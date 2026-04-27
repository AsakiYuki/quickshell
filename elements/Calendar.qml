import QtQuick

import "../core"
import "../components"

DropPanel {
  id: root
  
  active: SharedState.overlayDropPanelType === 5;
  anchors.horizontalCenter: parent.horizontalCenter
  viewY: 5
  
  content: Item {
    id: rootContent

    function isLeap(year) {
      return !(year % 4) && Boolean(year % 100)
    }

    function getMonthDays(month, year) {
      switch (month) {
        case 2: return 28 + rootContent.isLeap(year)
        case 1: case 3: case 5: case 7: case 10: case 12: return 31;
        case 4: case 6: case 8: case 9: case 11: return 30;
        default: return 0; 
      }
    }

    width: 500
    height: 500
  }
}