#!/usr/bin/env python3
"""Dawnbreak's local, wallpaper/scheme-focused Caelestia compatibility CLI.

The Material You palette generation follows the Caelestia CLI's GPL-3.0
implementation (caelestia-dots/cli, utils/material/{generator,score}.py).
Only the wallpaper and scheme operations used by this Quickshell config are
implemented here; this is not the upstream Caelestia CLI.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import random
import subprocess
import sys
from pathlib import Path
from typing import Any

from materialyoucolor.blend import Blend
from materialyoucolor.dislike.dislike_analyzer import DislikeAnalyzer
from materialyoucolor.dynamiccolor.material_dynamic_colors import MaterialDynamicColors
from materialyoucolor.hct import Hct
from materialyoucolor.quantize import ImageQuantizeCelebi
from materialyoucolor.scheme.scheme_content import SchemeContent
from materialyoucolor.scheme.scheme_expressive import SchemeExpressive
from materialyoucolor.scheme.scheme_fidelity import SchemeFidelity
from materialyoucolor.scheme.scheme_fruit_salad import SchemeFruitSalad
from materialyoucolor.scheme.scheme_monochrome import SchemeMonochrome
from materialyoucolor.scheme.scheme_neutral import SchemeNeutral
from materialyoucolor.scheme.scheme_rainbow import SchemeRainbow
from materialyoucolor.scheme.scheme_tonal_spot import SchemeTonalSpot
from materialyoucolor.scheme.scheme_vibrant import SchemeVibrant
from materialyoucolor.utils.color_utils import argb_from_rgb
from materialyoucolor.utils.math_utils import (
    difference_degrees,
    rotation_direction,
    sanitize_degrees_double,
    sanitize_degrees_int,
)
from PIL import Image

VERSION = "0.1.0"
SCHEME_VARIANTS = (
    "tonalspot", "vibrant", "expressive", "fidelity", "fruitsalad",
    "monochrome", "neutral", "rainbow", "content",
)
IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp", ".tif", ".tiff", ".gif", ".bmp"}
VIDEO_EXTENSIONS = {".mp4", ".mkv", ".webm", ".mov", ".avi"}

HOME = Path.home()
STATE = Path(os.environ.get("XDG_STATE_HOME", HOME / ".local/state")) / "dawnbreak"
CACHE = Path(os.environ.get("XDG_CACHE_HOME", HOME / ".cache")) / "dawnbreak"
SCHEME_PATH = STATE / "scheme.json"
WALLPAPER_PATH = STATE / "wallpaper/path.txt"
THUMBNAIL_PATH = STATE / "wallpaper/thumbnail.jpg"


def atomic_json(path: Path, data: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temp = path.with_suffix(path.suffix + ".tmp")
    temp.write_text(json.dumps(data, separators=(",", ":")))
    temp.replace(path)


def read_scheme() -> dict[str, Any]:
    try:
        data = json.loads(SCHEME_PATH.read_text())
        if data.get("name") == "dynamic":
            return data
    except (OSError, json.JSONDecodeError):
        pass
    return {
        "name": "dynamic",
        "flavour": "default",
        "mode": "dark",
        "variant": "tonalspot",
        "colours": {},
    }


def hex_to_hct(value: str) -> Hct:
    return Hct.from_int(int(f"0xFF{value}", 16))


LIGHT_TERMINAL = [
    "FDF9F3", "FF6188", "A9DC76", "FC9867", "FFD866", "F47FD4", "78DCE8", "333034",
    "121212", "FF6188", "A9DC76", "FC9867", "FFD866", "F47FD4", "78DCE8", "333034",
]
DARK_TERMINAL = [
    "282828", "CC241D", "98971A", "D79921", "458588", "B16286", "689D6A", "A89984",
    "928374", "FB4934", "B8BB26", "FABD2F", "83A598", "D3869B", "8EC07C", "EBDBB2",
]
LIGHT_CATPPUCCIN = [
    "dc8a78", "dd7878", "ea76cb", "8839ef", "d20f39", "e64553", "fe640b", "df8e1d",
    "40a02b", "179299", "04a5e5", "209fb5", "1e66f5", "7287fd",
]
DARK_CATPPUCCIN = [
    "f5e0dc", "f2cdcd", "f5c2e7", "cba6f7", "f38ba8", "eba0ac", "fab387", "f9e2af",
    "a6e3a1", "94e2d5", "89dceb", "74c7ec", "89b4fa", "b4befe",
]
NAMED_COLOURS = [
    "rosewater", "flamingo", "pink", "mauve", "red", "maroon", "peach", "yellow",
    "green", "teal", "sky", "sapphire", "blue", "lavender",
]
K_COLOURS = [
    ("klink", "2980b9"), ("kvisited", "9b59b6"), ("knegative", "da4453"),
    ("kneutral", "f67400"), ("kpositive", "27ae60"),
]


def image_score(image: Path) -> Hct:
    colours_to_population = ImageQuantizeCelebi(str(image), 1, 128)
    hue_population = [0] * 360
    population_sum = 0
    hcts: list[tuple[Hct, int]] = []
    for rgb, population in colours_to_population.items():
        hct = Hct.from_int(rgb)
        hcts.append((hct, population))
        hue_population[int(hct.hue)] += population
        population_sum += population

    excited = [0.0] * 360
    if population_sum == 0:
        raise ValueError("No colours could be extracted from the wallpaper")
    for hue in range(360):
        proportion = hue_population[hue] / population_sum
        for neighbour in range(hue - 14, hue + 16):
            excited[int(sanitize_degrees_int(neighbour))] += proportion

    scored: list[tuple[Hct, float]] = []
    for hct, _population in hcts:
        hue = int(sanitize_degrees_int(round(hct.hue)))
        proportion = excited[hue]
        proportion_score = proportion * 100.0 * 0.7
        chroma_weight = 0.1 if hct.chroma < 48.0 else 0.3
        scored.append((hct, proportion_score + (hct.chroma - 48.0) * chroma_weight))
    scored.sort(key=lambda item: item[1], reverse=True)

    for cutoff in range(20, -1, -1):
        for hct, _score in scored:
            if hct.chroma > cutoff and hct.tone > cutoff * 3:
                return DislikeAnalyzer.fix_if_disliked(hct)
    if scored:
        return DislikeAnalyzer.fix_if_disliked(scored[0][0])
    raise ValueError("No suitable wallpaper colour was found")


def get_variant(image: Path) -> str:
    with Image.open(image) as source:
        image_rgb = source.convert("RGB")
        image_rgb.thumbnail((128, 128), Image.Resampling.NEAREST)
        pixels = list(image_rgb.getdata())
    rg = [abs(r - g) for r, g, _b in pixels]
    yb = [abs(0.5 * (r + g) - b) for r, g, b in pixels]

    def mean(values: list[float]) -> float:
        return sum(values) / len(values) if values else 0.0

    def stddev(values: list[float], avg: float) -> float:
        return (sum((value - avg) ** 2 for value in values) / len(values)) ** 0.5 if values else 0.0

    mean_rg, mean_yb = mean(rg), mean(yb)
    colourfulness = (stddev(rg, mean_rg) ** 2 + stddev(yb, mean_yb) ** 2) ** 0.5
    colourfulness += 0.3 * (mean_rg**2 + mean_yb**2) ** 0.5
    if colourfulness < 10:
        return "neutral"
    if colourfulness < 20:
        return "content"
    return "tonalspot"


def extract_frame(wallpaper: Path) -> Path:
    digest_builder = hashlib.sha256()
    with wallpaper.open("rb") as source:
        while chunk := source.read(1024 * 1024):
            digest_builder.update(chunk)
    digest = digest_builder.hexdigest()
    cache_dir = CACHE / "wallpapers" / digest
    cache_dir.mkdir(parents=True, exist_ok=True)
    frame = cache_dir / "first_frame.png"
    if frame.exists():
        return frame
    if wallpaper.suffix.lower() in VIDEO_EXTENSIONS:
        subprocess.run(
            ["ffmpeg", "-y", "-loglevel", "error", "-i", str(wallpaper), "-frames:v", "1", str(frame)],
            check=True,
            stdin=subprocess.DEVNULL,
        )
    else:
        with Image.open(wallpaper) as image:
            try:
                image.seek(0)
            except EOFError:
                pass
            image.convert("RGB").save(frame, "PNG")
    return frame


def make_thumbnail(image_path: Path) -> Path:
    digest = hashlib.sha256(image_path.read_bytes()).hexdigest()
    cache_dir = CACHE / "wallpapers" / digest
    cache_dir.mkdir(parents=True, exist_ok=True)
    thumb = cache_dir / "thumbnail.jpg"
    if not thumb.exists():
        with Image.open(image_path) as image:
            image = image.convert("RGB")
            image.thumbnail((128, 128), Image.Resampling.NEAREST)
            image.save(thumb, "JPEG")
    return thumb


def choose_scheme_class(variant: str):
    return {
        "content": SchemeContent,
        "expressive": SchemeExpressive,
        "fidelity": SchemeFidelity,
        "fruitsalad": SchemeFruitSalad,
        "monochrome": SchemeMonochrome,
        "neutral": SchemeNeutral,
        "rainbow": SchemeRainbow,
        "tonalspot": SchemeTonalSpot,
    }.get(variant, SchemeVibrant)


def lighten(colour: Hct, amount: float) -> Hct:
    diff = (100 - colour.tone) * amount
    return Hct.from_hct(colour.hue, colour.chroma + diff / 5, colour.tone + diff)


def darken(colour: Hct, amount: float) -> Hct:
    diff = colour.tone * amount
    return Hct.from_hct(colour.hue, colour.chroma - diff / 5, colour.tone - diff)


def harmonize(source: Hct, target: Hct, tone_boost: float) -> Hct:
    difference = difference_degrees(source.hue, target.hue)
    rotation = min(difference * 0.8, 100)
    hue = sanitize_degrees_double(source.hue + rotation * rotation_direction(source.hue, target.hue))
    return Hct.from_hct(hue, source.chroma, source.tone * (1 + tone_boost))


def mix(a: Hct, b: Hct, weight: float) -> Hct:
    return Hct.from_int(Blend.cam16_ucs(a.to_int(), b.to_int(), weight))


def grayscale(colour: Hct, light: bool) -> Hct:
    colour = darken(colour, 0.35) if light else lighten(colour, 0.65)
    colour.chroma = 0
    return colour


def generate_colours(primary: Hct, mode: str, variant: str, flavour: str) -> dict[str, str]:
    is_light = mode == "light"
    dynamic_scheme = choose_scheme_class(variant)(source_color_hct=primary, is_dark=not is_light, contrast_level=0.0)
    colours: dict[str, Hct] = {}
    dynamic_colours = MaterialDynamicColors()
    if hasattr(dynamic_colours, "all_colors"):
        for colour in dynamic_colours.all_colors:
            colours[colour.name] = colour.get_hct(dynamic_scheme)
    else:
        for attribute in vars(MaterialDynamicColors).keys():
            colour = getattr(MaterialDynamicColors, attribute)
            if hasattr(colour, "get_hct"):
                colours[attribute] = colour.get_hct(dynamic_scheme)

    if "primaryPaletteKeyColor" in colours:
        for name in ("primary", "secondary", "tertiary", "neutral"):
            colours[f"{name}_paletteKeyColor"] = colours[f"{name}PaletteKeyColor"]
        colours["neutral_variant_paletteKeyColor"] = colours["neutralVariantPaletteKeyColor"]

    for index, hex_colour in enumerate(LIGHT_TERMINAL if is_light else DARK_TERMINAL):
        hct = hex_to_hct(hex_colour)
        colours[f"term{index}"] = grayscale(hct, is_light) if variant == "monochrome" else harmonize(
            hct, colours["primary_paletteKeyColor"], (0.35 if index < 8 else 0.2) * (-1 if is_light else 1)
        )

    for index, hex_colour in enumerate(LIGHT_CATPPUCCIN if is_light else DARK_CATPPUCCIN):
        hct = hex_to_hct(hex_colour)
        colours[NAMED_COLOURS[index]] = grayscale(hct, is_light) if variant == "monochrome" else harmonize(
            hct, colours["primary_paletteKeyColor"], -0.2 if is_light else 0.05
        )

    for name, hex_colour in K_COLOURS:
        hct = hex_to_hct(hex_colour)
        colours[name] = harmonize(hct, colours["primary"], 0.1)
        colours[f"{name}Selection"] = harmonize(hct, colours["onPrimaryFixedVariant"], 0.1)
        if variant == "monochrome":
            colours[name] = grayscale(colours[name], is_light)
            colours[f"{name}Selection"] = grayscale(colours[f"{name}Selection"], is_light)

    if variant == "neutral":
        for colour in colours.values():
            colour.chroma -= 15

    if flavour == "hard":
        for name in ("background", *(key for key in colours if key.startswith("surface"))):
            colours[name] = lighten(colours[name], 0.4) if is_light else darken(colours[name], 0.8)
        colours["term0"] = lighten(colours["term0"], 0.4) if is_light else darken(colours["term0"], 0.9)

    colours["text"] = colours["onBackground"]
    colours["subtext1"] = colours["onSurfaceVariant"]
    colours["subtext0"] = colours["outline"]
    colours["overlay2"] = mix(colours["surface"], colours["outline"], 0.86)
    colours["overlay1"] = mix(colours["surface"], colours["outline"], 0.71)
    colours["overlay0"] = mix(colours["surface"], colours["outline"], 0.57)
    colours["surface2"] = mix(colours["surface"], colours["outline"], 0.43)
    colours["surface1"] = mix(colours["surface"], colours["outline"], 0.29)
    colours["surface0"] = mix(colours["surface"], colours["outline"], 0.14)
    colours["base"] = colours["surface"]
    colours["mantle"] = darken(colours["surface"], 0.03)
    colours["crust"] = darken(colours["surface"], 0.05)

    if flavour == "hard":
        for name in ("base", "mantle", "crust"):
            colours[name] = lighten(colours[name], 0.4) if is_light else darken(colours[name], 0.9)
        for index in range(3):
            for prefix in ("overlay", "surface"):
                key = f"{prefix}{index}"
                colours[key] = lighten(colours[key], 0.4) if is_light else darken(colours[key], 0.8)

    output = {name: f"{colour.to_int():08x}"[2:] for name, colour in colours.items()}
    output.update({
        "success": "4F6354" if is_light else "B5CCBA",
        "onSuccess": "FFFFFF" if is_light else "213528",
        "successContainer": "D1E8D5" if is_light else "374B3E",
        "onSuccessContainer": "0C1F13" if is_light else "D1E9D6",
    })
    return output


def generate_scheme(wallpaper: Path, no_smart: bool = False, mode_override: str | None = None) -> dict[str, Any]:
    if not wallpaper.is_file() or wallpaper.suffix.lower() not in IMAGE_EXTENSIONS | VIDEO_EXTENSIONS:
        raise ValueError(f"Not a supported wallpaper file: {wallpaper}")
    frame = extract_frame(wallpaper)
    thumb = make_thumbnail(frame)
    previous = read_scheme()
    flavour = previous.get("flavour", "default")
    variant = previous.get("variant", "tonalspot")
    mode = mode_override or previous.get("mode", "dark")

    if not no_smart:
        variant = get_variant(thumb)
        if mode_override is None:
            with Image.open(thumb) as image:
                pixel_image = image.convert("RGB")
                pixel_image.thumbnail((1, 1), Image.Resampling.LANCZOS)
                pixel = pixel_image.getpixel((0, 0))
            mode = "light" if Hct.from_int(argb_from_rgb(*pixel)).tone > 60 else "dark"

    primary = image_score(thumb)
    colours = generate_colours(primary, mode, variant, flavour)
    return {
        "name": "dynamic",
        "flavour": flavour,
        "mode": mode,
        "variant": variant,
        "colours": colours,
    }


def run_switchwall(wallpaper: str, no_smart: bool = False) -> None:
    config_home = Path(os.environ.get("XDG_CONFIG_HOME", HOME / ".config"))
    script = config_home / "quickshell/ii/scripts/colors/switchwall.sh"
    if not script.is_file():
        raise FileNotFoundError(f"Wallpaper switch script not found: {script}")
    env = dict(os.environ)
    if no_smart:
        env["DAWNBREAK_NO_SMART_SCHEME"] = "1"
    wallpaper_path = str(Path(wallpaper).expanduser().resolve())
    subprocess.run([str(script), "--image", wallpaper_path], check=True, env=env)


def cmd_wallpaper(args: argparse.Namespace) -> None:
    if args.print_path is not None:
        if not args.print_path:
            raise FileNotFoundError("No wallpaper path is available for preview")
        wallpaper = Path(args.print_path).expanduser().resolve()
        scheme = generate_scheme(wallpaper, args.no_smart)
        print(json.dumps(scheme))
        return
    if args.file:
        run_switchwall(args.file, args.no_smart)
        return
    if args.random:
        directory = Path(args.random).expanduser()
        if not directory.is_dir():
            raise FileNotFoundError(f"Wallpaper directory not found: {directory}")
        candidates = [path for path in directory.rglob("*") if path.suffix.lower() in IMAGE_EXTENSIONS | VIDEO_EXTENSIONS]
        if not candidates:
            raise FileNotFoundError(f"No supported wallpapers found in {directory}")
        current = WALLPAPER_PATH.read_text().strip() if WALLPAPER_PATH.exists() else ""
        candidates = [path for path in candidates if str(path.resolve()) != current] or candidates
        run_switchwall(str(random.choice(candidates).resolve()), args.no_smart)
        return
    print(WALLPAPER_PATH.read_text().strip() if WALLPAPER_PATH.exists() else "No wallpaper set")


def cmd_generate(args: argparse.Namespace) -> None:
    wallpaper = Path(args.image).expanduser().resolve()
    scheme = generate_scheme(wallpaper, args.no_smart, args.mode)
    atomic_json(SCHEME_PATH, scheme)
    WALLPAPER_PATH.parent.mkdir(parents=True, exist_ok=True)
    WALLPAPER_PATH.write_text(str(wallpaper))
    frame = extract_frame(wallpaper)
    thumb = make_thumbnail(frame)
    THUMBNAIL_PATH.parent.mkdir(parents=True, exist_ok=True)
    THUMBNAIL_PATH.unlink(missing_ok=True)
    THUMBNAIL_PATH.symlink_to(thumb)


def cmd_scheme(args: argparse.Namespace) -> None:
    current = read_scheme()
    if args.action == "get":
        for enabled, key in ((args.name, "name"), (args.flavour, "flavour"), (args.mode, "mode"), (args.variant, "variant")):
            if enabled:
                print(current[key])
        return

    if args.action == "list":
        variants = current.get("variant", "tonalspot")
        wallpaper = WALLPAPER_PATH.read_text().strip() if WALLPAPER_PATH.exists() else ""
        if wallpaper and Path(wallpaper).is_file():
            wall = Path(wallpaper)
            frame = extract_frame(wall)
            thumb = make_thumbnail(frame)
            primary = image_score(thumb)
            default = generate_scheme(wall, no_smart=True)
            default["flavour"] = "default"
            default["colours"] = generate_colours(primary, default["mode"], variants, "default")
            hard_colours = generate_colours(primary, default["mode"], variants, "hard")
        else:
            default = current
            hard_colours = current.get("colours", {})
        print(json.dumps({"dynamic": {"default": default["colours"], "hard": hard_colours}}))
        return

    if args.name and args.name != "dynamic":
        raise ValueError("This local CLI currently implements the dynamic scheme only")
    if args.flavour:
        if args.flavour not in ("default", "hard"):
            raise ValueError("Dynamic flavour must be 'default' or 'hard'")
        current["flavour"] = args.flavour
    if args.mode:
        current["mode"] = args.mode
    if args.variant:
        if args.variant not in SCHEME_VARIANTS:
            raise ValueError(f"Unsupported variant: {args.variant}")
        current["variant"] = args.variant

    wallpaper = WALLPAPER_PATH.read_text().strip() if WALLPAPER_PATH.exists() else ""
    if not wallpaper or not Path(wallpaper).is_file():
        raise FileNotFoundError("No wallpaper is recorded yet; set one before selecting the dynamic scheme")
    updated = generate_scheme(Path(wallpaper), no_smart=True, mode_override=current["mode"])
    updated["flavour"] = current["flavour"]
    updated["variant"] = current["variant"]
    frame = make_thumbnail(extract_frame(Path(wallpaper)))
    updated["colours"] = generate_colours(image_score(frame), updated["mode"], updated["variant"], updated["flavour"])
    atomic_json(SCHEME_PATH, updated)


def main() -> int:
    parser = argparse.ArgumentParser(prog="dawnbreak-shell-cli", description="Local wallpaper and Material You palette helper for DawnbreakOS")
    parser.add_argument("--version", action="version", version=f"dawnbreak-shell-cli {VERSION}")
    commands = parser.add_subparsers(dest="command", required=True)

    wallpaper = commands.add_parser("wallpaper", help="switch wallpaper or generate a palette preview")
    wallpaper.add_argument("-f", "--file")
    wallpaper.add_argument("-p", "--print", dest="print_path", nargs="?", const="")
    wallpaper.add_argument("-r", "--random", nargs="?", const=str(HOME / "Pictures/Wallpapers"))
    wallpaper.add_argument("-N", "--no-smart", action="store_true")
    wallpaper_sub = wallpaper.add_subparsers(dest="wallpaper_action")
    generate = wallpaper_sub.add_parser("generate", help=argparse.SUPPRESS)
    generate.add_argument("--image", required=True)
    generate.add_argument("--mode", choices=("dark", "light"))
    generate.add_argument("--no-smart", action="store_true")

    scheme = commands.add_parser("scheme", help="manage the dynamic Material You palette")
    scheme_sub = scheme.add_subparsers(dest="action", required=True)
    get = scheme_sub.add_parser("get")
    get.add_argument("-n", "--name", action="store_true")
    get.add_argument("-f", "--flavour", action="store_true")
    get.add_argument("-m", "--mode", action="store_true")
    get.add_argument("-v", "--variant", action="store_true")
    listing = scheme_sub.add_parser("list")
    listing.add_argument("-n", "--names", action="store_true")
    listing.add_argument("-f", "--flavours", action="store_true")
    listing.add_argument("-m", "--modes", action="store_true")
    listing.add_argument("-v", "--variants", action="store_true")
    setting = scheme_sub.add_parser("set")
    setting.add_argument("--notify", action="store_true")
    setting.add_argument("-n", "--name")
    setting.add_argument("-f", "--flavour")
    setting.add_argument("-m", "--mode", choices=("dark", "light"))
    setting.add_argument("-v", "--variant", choices=SCHEME_VARIANTS)

    args = parser.parse_args()
    try:
        if args.command == "wallpaper":
            if args.wallpaper_action == "generate":
                cmd_generate(args)
            else:
                if args.print_path == "":
                    args.print_path = WALLPAPER_PATH.read_text().strip() if WALLPAPER_PATH.exists() else ""
                cmd_wallpaper(args)
        elif args.command == "scheme":
            if args.action == "list":
                if args.names:
                    print("dynamic")
                elif args.flavours:
                    print("default\nhard")
                elif args.modes:
                    print("light\ndark")
                elif args.variants:
                    print("\n".join(SCHEME_VARIANTS))
                else:
                    cmd_scheme(args)
            else:
                cmd_scheme(args)
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        print(f"dawnbreak-shell-cli: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
