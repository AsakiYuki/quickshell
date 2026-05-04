import QtQuick
import Quickshell
import "../../components"
import "../../core"
import "../../base"
import "../../utils/FuzzySort.js" as FuzzySort

LauncherListView {
    id: _list

    model: [{ text: "Nothing found!", subtext: "Try searching for something more general...", icon: "../../assets/icons/search_off.png" }]

    readonly property list<var> entries: DesktopEntries.applications.values
        .filter(v => !v.noDisplay)
        .sort((a, b) => a.name.localeCompare(b.name))
        .map(a => ({ name: FuzzySort.prepare(a.name), comment: FuzzySort.prepare(a.comment), entry: a }))

    readonly property string search: _textField.searchText
    readonly property var noResult: [{ text: "Nothing found!", subtext: "Try searching for something more general...", icon: "../../assets/icons/search_off.png" }]

    function toModelEntry(v) {
        return { icon: SharedState.parseIconPath(v.entry.icon), text: v.entry.name, subtext: v.entry.comment, entry: v.entry };
    }

    onEntriesChanged: model = entries.map(toModelEntry)

    onSearchChanged: {
        _root.reset();
        const s = search.trim();
        if (s.startsWith("/") || s.startsWith("=")) return;
        model = s === "" ? entries.map(toModelEntry) : (SharedState.search(s, entries, true, r => {
            if (r[0].score > 0) {
                const clickCount = configuration.getSearchScore("application", r.obj.entry.id);
                return (r[0].score * 0.9 + r[1].score * 0.1) + (Math.log(1 + clickCount) * 0.1);
            } else return 0;
        }) || []);
        if (model.length === 0) model = noResult;
    }
}