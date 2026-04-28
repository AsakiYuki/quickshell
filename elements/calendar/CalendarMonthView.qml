import QtQuick

import "../../components"
import "../../base"

import "../../utils/Color.js" as ColorUtils
import "../../utils/DateUtils.js" as DateUtils
import "./CalendarUtils.js" as CalendarUtils

Grid {
  id: root
  columns: 7

  property int currentMonth: new Date().getMonth()
  property int currentDay: new Date().getDate()

  property int viewMonth: 0
  property int viewYear: 0

  spacing: 5

  Repeater {
    model: CalendarUtils.getDaysArray(root.viewMonth + 1, root.viewYear)

    SimpleButton {
      radius: 5

      id: day
      required property var modelData;

      readonly property var lunar: new DateUtils.SolarDate(modelData.date).toLunarDate().get();
      readonly property bool isCurrentDay: (day.modelData.month === root.currentMonth + 1) && (day.modelData.day === root.currentDay)
      
      normalColor: isCurrentDay ? Catppuccin.lavender : ColorUtils.lighten(Catppuccin.base, 3)

      width: 70
      height: width
      
      Column {
        anchors.centerIn: parent
        
        StyledText {
          text: day.modelData.day
          font.weight: 1000
          font.pixelSize: 14
          anchors.horizontalCenter: parent.horizontalCenter
          color: day.modelData.isCurrentMonth ? (day.isCurrentDay ? Catppuccin.base : Catppuccin.text) : ColorUtils.darken(Catppuccin.text, 100)
        }

        StyledText {
          font.pixelSize: 12
          anchors.horizontalCenter: parent.horizontalCenter
          text: `${day.lunar.day}/${day.lunar.month}`
          color: day.modelData.isCurrentMonth ? (day.isCurrentDay ? Catppuccin.base : Catppuccin.subtext1) : ColorUtils.darken(Catppuccin.subtext1, 100)
        }
      }
    }
  }
}