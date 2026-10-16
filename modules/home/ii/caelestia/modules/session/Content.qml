pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Dawnbreak
import Dawnbreak.Config
import Dawnbreak.Services
import qs.caelestia.components
import qs.caelestia.components.controls
import qs.caelestia.services
import qs.caelestia.utils

Column {
    id: root

    required property ScreenState screenState

    padding: Tokens.padding.large
    rightPadding: CUtils.clamp(padding - Config.border.thickness, 0, padding)
    spacing: Tokens.spacing.large

    SessionButton {
        id: lock
        label: "Lock"
        icon: "lock"
        command: ["loginctl", "lock-session"]
        navDown: sleep.focusItem
        Component.onCompleted: focusItem.forceActiveFocus()
    }

    SessionButton {
        id: sleep
        label: "Sleep"
        icon: "dark_mode"
        command: ["bash", "-c", "systemctl suspend || loginctl suspend"]
        navUp: lock.focusItem
        navDown: logout.focusItem
    }

    SessionButton {
        id: logout
        label: "Log out"
        icon: Config.session.icons.logout
        command: Config.session.commands.logout
        navUp: sleep.focusItem
        navDown: taskManager.focusItem

        Connections {
            function onLauncherChanged(): void {
                if (!root.screenState.launcher)
                    logout.focusItem.forceActiveFocus();
            }
            target: root.screenState
        }
    }

    SessionButton {
        id: taskManager
        label: "Task Manager"
        icon: "monitoring"
        command: ["plasma-systemmonitor", "--page-name", "Processes"]
        navUp: logout.focusItem
        navDown: hibernate.focusItem
    }

    AnimatedImage {
        width: Tokens.sizes.session.button
        height: Tokens.sizes.session.button
        sourceSize.width: width * ((QsWindow.window as QsWindow)?.devicePixelRatio ?? 1)
        playing: visible
        asynchronous: true
        speed: Config.general.sessionGifSpeed
        source: Paths.absolutePath(Config.paths.sessionGif)
        fillMode: AnimatedImage.PreserveAspectFit
    }

    SessionButton {
        id: hibernate
        label: "Hibernate"
        icon: Config.session.icons.hibernate
        command: Config.session.commands.hibernate
        navUp: taskManager.focusItem
        navDown: shutdown.focusItem
    }

    SessionButton {
        id: shutdown
        label: "Shut down"
        icon: Config.session.icons.shutdown
        command: Config.session.commands.shutdown
        navUp: hibernate.focusItem
        navDown: reboot.focusItem
    }

    SessionButton {
        id: reboot
        label: "Restart"
        icon: Config.session.icons.reboot
        command: Config.session.commands.reboot
        navUp: shutdown.focusItem
        navDown: firmware.focusItem
    }

    SessionButton {
        id: firmware
        label: "Reboot to firmware settings"
        icon: "settings_applications"
        command: ["bash", "-c", "systemctl reboot --firmware-setup || loginctl reboot --firmware-setup"]
        navUp: reboot.focusItem
    }

    component SessionButton: Row {
        id: row

        required property string label
        required property string icon
        required property list<string> command
        property Item navUp: null
        property Item navDown: null
        readonly property Item focusItem: button

        // spacing: Tokens.spacing.medium

        function exec(): void {
            if (!SessionManager.exec(command))
                Quickshell.execDetached(command);
            root.screenState.session = false;
        }

        IconButton {
            id: button
            icon: row.icon
            implicitWidth: Tokens.sizes.session.button
            implicitHeight: Tokens.sizes.session.button
            inactiveColour: activeFocus ? Colours.palette.m3secondaryContainer : Colours.tPalette.m3surfaceContainer
            inactiveOnColour: activeFocus ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface
            radius: pressed ? Tokens.rounding.medium : activeFocus ? Tokens.rounding.extraLarge : Tokens.rounding.largeIncreased
            font: Tokens.font.icon.builders.large.scale(1.3).build()
            onClicked: row.exec()
            KeyNavigation.up: row.navUp
            KeyNavigation.down: row.navDown
            Keys.onEnterPressed: row.exec()
            Keys.onReturnPressed: row.exec()
            Keys.onEscapePressed: root.screenState.session = false
            ToolTip.text: row.label
            ToolTip.visible: hovered
            ToolTip.delay: 250
        }

        // StyledText {
        //     id: labelText
        //     anchors.verticalCenter: button.verticalCenter
        //     text: row.label
        //     color: Colours.palette.m3onSurface
        //     opacity: button.hovered || button.activeFocus ? 1 : 0
        //     visible: opacity > 0
        //     font: Tokens.font.body.medium
        //     Behavior on opacity { Anim {} }
        // }
    }
}
