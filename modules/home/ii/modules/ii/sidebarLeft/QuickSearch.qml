import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root

    property string query: ""
    property bool searching: false
    property string statusText: ""
    property var results: []
    property int requestSerial: 0

    function search() {
        const text = searchField.text.trim()

        if (text.length === 0) {
            searchField.forceActiveFocus()
            return
        }

        root.requestSerial++
        const serial = root.requestSerial

        searchProcess.running = false
        searchProcess.buffer = ""
        searchProcess.requestSerial = serial
        searchProcess.command = ["dawn-search", text]

        root.query = text
        root.results = []
        root.searching = true
        root.statusText = "Searching NixOS unstable..."

        searchProcess.running = true
    }

    function handleSearchResponse(payload) {
        if (!payload || payload.requestSerial !== root.requestSerial)
            return

        root.searching = false

        if (!payload.ok) {
            root.results = []
            root.statusText = payload.error || "Nix search failed."
            console.log("Nix Repo Search:", root.statusText)
            return
        }

        root.results = Array.isArray(payload.results)
            ? payload.results.slice(0, 20)
            : []

        if (root.results.length > 0)
            root.statusText = root.results.length + " packages found in nixpkgs-unstable"
        else
            root.statusText = "No matching packages found in nixpkgs-unstable."
    }

    function clearSearch() {
        root.requestSerial++
        searchProcess.running = false
        searchProcess.buffer = ""

        searchField.text = ""
        root.query = ""
        root.results = []
        root.searching = false
        root.statusText = ""

        searchField.forceActiveFocus()
    }

    function openResult(url) {
        if (url)
            Qt.openUrlExternally(url)
    }

    function focusSearch() {
        searchField.forceActiveFocus()
    }

    onVisibleChanged: {
        if (visible)
            focusSearch()
    }

    Process {
        id: searchProcess

        property string buffer: ""
        property int requestSerial: 0

        command: []

        stdout: SplitParser {
            onRead: data => {
                searchProcess.buffer += data
            }
        }

        stderr: SplitParser {
            onRead: data => {
                console.log("dawn-search:", data)
            }
        }

        onStarted: {
            searchProcess.buffer = ""
        }

        onExited: (exitCode, exitStatus) => {
            const serial = searchProcess.requestSerial

            if (serial !== root.requestSerial)
                return

            if (exitCode !== 0) {
                root.searching = false
                root.results = []
                root.statusText = "Nix search helper failed."
                return
            }

            let payload
            try {
                payload = JSON.parse(searchProcess.buffer.trim())
            } catch (e) {
                root.searching = false
                root.results = []
                root.statusText = "Invalid response from Nix search."
                console.log("Nix Repo Search: invalid JSON:", searchProcess.buffer)
                return
            }

            payload.requestSerial = serial
            root.handleSearchResponse(payload)
        }
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: 4
        }
        spacing: 4

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            StyledFlickable {
                anchors.fill: parent
                clip: true
                contentHeight: resultsColumn.implicitHeight

                ColumnLayout {
                    id: resultsColumn
                    width: parent.width
                    spacing: 6

                    Item {
                        Layout.fillWidth: true
                        implicitHeight: 92
                        visible: root.query.length === 0

                        Column {
                            anchors.centerIn: parent
                            spacing: 5

                            StyledText {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "Nix Repo Search"
                                color: Appearance.colors.colPrimary
                                font.pixelSize: Appearance.font.pixelSize.normal
                            }

                            StyledText {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "Browse packages from nixpkgs-unstable"
                                color: Appearance.colors.colSubtext
                                font.pixelSize: Appearance.font.pixelSize.small
                            }

                            StyledText {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "Search is performed locally with nix"
                                color: Appearance.colors.colSubtext
                                font.pixelSize: Appearance.font.pixelSize.smallest
                            }
                        }
                    }

                    StyledText {
                        Layout.fillWidth: true
                        visible: root.query.length > 0
                        text: root.statusText
                        color: Appearance.colors.colSubtext
                        font.pixelSize: Appearance.font.pixelSize.small
                        elide: Text.ElideRight
                    }

                    Repeater {
                        model: root.results

                        delegate: Rectangle {
                            required property var modelData

                            Layout.fillWidth: true
                            implicitHeight: resultColumn.implicitHeight + 20
                            radius: Appearance.rounding.small
                            color: resultMouse.containsMouse
                                ? Appearance.colors.colLayer1Hover
                                : Appearance.colors.colLayer1

                            ColumnLayout {
                                id: resultColumn

                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    top: parent.top
                                    margins: 10
                                }
                                spacing: 3

                                StyledText {
                                    Layout.fillWidth: true
                                    text: modelData.title || modelData.attribute || ""
                                    color: Appearance.colors.colPrimary
                                    font.pixelSize: Appearance.font.pixelSize.normal
                                    font.weight: Font.Medium
                                    elide: Text.ElideRight
                                }

                                StyledText {
                                    Layout.fillWidth: true
                                    visible: (modelData.attribute || "").length > 0
                                    text: modelData.attribute || ""
                                    color: Appearance.colors.colSecondary
                                    font.pixelSize: Appearance.font.pixelSize.smallest
                                    elide: Text.ElideRight
                                }

                                StyledText {
                                    Layout.fillWidth: true
                                    visible: (modelData.snippet || "").length > 0
                                    text: modelData.snippet || ""
                                    color: Appearance.colors.colSubtext
                                    font.pixelSize: Appearance.font.pixelSize.smaller
                                    maximumLineCount: 3
                                    wrapMode: Text.WordWrap
                                }
                            }

                            MouseArea {
                                id: resultMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onClicked: {
                                    root.openResult(modelData.url)
                                }
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        implicitHeight: 80
                        visible:
                            !root.searching &&
                            root.query.length > 0 &&
                            root.results.length === 0

                        StyledText {
                            anchors.centerIn: parent
                            text: root.statusText || "No matching packages found."
                            color: Appearance.colors.colSubtext
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 48
            radius: Appearance.rounding.normal
            color: Appearance.colors.colLayer2
            clip: true

            RowLayout {
                anchors.fill: parent
                anchors.margins: 4
                spacing: 4

                TextField {
                    id: searchField

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    placeholderText: "Search Nix unstable..."

                    font.family: Appearance.font.family.main
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.colOnLayer2
                    selectedTextColor: Appearance.m3colors.m3onSecondaryContainer
                    selectionColor: Appearance.colors.colSecondaryContainer

                    background: Rectangle {
                        radius: Appearance.rounding.small
                        color: Appearance.colors.colLayer1
                    }

                    onAccepted: {
                        root.search()
                    }

                    Keys.onEscapePressed: {
                        root.clearSearch()
                    }
                }

                Rectangle {
                    id: searchButton

                    Layout.preferredWidth: 44
                    Layout.fillHeight: true
                    radius: Appearance.rounding.small

                    color: searchMouse.pressed
                        ? Appearance.colors.colLayer2Active
                        : searchMouse.containsMouse
                        ? Appearance.colors.colLayer2Hover
                        : Appearance.colors.colLayer2

                    Text {
                        anchors.centerIn: parent
                        text: "⌕"
                        color: Appearance.colors.colOnLayer2
                        font.pixelSize: Appearance.font.pixelSize.large
                    }

                    MouseArea {
                        id: searchMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            root.search()
                        }
                    }
                }

                Rectangle {
                    id: clearButton

                    Layout.preferredWidth: 34
                    Layout.fillHeight: true
                    radius: Appearance.rounding.small
                    visible: searchField.text.length > 0

                    color: clearMouse.pressed
                        ? Appearance.colors.colLayer2Active
                        : clearMouse.containsMouse
                        ? Appearance.colors.colLayer2Hover
                        : Appearance.colors.colLayer2

                    Text {
                        anchors.centerIn: parent
                        text: "×"
                        color: Appearance.colors.colOnLayer2
                        font.pixelSize: Appearance.font.pixelSize.large
                    }

                    MouseArea {
                        id: clearMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            root.clearSearch()
                        }
                    }
                }
            }
        }
    }
}
