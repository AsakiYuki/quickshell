import QtQuick
import "../../core"
import "../../utils/FuzzySort.js" as FuzzySort
import "../../commands" as Cmd

LauncherListView {
    id: _list

    model: []

    readonly property list<var> entries: Cmd.List.commands.map(a => ({
        name:    FuzzySort.prepare(a.name),
        comment: FuzzySort.prepare(a.comment),
        entry:   a
    }))

    readonly property string search: _textField.searchText

    onSearchChanged: {
        const s = search.trim();
        if (!s.startsWith("/")) return;

        model = s === "/"
            ? entries.map(v => ({
                icon: v.entry.icon,
                text: v.entry.name,
                subtext: v.entry.comment,
                entry: v.entry
            }))
            : SharedState.search(s.slice(1), entries, false);

        if (model.length === 0) model = [{ text: "Nothing found!", subtext: "Try searching for something more general...", icon: "../../assets/icons/search_off.png" }];
    }
}