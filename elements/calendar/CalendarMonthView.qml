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
  property int currentYear: new Date().getFullYear()

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
      readonly property bool isCurrentDay: (day.modelData.year === root.currentYear) && (day.modelData.month === root.currentMonth + 1) && (day.modelData.day === root.currentDay)
      readonly property bool isSpecialDay: {
        if (modelData.date.getDay() === 0 || modelData.date.getDay() === 6) return true
        return Holydays.lunar[`${day.lunar.day}/${day.lunar.month}`]?.isSpecial || Holydays.solar[`${modelData.day}/${modelData.month}`]?.isSpecial || false;
      }
      readonly property string holydayName: {
        const lunarHolidayName = Holydays.lunar[`${day.lunar.day}/${day.lunar.month}`]?.name;
        const solarHoliday = Holydays.solar[`${modelData.day}/${modelData.month}`];
        if (!solarHoliday?.isSpecial && lunarHolidayName) return lunarHolidayName;
        if (!solarHoliday || solarHoliday.startYear > modelData.year) return ""
        return solarHoliday.name
      }

      readonly property string mainTextColor: {
        if (day.modelData.isCurrentMonth) {
          return day.isCurrentDay ? Catppuccin.base : isSpecialDay ? Catppuccin.red : Catppuccin.text
        } else {
          return isCurrentDay ? Catppuccin.base : ColorUtils.darken(isSpecialDay ? Catppuccin.red : Catppuccin.text, 50)
        }
      }

      readonly property string subTextColor: {
        if (day.modelData.isCurrentMonth) {
          return day.isCurrentDay ? Catppuccin.base : isSpecialDay ? ColorUtils.darken(Catppuccin.red, 40) : ColorUtils.darken(Catppuccin.text, 90)
        } else {
          return day.isCurrentDay ? Catppuccin.base : ColorUtils.darken(isSpecialDay ? Catppuccin.red : Catppuccin.text, 80)
        }
      }
      
      normalColor: isCurrentDay ? Catppuccin.lavender : ColorUtils.lighten(Catppuccin.base, 3)

      width: 80
      height: width
      
      Column {
        anchors.centerIn: parent
        
        StyledText {
          text: day.modelData.day
          font.weight: 1000
          font.pixelSize: 16
          anchors.horizontalCenter: parent.horizontalCenter
          color: day.mainTextColor
        }

        StyledText {
          text: day.holydayName
          font.pixelSize: 12
          anchors.horizontalCenter: parent.horizontalCenter
          color: day.subTextColor
        }

        StyledText {
          font.pixelSize: 12
          anchors.horizontalCenter: parent.horizontalCenter
          text: `${day.lunar.day}/${day.lunar.month}`
          color: day.subTextColor
        }
      }
    }
  }
}