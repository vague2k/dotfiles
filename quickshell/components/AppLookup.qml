pragma Singleton

import Quickshell
import QtQuick

QtObject {
    function resolveWindow(window) {
        const appId = window?.wayland?.appId || window?.lastIpcObject?.class || "";
        return DesktopEntries.heuristicLookup(appId);
    }

    function icon(entry, fallback) {
        return iconPath(entry?.icon || "", fallback);
    }

    function iconPath(name, fallback) {
        return Quickshell.iconPath(name || "", fallback === undefined ? true : fallback);
    }
}
