import QtQuick.Layouts
import Dawnbreak.Config
import Dawnbreak.I18n
import qs.caelestia.components
import qs.caelestia.services

ColumnLayout {
    spacing: Tokens.spacing.small

    StyledText {
        text: Hypr.capsLock ? Tr.tr("Caps lock enabled") : Tr.tr("Caps lock disabled")
    }

    StyledText {
        text: Hypr.numLock ? Tr.tr("Num lock enabled") : Tr.tr("Num lock disabled")
    }
}
