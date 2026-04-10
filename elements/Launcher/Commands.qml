import QtQuick

import "../../core"
import "../../utils/FuzzySort.js" as FuzzySort
import "../../commands" as Cmd

LauncherListView {
    id: _list

    property list<var> entries: Cmd.List.commands.map(a => ({
                name: FuzzySort.prepare(a.name),
                comment: FuzzySort.prepare(a.comment),
                entry: a
            }))

    readonly property string search: _textField.searchText

    onSearchChanged: {
        const $search = search.trim();

        if (!$search.startsWith("/"))
            return;

        if ($search === "/") {
            model = entries.map(v => ({
                        icon: v.entry.icon,
                        text: v.entry.name,
                        subtext: v.entry.comment,
                        entry: {
                            target: v.entry.target,
                            textfieldPlaceHolder: v.entry.textfieldPlaceHolder
                        }
                    }));
        } else {
            model = SharedState.search($search.slice(1), entries, false);
        }

        if (model.length === 0)
            model = [
                {
                    text: "No results",
                    subtext: "Try again",
                    icon: "../../assets/icons/search_off.png"
                }
            ];
    }

    model: []
}
