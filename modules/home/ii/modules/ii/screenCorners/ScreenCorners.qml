import qs
import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick.Controls
import QtQuick.Layouts

Scope {
    id: screenCorners
    property var actionForCorner: ({
        [RoundCorner.CornerEnum.TopLeft]: () => GlobalStates.sidebarLeftOpen = !GlobalStates.sidebarLeftOpen,
        [RoundCorner.CornerEnum.BottomLeft]: () => GlobalStates.sidebarLeftOpen = !GlobalStates.sidebarLeftOpen,
        [RoundCorner.CornerEnum.TopRight]: () => GlobalStates.sidebarRightOpen = !GlobalStates.sidebarRightOpen,
        [RoundCorner.CornerEnum.BottomRight]: () => GlobalStates.sidebarRightOpen = !GlobalStates.sidebarRightOpen
    })

    component CornerPanelWindow: PanelWindow {
        id: cornerPanelWindow
        property bool fullscreen
        visible: !fullscreen
        property var corner

        exclusionMode: ExclusionMode.Ignore
        mask: Region {
            item: sidebarCornerOpenInteractionLoader.active ? sidebarCornerOpenInteractionLoader : null
        }
        WlrLayershell.namespace: "quickshell:screenCorners"
        WlrLayershell.layer: WlrLayer.Overlay
        color: "transparent"

        anchors {
            top: cornerWidget.isTopLeft || cornerWidget.isTopRight
            left: cornerWidget.isBottomLeft || cornerWidget.isTopLeft
            bottom: cornerWidget.isBottomLeft || cornerWidget.isBottomRight
            right: cornerWidget.isTopRight || cornerWidget.isBottomRight
        }

        implicitWidth: cornerWidget.implicitWidth
        implicitHeight: cornerWidget.implicitHeight

        RoundCorner {
            id: cornerWidget
            anchors.fill: parent
            corner: cornerPanelWindow.corner
            rightVisualMargin: 0
            bottomVisualMargin: 0

            implicitSize: Appearance.rounding.screenRounding
            implicitHeight: Math.max(implicitSize, sidebarCornerOpenInteractionLoader.implicitHeight)
            implicitWidth: Math.max(implicitSize, sidebarCornerOpenInteractionLoader.implicitWidth)

            Loader {
                id: sidebarCornerOpenInteractionLoader
                active: !cornerPanelWindow.fullscreen && !cornerWidget.isBottom
                anchors {
                    top: (cornerWidget.isTopLeft || cornerWidget.isTopRight) ? parent.top : undefined
                    bottom: (cornerWidget.isBottomLeft || cornerWidget.isBottomRight) ? parent.bottom : undefined
                    left: (cornerWidget.isLeft) ? parent.left : undefined
                    right: (cornerWidget.isTopRight || cornerWidget.isBottomRight) ? parent.right : undefined
                }

                sourceComponent: FocusedScrollMouseArea {
                    id: mouseArea
                    implicitWidth: 250
                    implicitHeight: 5
                    hoverEnabled: true
                    onPositionChanged: {
                        const verticalOffset = 1;
                        const correctX = (cornerWidget.isRight && mouseArea.mouseX >= mouseArea.width - 2) || (cornerWidget.isLeft && mouseArea.mouseX <= 2);
                        const correctY = (cornerWidget.isTop && mouseArea.mouseY > verticalOffset || cornerWidget.isBottom && mouseArea.mouseY < mouseArea.height - verticalOffset);
                        if (correctX && correctY)
                            screenCorners.actionForCorner[cornerPanelWindow.corner]();
                    }
                    onPressed: {
                        screenCorners.actionForCorner[cornerPanelWindow.corner]();
                    }
                    onScrollDown: {
                        if (cornerWidget.isLeft)
                            Brightness.decreaseBrightness()
                        else {
                            const currentVolume = Audio.value;
                            const step = currentVolume < 0.1 ? 0.01 : 0.02;
                            Audio.sink.audio.volume -= step;
                        }
                    }
                    onScrollUp: {
                        if (cornerWidget.isLeft)
                            Brightness.increaseBrightness()
                        else {
                            const currentVolume = Audio.value;
                            const step = currentVolume < 0.1 ? 0.01 : 0.02;
                            Audio.sink.audio.volume = Math.min(1, Audio.sink.audio.volume + step);
                        }
                    }
                    onMovedAway: {
                        if (cornerWidget.isLeft)
                            GlobalStates.osdBrightnessOpen = false;
                        else
                            GlobalStates.osdVolumeOpen = false;
                    }


                }
            }
        }
    }

    Variants {
        model: Quickshell.screens

        Scope {
            id: monitorScope
            required property var modelData
            property HyprlandMonitor monitor: Hyprland.monitorFor(modelData)

            // Hide when fullscreen
            property list<HyprlandWorkspace> workspacesForMonitor: Hyprland.workspaces.values.filter(workspace => workspace.monitor && workspace.monitor.name == monitor.name)
            property var activeWorkspaceWithFullscreen: workspacesForMonitor.filter(workspace => ((workspace.toplevels.values.filter(window => window.wayland?.fullscreen)[0] != undefined) && workspace.active))[0]
            property bool fullscreen: activeWorkspaceWithFullscreen != undefined

            CornerPanelWindow {
                screen: modelData
                corner: RoundCorner.CornerEnum.TopLeft
                fullscreen: monitorScope.fullscreen
            }
            CornerPanelWindow {
                screen: modelData
                corner: RoundCorner.CornerEnum.TopRight
                fullscreen: monitorScope.fullscreen
            }
            CornerPanelWindow {
                screen: modelData
                corner: RoundCorner.CornerEnum.BottomLeft
                fullscreen: monitorScope.fullscreen
            }
            CornerPanelWindow {
                screen: modelData
                corner: RoundCorner.CornerEnum.BottomRight
                fullscreen: monitorScope.fullscreen
            }
        }
    }
}
