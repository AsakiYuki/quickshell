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
  height: 350
  anchors.bottom: parent.bottom

  Canvas {
    id: soundVisualizer
    anchors.fill: parent
    onPaint: {
      const ctx = getContext("2d");
      const bars = root.bars;

      const mirrored = [
        ...bars.slice().reverse().slice(1, -1),
        ...bars.slice(2, -1)
      ];

      const spacing = width / (mirrored.length - 2);

      ctx.reset();
      ctx.beginPath();

      ctx.moveTo(0, height);

      let lastX = 0;
      let lastY = height - mirrored[0] * root.barScale;

      ctx.fillStyle = ColorUtils.opacity(Catppuccin.yellow, 0.35);

      for (let i = 0; i < mirrored.length; i++) {
        const x = i * spacing;
        const y = height - mirrored[i] * root.barScale;

        const midX = (lastX + x) >> 1;
        const midY = (lastY + y) >> 1;

        ctx.quadraticCurveTo(lastX, lastY, midX, midY);

        lastX = x;
        lastY = y;
      }

      ctx.lineTo(width, height);
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