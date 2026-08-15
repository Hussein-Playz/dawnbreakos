{host, ...}: let
  vars = import ../../hosts/${host}/variables.nix;
  keyboardLayout = vars.keyboardLayout or "us";
  keyboardVariant = vars.keyboardVariant or "";

  # Treat only known US-based variants as implying layout = "us".
  usVariants = ["dvorak" "colemak" "workman" "intl" "us-intl" "altgr-intl"];
  normalizeUSVariant = v:
    if v == "us-intl"
    then "intl"
    else v;

  # If layout itself is a US variant (e.g., "dvorak", "us-intl"), normalize it
  layoutFromLayout =
    if builtins.elem keyboardLayout usVariants
    then "us"
    else keyboardLayout;
  variantFromLayout =
    if builtins.elem keyboardLayout usVariants
    then normalizeUSVariant keyboardLayout
    else "";

  # If the provided variant is a US variant, force layout to us; otherwise keep layout
  layoutFromVariant =
    if builtins.elem keyboardVariant usVariants
    then "us"
    else layoutFromLayout;
  variantFinal =
    if builtins.elem keyboardVariant usVariants
    then normalizeUSVariant keyboardVariant
    else if variantFromLayout != ""
    then variantFromLayout
    else keyboardVariant;

  xkbLayout = layoutFromVariant;
  xkbVariant = variantFinal;
in {
  services.xserver = {
    enable = false;
    xkb = {
      layout = xkbLayout;
      variant = xkbVariant;
    };
  };
}
