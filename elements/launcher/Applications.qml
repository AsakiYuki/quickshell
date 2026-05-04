import QtQuick
import Quickshell
import "../../components"
import "../../core"
import "../../base"
import "../../utils/FuzzySort.js" as FuzzySort

LauncherListView {
    id: _list

    model: [{ text: "No results", subtext: "Try again", icon: "../../assets/icons/search_off.png" }]

    readonly property list<var> entries: DesktopEntries.applications.values
        .filter(v => !v.noDisplay)
        .sort((a, b) => a.name.localeCompare(b.name))
        .map(a => ({
            name:    FuzzySort.prepare(a.name),
            comment: FuzzySort.prepare(a.comment),
            entry:   a
        }))

    readonly property string search: _textField.searchText
    readonly property var noResult: [{ text: "No results", subtext: "Try again", icon: "../../assets/icons/search_off.png" }]

    function toModelEntry(v) {
        return { icon: SharedState.parseIconPath(v.entry.icon), text: v.entry.name, subtext: v.entry.comment, entry: v.entry };
    }

    onEntriesChanged: model = entries.map(toModelEntry)

    onSearchChanged: {
        _root.reset();
        const s = search.trim();
        if (s.startsWith("/")) return;
        model = s === "" ? entries.map(toModelEntry) : (SharedState.search(s, entries) || []);
        if (model.length === 0) model = noResult;
    }
}