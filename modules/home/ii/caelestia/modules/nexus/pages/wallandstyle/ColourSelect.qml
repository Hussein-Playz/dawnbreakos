import QtQuick
import QtQuick.Layouts
import Dawnbreak.Config
import Dawnbreak.I18n
import qs.caelestia.components
import qs.caelestia.services
import qs.caelestia.modules.nexus.common

PageBase {
    id: root

    title: Tr.tr("Colours")
    isSubPage: true

    Item {
        anchors.horizontalCenter: parent.horizontalCenter
        implicitHeight: {
            const f = parent.parent as Flickable;
            return f.height - f.topMargin - f.bottomMargin;
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: Tokens.padding.extraSmall

            MaterialIcon {
                Layout.alignment: Qt.AlignHCenter
                text: "handyman"
                color: Colours.palette.m3outlineVariant
                fontStyle: Tokens.font.icon.extraLarge
            }

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: Tr.tr("Page under construction")
                color: Colours.palette.m3outlineVariant
                font: Tokens.font.title.large
            }

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: Tr.tr("This page will be available in a future update.")
                color: Colours.palette.m3outlineVariant
                font: Tokens.font.body.large
            }
        }
    }
}
