import QtQuick
import Quickshell

import "../../components"
import "../../core"
import "../../base"
import "../../utils/FuzzySort.js" as FuzzySort

LauncherListView {
    id: _list

    property list<var> entries: DesktopEntries.applications.values.filter(v => !v.noDisplay).sort((a, b) => a.name.localeCompare(b.name)).map(a => ({
        name: FuzzySort.prepare(a.name),
        comment: FuzzySort.prepare(a.comment),
        entry: a
    }))

    readonly property string search: _textField.searchText

    onSearchChanged: {
        _root.reset();

        const $search = search.trim();

        if ($search === "") {
            model = entries.map(v => ({
                icon: SharedState.parseIconPath(v.entry.icon),
                text: v.entry.name,
                subtext: v.entry.comment,
                entry: v.entry
            }));
        }

        if ($search.startsWith("/"))
            return;

        model = SharedState.search($search, entries);

        if (model.length === 0)
            model = [
                {
                    text: "No results",
                    subtext: "Try again",
                    icon: "../../assets/icons/search_off.png"
                }
            ];
    }

    model: [
        {
            text: "No results",
            subtext: "Try again",
            icon: "../../assets/icons/search_off.png"
        }
    ]

    onEntriesChanged: {
        model = entries.map(v => ({
            icon: SharedState.parseIconPath(v.entry.icon),
            text: v.entry.name,
            subtext: v.entry.comment,
            entry: v.entry
        }));
    }
}
