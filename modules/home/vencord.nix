{ config, pkgs, ... }:

{
  home.file.".config/Vencord/themes/DBWT.theme.css".text = ''
    /**
    * @name The Dawnbreak Warden
    * @author The Dawnbreak Warden
    * @version 1.0.0
    * @description The theme of the Dawnbreak Warden himself
    */
    /* IMPORT CSS */
    @import url("https://clearvision.github.io/ClearVision-v7/main.css");
    @import url("https://clearvision.github.io/ClearVision-v7/betterdiscord.css");
    /* SETTINGS */
    :root {
        /* ACCENT COLORS */
        --main-color: #7a3ee8; /* vivid royal purple */
        --hover-color: #632ccf; /* darker hover purple */
        --success-color: #8be88b; /* softened green accent to match purple tone */
        --danger-color: #b33232; /* slightly warmer red for better harmony */
        /* STATUS COLORS */
        --online-color: #8be88b;
        --idle-color: #e0a43c;
        --dnd-color: #b33232;
        --streaming-color: #8e48e0; /* matches new purple accent */
        --offline-color: #808080;
        /* APP BACKGROUND */
        --background-shading-percent: 0%; /* app background shading amount (0 for complete smoothness) [default: 100%] */
        --background-image: url(https://raw.githubusercontent.com/Hussein-Playz/Dawnbreak-Warden/main/Dawnbreak%20Warden%20PC%20Art.png); /* app background image (link must be HTTPS) [default: url(https://clearvision.github.io/images/sapphire.jpg)]*/
        --background-position: center; /* app background position [default: center] */
        --background-size: cover; /* app background size (px) [default: cover] */
        --background-attachment: fixed; /* app background attachment [default: fixed] */
        --background-filter: saturate(calc(var(--saturation-factor, 1) * 1)); /* app background adjustments (ex: blur, saturation, brightness) (more info: https://developer.mozilla.org/en-US/docs/Web/CSS/filter) [default: saturate(calc(var(--saturation-factor, 1) * 1))] */
        /* USER POPOUT BACKGROUND */
        --user-popout-image: var(--background-image); /* user popout background image (link must be HTTPS) (not applied to nitro users) [default: var(--background-image)] */
        --user-popout-position: var(--background-position); /* user popout position [default: var(--background-position)] */
        --user-popout-size: var(--background-size); /* user popout size (px) [default: var(--background-size)] */
        --user-popout-attachment: var(--background-attachment); /* user popout background attachment [default: var(--background-attachment)] */
        --user-popout-filter: var(--background-filter); /* user popout background adjustments (ex: blur, saturation, brightness) (more info: https://developer.mozilla.org/en-US/docs/Web/CSS/filter) [default: var(--background-filter);] */
        /* USER MODAL BACKGROUND */
        --user-modal-image: var(--background-image); /* user modal background image (link must be HTTPS) (not applied to nitro users) [default: var(--background-image)] */
        --user-modal-position: var(--background-position); /* user modal position [default: var(--background-position)] */
        --user-modal-size: var(--background-size); /* user modal size (px) [default: var(--background-size)] */
        --user-modal-attachment: var(--background-attachment); /* user modal background attachment [default: var(--background-attachment)] */
        --user-modal-filter: var(--background-filter); /* user modal background adjustments (ex: blur, saturation, brightness) (more info: https://developer.mozilla.org/en-US/docs/Web/CSS/filter) [default: var(--background-filter);] */
        /* HOME ICON */
        --home-icon: url(https://clearvision.github.io/icons/discord.svg); /* home button icon (link must be HTTPS) [default: url(https://clearvision.github.io/icons/discord.svg)]*/
        --home-size: cover; /* home button icon size (px) [default:cover] */
        /* FONTS */
        --main-font: "gg sans", "Helvetica Neue", Helvetica, Arial, sans-serif; /* main font for app (font must be installed) [default: gg sans, Helvetica Neue, Helvetica, Arial, sans-serif] */
        --code-font: Consolas, "gg mono", "Liberation Mono", Menlo, Courier, monospace; /* font for codeblocks (font must be installed) [default: Consolas, Liberation Mono, Menlo, Courier, monospace] */
        /* CHANNEL COLORS */
        --channel-normal: var(--interactive-normal); /* channel text color [default: var(--interactive-normal)] */
        --channel-muted: var(--interactive-muted); /* muted channel text color [default: var(--interactive-muted)] */
        --channel-hover: var(--interactive-hover); /* hovered channel text color [default: var(--interactive-hover)] */
        --channel-selected: var(--interactive-active); /* selected channel text color [default: var(--interactive-active)] */
        --channel-selected-bg: #170042;
        --channel-unread: #8e48e0;
        --channel-unread-hover: #a05cf2;
        /* ACCESSIBILITY */
        --focus-color: #8e48e0; /* outline when pressing TAB key [default: var(--main-color)] */
    }
    /* THEME SPECIFIC SHADING */
    /* LIGHT THEME */
    :is(.theme-light, .theme-dark .theme-light) {
        --background-shading: rgba(0, 0, 0, 0.0);; /* app background shading color [default: rgba(252, 252, 252, 0.3)] */
        --card-shading: rgba(0, 0, 0, 0.0);
        --popout-shading: rgba(0, 0, 0, 0.0);
        --modal-shading: rgba(0, 0, 0, 0.0);
        --input-shading: rgba(0, 0, 0, 0.3); /* inputs background shading color [default: rgba(0, 0, 0, 0.6)] */
        --normal-text: #36363c; /* text color [default: #36363c] */
        --muted-text: #75757e; /* muted text color [default: #75757e] */
    }

    /* ASH THEME */
    :is(.theme-dark, .theme-light .theme-dark) {
        --background-shading: rgba(0, 0, 0, 0.4); /* app background shading color [default: rgba(0, 0, 0, 0.4)] */
        --card-shading: rgba(0, 0, 0, 0.0);
        --popout-shading: rgba(0, 0, 0, 0.0);
        --modal-shading: rgba(0, 0, 0, 0.0);
        --input-shading: rgba(255, 255, 255, 0.05); /* inputs background shading color [default: rgba(255, 255, 255, 0.05)] */
        --normal-text: #d8d8db; /* text color [default: #d8d8db] */
        --muted-text: #aeaeb4; /* muted text color [default: #aeaeb4] */
    }

    /* DARK THEME */
    :is(.theme-darker, .theme-light .theme-darker) {
        --background-shading: rgba(0, 0, 0, 0.0); /* app background shading color [default: rgba(0, 0, 0, 0.6)] */
        --card-shading: rgba(0, 0, 0, 0.0);
        --popout-shading: rgba(0, 0, 0, 0.0);
        --modal-shading: rgba(0, 0, 0, 0.0);
        --input-shading: rgba(255, 255, 255, 0.05); /* inputs background shading color [default: rgba(255, 255, 255, 0.05)] */
        --normal-text: #fbfbfb; /* text color [default: #fbfbfb] */
        --muted-text: #94949c; /* muted text color [default: #94949c] */
    }

    /* ONYX THEME */
    :is(.theme-midnight, .theme-light .theme-midnight) {
        --background-shading: rgba(0, 0, 0, 0.0); /* app background shading color [default: rgba(0, 0, 0, 0.8)] */
        --card-shading: rgba(0, 0, 0, 0.0);
        --popout-shading: rgba(0, 0, 0, 0.0);
        --modal-shading: rgba(0, 0, 0, 0.0);
        --input-shading: rgba(255, 255, 255, 0.05); /* inputs background shading color [default: rgba(255, 255, 255, 0.05)] */
        --normal-text: #dcdcde; /* text color [default: #dcdcde] */
        --muted-text: #86868e; /* muted text color [default: #86868e] */
    }

    /* ADD ADDITIONAL CSS BELOW HERE */
    .info__2debe::after {
        content: "Dawnbreak Warden";
        color: var(--text-muted);
        font-size: 12px;
        line-height: 1.3333333333;
        font-weight: 400;
        font-family: var(--font-primary)
    }

    .visual-refresh:not(.platform-osx) .leading_c38106::before {
        content: "Dawnbreak Warden";
        position: static;
        margin-left: 10px;
        font-size: 16px;
        font-weight: 600;
        color: var(--text-default);
        order: 2;
        filter: drop-shadow(0 0 5px var(--hsl-main-color))
    }
    .visual-refresh:not(.platform-osx) .leading_c38106::after {
        content: "";
        position: static;
        margin-top: -5px;
        margin-left: 5px;
        font-family: var(--code-font);
        font-size: 11px;
        font-weight: 600;
        color: var(--text-muted);
        order: 3
    }
  '';
}
