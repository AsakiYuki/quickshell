import QtQuick
import "../components"
import "../base"
import "../core"
import "../elements/launcher" as Launcher
import "../utils/FuzzySort.js" as FuzzySort

Item {
    id: root

    width: 630
    height: launcherListView.height

    property string searchScoreName: "application"

    property int viewIndex: 0
    property int selectorIndex: 0

    property int count: launcherListView.model?.length ?? 0
    property int maxSelector: Math.min(launcherListView.maxView ?? 0, count)

    property list<var> listEntries: []

    function clampSelector(v) {
        return Math.max(0, Math.min(v, maxSelector - 1));
    }
    function clampView(v) {
        return Math.max(0, Math.min(v, count - maxSelector));
    }

    function goUp() {
        if (selectorIndex > 0)
            selectorIndex--;
        else if (viewIndex > 0)
            viewIndex--;
        else {
            selectorIndex = maxSelector - 1;
            viewIndex = count - maxSelector;
        }
    }

    function goDown() {
        if (selectorIndex < maxSelector - 1)
            selectorIndex++;
        else if (viewIndex + maxSelector < count)
            viewIndex++;
        else {
            selectorIndex = 0;
            viewIndex = 0;
        }
    }

    onSelectorIndexChanged: {
        const c = clampSelector(selectorIndex);
        if (selectorIndex !== c)
            selectorIndex = c;
    }

    onViewIndexChanged: {
        const c = clampView(viewIndex);
        if (viewIndex !== c)
            viewIndex = c;
    }

    function reset() {
        viewIndex = 0;
        selectorIndex = 0;
    }

    function onExecute(index) {
        SharedState.isLauncherOpened = false;
    }

    function scoreFn(r) {
        return (r[0].score > 0) ? (r[0].score * 0.9 + r[1].score * 0.1) : 0;
    }

    function getKey(e) {
        return e.path ?? e.appid ?? e.text;
    }

    function defaultScore(e) {
        const key = getKey(e);
        const clickCount = configuration.getSearchScore(root.searchScoreName, key);
        return Math.log(1 + clickCount);
    }

    function execute(index) {
        if (index < 0 || index >= launcherListView.model.length)
            return;
        const exec = launcherListView.model[index].execute;
        if (typeof exec === "function")
            exec();
        onExecute(index);
    }

    function onTextfieldTyping(text) {
        launcherListView.search = text.trim();
        root.viewIndex = root.selectorIndex = 0;
    }

    function onKeyPressed(ev) {
        switch (ev.key) {
        case Qt.Key_Up:
            root.goUp();
            break;
        case Qt.Key_Down:
            root.goDown();
            break;
        case Qt.Key_Return:
        case Qt.Key_Enter:
            root.execute(root.viewIndex + root.selectorIndex);
            break;
        }
    }

    RadiusRectangle {
        id: selectorPanel

        anchors.horizontalCenter: parent.horizontalCenter
        color: Catppuccin.surface0
        width: parent.width
        height: 55
        y: root.selectorIndex * 55

        Behavior on y {
            NumberAnimation {
                duration: 350
                easing.type: Easing.OutExpo
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: ev => {
            const clicked = Math.floor(mouseY / 55);
            if (root.selectorIndex === clicked)
                root.execute(clicked + root.viewIndex);
            else
                root.selectorIndex = clicked;
        }

        onWheel: ev => {
            if (ev.angleDelta.y > 0)
                root.goUp();
            else
                root.goDown();
        }
    }

    Launcher.LauncherListView {
        id: launcherListView

        width: parent.width - 20
        viewIndex: root.viewIndex

        property string search: ""

        readonly property var preparedEntries: root.listEntries.map(a => ({
            name: FuzzySort.prepare(a.text),
            comment: FuzzySort.prepare(a.subtext),
            entry: a
        }))

        model: {
            if (!preparedEntries || preparedEntries.length === 0)
                return [];

            if (search.length === 0) {
                return preparedEntries.map(e => ({
                    entry: e.entry,
                    score: root.defaultScore(e.entry)
                })).sort((a, b) => b.score - a.score).map(v => v.entry);
            }

            const result = SharedState.search(search, preparedEntries, false, root.scoreFn);

            const mapped = result?.map(v => v.entry) || [];

            return mapped.length > 0 ? mapped : [
                {
                    text: "Nothing found!",
                    subtext: "Try searching for something more general...",
                    icon: "../../assets/icons/search_off.png"
                }
            ];
        }
    }
}
