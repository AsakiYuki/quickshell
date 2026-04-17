function isMouseInsideTargetElement(mouseX, mouseY, offsetX, offsetY, target) {
  const {x, y} = target.mapToGlobal(offsetX, offsetY)
  const [toX, toY] = [x + target.width, y + target.height]

  return ((mouseX >= x) && (mouseX <= toX)) && ((mouseY >= y) && (mouseY <= toY))
}