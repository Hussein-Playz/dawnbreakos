# Generated QML source. This expression evaluates to the runtime QML text.
builtins.fromJSON "\"import qs.services\\nimport QtQuick\\nimport qs.modules.ii.onScreenDisplay\\n\\nOsdValueIndicator {\\n    id: osdValues\\n    value: Audio.sink?.audio.volume ?? 0\\n    icon: Audio.sink?.audio.muted ? \\\"volume_off\\\" : \\\"volume_up\\\"\\n    name: Translation.tr(\\\"Volume\\\")\\n}\\n\""
