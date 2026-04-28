import QtQuick

import "../../components"
import "../../base"

import "../../utils/Color.js" as ColorUtils
import "../../utils/DateUtils.js" as DateUtils
import "./CalendarUtils.js" as CalendarUtils

Grid {
  id: root

  columns: 7
  spacing: 5

  property int currentMonth: new Date().getMonth()
  property int currentDay: new Date().getDate()
  property int currentYear: new Date().getFullYear()

  property int viewMonth: 0
  property int viewYear: 0

  Repeater {
    model: CalendarUtils.getDaysArray(root.viewMonth + 1, root.viewYear)

    SimpleButton {
      id: day

      required property var modelData

      radius: 5

      width: 80
      height: width

      readonly property var lunar:
        new DateUtils.SolarDate(modelData.date)
          .toLunarDate()
          .get()

      readonly property bool isCurrentDay:
        modelData.year === root.currentYear
        && modelData.month === root.currentMonth + 1
        && modelData.day === root.currentDay

      readonly property bool isSpecialDay: {
        const lunarHoliday =
          Holydays.lunar[`${lunar.day}/${lunar.month}`]

        const solarHoliday =
          Holydays.solar[`${modelData.day}/${modelData.month}`]

        return modelData.date.getDay() === 0
          || modelData.date.getDay() === 6
          || lunarHoliday?.isSpecial
          || solarHoliday?.isSpecial
          || false
      }

      readonly property string holydayName: {
        const lunarHolidayName =
          Holydays.lunar[`${lunar.day}/${lunar.month}`]?.name

        const solarHoliday =
          Holydays.solar[`${modelData.day}/${modelData.month}`]

        if (!solarHoliday?.isSpecial && lunarHolidayName) {
          return lunarHolidayName
        }

        if (
          !solarHoliday
          || (
            solarHoliday.startYear
            && solarHoliday.startYear > modelData.year
          )
        ) {
          return ""
        }

        return solarHoliday.name
      }

      readonly property color mainTextColor: {
        if (modelData.isCurrentMonth) {
          return isCurrentDay
            ? (
              isSpecialDay
                ? ColorUtils.darken(Catppuccin.red, 100)
                : Catppuccin.base
            )
            : (
              isSpecialDay
                ? ColorUtils.darken(Catppuccin.red, 40)
                : Catppuccin.text
            )
        }

        return isCurrentDay
          ? (
            isSpecialDay
              ? ColorUtils.darken(Catppuccin.red, 100)
              : Catppuccin.base
          )
          : ColorUtils.darken(
            isSpecialDay
              ? Catppuccin.red
              : Catppuccin.text,
            50
          )
      }

      readonly property color subTextColor: {
        if (modelData.isCurrentMonth) {
          return isCurrentDay
            ? (
              isSpecialDay
                ? ColorUtils.darken(Catppuccin.red, 100)
                : Catppuccin.base
            )
            : (
              isSpecialDay
                ? ColorUtils.darken(Catppuccin.red, 40)
                : ColorUtils.darken(Catppuccin.text, 90)
            )
        }

        return isCurrentDay
          ? (
            isSpecialDay
              ? ColorUtils.darken(Catppuccin.red, 100)
              : Catppuccin.base
          )
          : ColorUtils.darken(
            isSpecialDay
              ? Catppuccin.red
              : Catppuccin.text,
            80
          )
      }

      normalColor:
        isCurrentDay
          ? Catppuccin.lavender
          : ColorUtils.lighten(Catppuccin.base, 3)

      Column {
        anchors.centerIn: parent
        spacing: 2

        StyledText {
          text: modelData.day
          font.weight: 1000
          font.pixelSize: 16
          anchors.horizontalCenter: parent.horizontalCenter
          color: mainTextColor
        }

        StyledText {
          visible: holydayName.length > 0
          text: holydayName
          font.pixelSize: 12
          anchors.horizontalCenter: parent.horizontalCenter
          color: subTextColor
        }

        StyledText {
          text: `${lunar.day}/${lunar.month}`
          font.pixelSize: 12
          anchors.horizontalCenter: parent.horizontalCenter
          color: subTextColor
        }
      }
    }
  }
}