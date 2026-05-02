import QtQuick

import Quickshell.Io

import "../core"
import "../base"
import "../utils/Color.js" as ColorUtils

Item {
  id: root
  readonly property double barScale: height / parent.height 
  property list<int> bars: []

  onBarsChanged: soundVisualizer.requestPaint();

  width: parent.width
  height: 500
  anchors.bottom: parent.bottom

  Canvas {
    id: soundVisualizer
    anchors.fill: parent
    onPaint: {
      const ctx = getContext("2d");
      const bars = root.bars;
      const spacing = width / (bars.length - 2);
      ctx.reset()
      ctx.beginPath();

      ctx.moveTo(0, height);

      let lastX = 0;
      let lastY = height - bars[0];
      ctx.fillStyle = ColorUtils.opacity(Catppuccin.peach, 0.5);

      for (let index = 0; index < bars.length; index++) {
        const x = index * spacing;
        const y = height - bars[index] * root.barScale;

        const midX = (lastX + x) >> 1;
        const midY = (lastY + y) >> 1;

        ctx.quadraticCurveTo(lastX, lastY, midX, midY);

        lastX = x;
        lastY = y;
      }

      ctx.lineTo(width, height)

      ctx.fill();
    }
  }
  
  Process {
    id: cavaProcess
    running: !Workspaces.current.hasFullscreen
    command: ["cava", "-p", `${Paths.quickshell}/scripts/cava.ini`]
    stdout: SplitParser {
      onRead: data => root.bars = data.split(";").map(v => Number(v))
    }
  }
}