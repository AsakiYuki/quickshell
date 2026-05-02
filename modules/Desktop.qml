pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland

import "../components"
import "../core"

import "../elements" as Elements

Variants {
  id: root
  model: Quickshell.screens

  Scope {
    id: scope
    required property ShellScreen modelData
    
    StyledWindow {
      id: desktop
      name: "desktop"

      WlrLayershell.exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: WlrLayer.Bottom

      anchors.top: true
      anchors.bottom: true
      anchors.left: true
      anchors.right: true

      margins.top: (!Workspaces.hasFullscreen) * 45
      
      Elements.Cava {}
    }
  }
}