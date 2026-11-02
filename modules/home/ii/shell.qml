//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

// Remove two slashes below and adjust the value to change the UI scale
////@ pragma Env QT_SCALE_FACTOR=1

import "modules/common"
import "services"
import "panelFamilies"
import "caelestia"
import "caelestia/modules/lock" as CaelestiaLock
import QtQuick.Window
import Quickshell.Hyprland

import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {

    // Stuff for every panel family
    ReloadPopup {}

    // Caelestia-derived dashboard, integrated into this same II config.
    DashboardHost { id: dashboardHost }

    // Caelestia lock screen replaces the Illogical Impulse lock screen.
    CaelestiaLock.Lock { id: caelestiaLock }

    IpcHandler {
        target: "dawnbreakDashboard"
        function toggle(): void { dashboardHost.toggleFromShortcut() }
        function open(): void { dashboardHost.opened = true; dashboardHost.shortcutActive = true }
        function close(): void { dashboardHost.opened = false; dashboardHost.shortcutActive = false }
    }

    Component.onCompleted: {
        MaterialThemeLoader.reapplyTheme()
        FirstRunExperience.load()
        ConflictKiller.load()
        Cliphist.refresh()
        Wallpapers.load()
        Updates.load()
    }


    // II is the only active panel family.
    LazyLoader {
        active: Config.ready
        component: IllogicalImpulseFamily {}
    }

}
