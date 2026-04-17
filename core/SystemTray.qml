pragma Singleton

import QtQuick

import Quickshell
import Quickshell.Services.SystemTray

Singleton {
  id: _root

  function getTrayById(id) {
    return configuration.trayIndex[id] ?? {};
  }

  readonly property list<var> systemTray: SystemTray.items.values;
  readonly property list<SystemTrayItem> allTray: Array.from(SystemTray.items.values);
  
  property list<SystemTrayItem> showTray: allTray.filter(v => !hideTray.includes(v))
  property list<SystemTrayItem> hideTray: allTray.filter(v => hideTray.includes(v))
  
  function updateSystemTray() {
    showTray = [];
    hideTray = [];

    console.log(hideTrayID)

    for (const trayItem of allTray) {
      const fullId = [trayItem.id, trayItem.tooltipTitle, trayItem.title].join("&")
      const isHide = hideTrayID.includes(fullId)

      if (isHide) hideTray.push(trayItem)
      else showTray.push(trayItem)
    }
  }

  property list<string> hideTrayID: []

  onHideTrayIDChanged: updateSystemTray()
  onAllTrayChanged: updateSystemTray()
  Component.onCompleted: updateSystemTray()
}