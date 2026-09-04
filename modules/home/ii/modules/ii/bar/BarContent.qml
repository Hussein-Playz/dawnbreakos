import qs.modules.ii.bar.weather
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

Item { // Bar content region
    id: root

    property var screen: root.QsWindow.window?.screen
    property var brightnessMonitor: Brightness.getMonitorForScreen(screen)
    property real useShortenedForm: (Appearance.sizes.barHellaShortenScreenWidthThreshold >= screen?.width) ? 2 : (Appearance.sizes.barShortenScreenWidthThreshold >= screen?.width) ? 1 : 0
    readonly property int centerSideModuleWidth: (useShortenedForm == 2) ? Appearance.sizes.barCenterSideModuleWidthHellaShortened : (useShortenedForm == 1) ? Appearance.sizes.barCenterSideModuleWidthShortened : Appearance.sizes.barCenterSideModuleWidth

    component VerticalBarSeparator: Rectangle {
        Layout.topMargin: Appearance.sizes.baseBarHeight / 3
        Layout.bottomMargin: Appearance.sizes.baseBarHeight / 3
        Layout.fillHeight: true
        implicitWidth: 1
        color: Appearance.colors.colOutlineVariant
    }

    // The bar is intentionally transparent.
    // Each section owns its own surface.

    // LEFT GROUP -----------------------------------------------------------
    FocusedScrollMouseArea {
        id: barLeftSideMouseArea

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            right: middleSection.left
        }

        implicitWidth: leftGroup.implicitWidth + 32
        implicitHeight: Appearance.sizes.baseBarHeight

        onScrollDown: Brightness.decreaseBrightness()
        onScrollUp: Brightness.increaseBrightness()
        onMovedAway: GlobalStates.osdBrightnessOpen = false

        onPressed: event => {
            if (event.button === Qt.LeftButton)
                GlobalStates.sidebarLeftOpen = !GlobalStates.sidebarLeftOpen;
        }

        ScrollHint {
            reveal: barLeftSideMouseArea.hovered
            icon: Hyprsunset.gamma === 100 ? "light_mode" : "wb_twilight"
            tooltipText: Translation.tr("Scroll to change brightness")
            side: "left"
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
        }

        BarGroup {
            id: leftGroup

            anchors {
                left: parent.left
                leftMargin: 12
                verticalCenter: parent.verticalCenter
            }

            padding: 8

            ActiveWindow {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: root.useShortenedForm === 0
            }
        }
    }

    // CENTER GROUP ---------------------------------------------------------
    //
    // One shared pill containing:
    //   Resources / Media | Clock | Workspaces / Buttons / Battery
    //
    // The individual BarGroups have their backgrounds disabled so they
    // don't create three separate pills.
    //
    Item {
        id: middleSection

        anchors {
            top: parent.top
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }

        implicitWidth: middleRow.implicitWidth + 16
        implicitHeight: Appearance.sizes.baseBarHeight

        Rectangle {
            id: middleBackground

            anchors {
                fill: parent
                topMargin: 4
                bottomMargin: 4
            }

            color: Appearance.colors.colLayer0
            radius: Appearance.rounding.full

            border.width: 1
            border.color: Appearance.colors.colLayer0Border
        }

        Row {
            id: middleRow

            anchors {
                centerIn: parent
            }

            spacing: 10

            // RESOURCE / MEDIA --------------------------------------------
            BarGroup {
                id: resourceMediaGroup

                drawBackground: false
                padding: 8

                Resources {
                    alwaysShowAllResources: root.useShortenedForm === 2
                    Layout.fillWidth: root.useShortenedForm === 2
                }

                Media {
                    visible: root.useShortenedForm < 2
                    Layout.fillWidth: true
                }
            }

            // CLOCK --------------------------------------------------------
            BarGroup {
                id: clockGroup

                drawBackground: false
                padding: 8

                ClockWidget {
                    showDate: (Config.options.bar.verbose && root.useShortenedForm < 2)
                    Layout.alignment: Qt.AlignVCenter
                    Layout.fillWidth: true
                }
            }

            // WORKSPACES / BUTTONS / BATTERY ------------------------------
            MouseArea {
                id: workspaceGroupArea

                anchors.verticalCenter: parent.verticalCenter

                implicitWidth: workspaceGroup.implicitWidth
                implicitHeight: workspaceGroup.implicitHeight

                onPressed: {
                    GlobalStates.sidebarRightOpen = !GlobalStates.sidebarRightOpen;
                }

                BarGroup {
                    id: workspaceGroup

                    drawBackground: false
                    anchors.centerIn: parent
                    padding: workspacesWidget.widgetPadding

                    Workspaces {
                        id: workspacesWidget

                        Layout.fillHeight: true

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.RightButton

                            onPressed: event => {
                                if (event.button === Qt.RightButton)
                                    GlobalStates.overviewOpen = !GlobalStates.overviewOpen;
                            }
                        }
                    }

                    UtilButtons {
                        visible: (Config.options.bar.verbose && root.useShortenedForm === 0)
                        Layout.alignment: Qt.AlignVCenter
                    }

                    BatteryIndicator {
                        visible: (root.useShortenedForm < 2 && Battery.available)
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
            }
        }
    }

    // RIGHT GROUP ----------------------------------------------------------
    FocusedScrollMouseArea {
        id: barRightSideMouseArea

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: middleSection.right
            right: parent.right
        }

        implicitWidth: rightGroup.implicitWidth + 32
        implicitHeight: Appearance.sizes.baseBarHeight

        onScrollDown: Audio.decrementVolume()
        onScrollUp: Audio.incrementVolume()
        onMovedAway: GlobalStates.osdVolumeOpen = false

        onPressed: event => {
            if (event.button === Qt.LeftButton)
                GlobalStates.sidebarRightOpen = !GlobalStates.sidebarRightOpen;
        }

        ScrollHint {
            reveal: barRightSideMouseArea.hovered
            icon: "volume_up"
            tooltipText: Translation.tr("Scroll to change volume")
            side: "right"
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
        }

        RowLayout {
            id: rightSectionRowLayout

            anchors {
                right: parent.right
                rightMargin: 12
                verticalCenter: parent.verticalCenter
            }

            spacing: 10
            layoutDirection: Qt.RightToLeft

            BarGroup {
                id: rightGroup

                padding: 8

                SysTray {
                    visible: root.useShortenedForm === 0
                    Layout.fillWidth: false
                    Layout.fillHeight: true
                    invertSide: Config?.options.bar.bottom
                }

                RippleButton {
                    id: rightSidebarButton

                    Layout.alignment: Qt.AlignVCenter
                    Layout.fillWidth: false

                    implicitWidth: indicatorsRowLayout.implicitWidth + 16
                    implicitHeight: indicatorsRowLayout.implicitHeight + 10

                    buttonRadius: Appearance.rounding.full

                    colBackground: barRightSideMouseArea.hovered
                    ? Appearance.colors.colLayer1Hover
                    : ColorUtils.transparentize(Appearance.colors.colLayer1Hover, 1)

                    colBackgroundHover: Appearance.colors.colLayer1Hover
                    colRipple: Appearance.colors.colLayer1Active
                    colBackgroundToggled: Appearance.colors.colPrimary
                    colBackgroundToggledHover: Appearance.colors.colPrimaryHover
                    colRippleToggled: Appearance.colors.colPrimaryActive

                    toggled: GlobalStates.sidebarRightOpen

                    property color colText: toggled
                    ? Appearance.colors.colOnPrimary
                    : Appearance.colors.colOnLayer0

                    Behavior on colText {
                        animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
                    }

                    onPressed: GlobalStates.sidebarRightOpen = !GlobalStates.sidebarRightOpen

                    RowLayout {
                        id: indicatorsRowLayout

                        anchors.centerIn: parent

                        property real realSpacing: 12

                        spacing: 0

                        Revealer {
                            reveal: Audio.sink?.audio?.muted ?? false
                            Layout.fillHeight: true
                            Layout.rightMargin: reveal ? indicatorsRowLayout.realSpacing : 0

                            MaterialSymbol {
                                text: "volume_off"
                                iconSize: Appearance.font.pixelSize.larger
                                color: rightSidebarButton.colText
                            }
                        }

                        Revealer {
                            reveal: Audio.source?.audio?.muted ?? false
                            Layout.fillHeight: true
                            Layout.rightMargin: reveal ? indicatorsRowLayout.realSpacing : 0

                            MaterialSymbol {
                                text: "mic_off"
                                iconSize: Appearance.font.pixelSize.larger
                                color: rightSidebarButton.colText
                            }
                        }

                        HyprlandXkbIndicator {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.rightMargin: indicatorsRowLayout.realSpacing
                            color: rightSidebarButton.colText
                        }

                        Revealer {
                            reveal: Notifications.silent || Notifications.unread > 0
                            Layout.fillHeight: true
                            Layout.rightMargin: reveal ? indicatorsRowLayout.realSpacing : 0

                            implicitHeight: reveal
                            ? notificationUnreadCount.implicitHeight
                            : 0

                            implicitWidth: reveal
                            ? notificationUnreadCount.implicitWidth
                            : 0

                            NotificationUnreadCount {
                                id: notificationUnreadCount
                            }
                        }

                        MaterialSymbol {
                            text: Network.materialSymbol
                            iconSize: Appearance.font.pixelSize.larger
                            color: rightSidebarButton.colText
                        }

                        MaterialSymbol {
                            Layout.leftMargin: indicatorsRowLayout.realSpacing

                            visible: BluetoothStatus.available

                            text: BluetoothStatus.connected
                            ? "bluetooth_connected"
                            : BluetoothStatus.enabled
                            ? "bluetooth"
                            : "bluetooth_disabled"

                            iconSize: Appearance.font.pixelSize.larger
                            color: rightSidebarButton.colText
                        }
                    }
                }
            }

            // Optional modules get their own surface.
            Loader {
                active: Config.options.bar.weather.enable

                sourceComponent: BarGroup {
                    WeatherBar {}
                }
            }
        }
    }
}
