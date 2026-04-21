.pragma library

function isMouseInsideTargetElement(mouseX, mouseY, offsetX, offsetY, target) {
  const {x, y} = target.mapToGlobal(offsetX, offsetY)
  const [toX, toY] = [x + target.width, y + target.height]

  return ((mouseX >= x) && (mouseX <= toX)) && ((mouseY >= y) && (mouseY <= toY))
}

function secondsToTime(seconds) {
  const time = seconds << 0

  seconds = time % 60
  let minutes = ((time / 60) << 0) % 60
  let hours = (time / 3600) << 0

  if (seconds < 10) seconds = "0" + seconds
  if (hours > 0) {
    if (minutes < 10) minutes = "0" + minutes
    hours = hours + ":"
  }
  
  return hours + minutes + ":" + seconds
}

function buildSearchQuery(data) {
  const params = new URLSearchParams();
  for (const [key, value] of Object.entries(data)) {
    if (value === null || value === undefined) continue;
    params.append(key, String(value));
  }
  const query = params.toString();
  return query ? `?${query}` : "";
}