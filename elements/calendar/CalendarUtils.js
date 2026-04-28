function getDaysArray(month, year) {
  const monthIndex = month - 1;

  const firstDayOfMonth = new Date(year, monthIndex, 1);
  const lastDayOfMonth = new Date(year, monthIndex + 1, 0);

  const startDayOfWeek = (firstDayOfMonth.getDay() + 6) % 7;
  const endDayOfWeek = (lastDayOfMonth.getDay() + 6) % 7;

  const startDate = new Date(
    year,
    monthIndex,
    1 - startDayOfWeek
  );

  const totalDays =
    startDayOfWeek +
    lastDayOfMonth.getDate() +
    (6 - endDayOfWeek);

  const daysArray = [];

  for (let i = 0; i < totalDays; i++) {
    const currentDate = new Date(
      startDate.getFullYear(),
      startDate.getMonth(),
      startDate.getDate() + i
    );

    daysArray.push({
      date: currentDate,
      day: currentDate.getDate(),
      month: currentDate.getMonth() + 1,
      year: currentDate.getFullYear(),

      weekDay: (currentDate.getDay() + 6) % 7,

      isCurrentMonth:
        currentDate.getMonth() === monthIndex
    });
  }

  return daysArray;
}