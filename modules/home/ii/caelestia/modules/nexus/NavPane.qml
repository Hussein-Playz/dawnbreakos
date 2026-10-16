import "navpane"
import QtQuick
import QtQuick.Layouts
import Dawnbreak.Config
import Dawnbreak.I18n
import qs.caelestia.components
import qs.caelestia.components.controls
import qs.caelestia.services
import qs.caelestia.modules.nexus

ColumnLayout {
    id: root

    required property NexusState nState

    spacing: Tokens.spacing.large

    SearchBar {
        id: searchField

        Layout.fillWidth: true

        placeholderText: Tr.tr("Search settings")
        font: Tokens.font.body.large

        bg.color: Colours.tPalette.m3surfaceContainerLowest
        bg.border.color: Colours.palette.m3outlineVariant
        searchIcon.fontStyle: Tokens.font.icon.medium
        searchIcon.anchors.leftMargin: Tokens.padding.largeIncreased
        clearIcon.font: Tokens.font.icon.medium
        clearIcon.padding: Tokens.padding.extraSmall

        Behavior on bg.border.color {
            CAnim {}
        }

        Binding {
            target: root.nState
            property: "searchOpen"
            value: searchField.text.length > 0
        }
    }

    NavLocations {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.topMargin: -topMargin
        Layout.bottomMargin: -bottomMargin
        nState: root.nState
    }
}
