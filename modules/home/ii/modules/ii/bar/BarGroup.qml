import qs.modules.common
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property bool drawBackground: true
    property real padding: 5
    implicitWidth: gridLayout.implicitWidth + padding * 2
    implicitHeight: Appearance.sizes.baseBarHeight
    default property alias items: gridLayout.children

    Rectangle {
        anchors {
            fill: parent
            topMargin: 4
            bottomMargin: 4
        }
        visible: root.drawBackground
        color: Appearance.colors.colLayer0
        radius: Appearance.rounding.full
        border.width: 1
        border.color: Appearance.colors.colLayer0Border
    }

    GridLayout {
        id: gridLayout
        columns: -1
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            right: parent.right
            margins: root.padding
        }
        columnSpacing: 4
        rowSpacing: 12
    }
}
