{lib, ...}: {
  programs.fuzzel = {
    enable = true;

    settings = {
      main = lib.mkForce {
        font = "Google Sans Flex:weight=medium";
        terminal = "kitty -1";
        prompt = ">>  ";
        layer = "overlay";
      };

      border = lib.mkForce {
        radius = 17;
        width = 1;
      };

      dmenu = lib.mkForce {
        exit-immediately-if-empty = "yes";
      };

      colors = lib.mkForce {
        background = "161217ff";
        text = "e9e0e8ff";
        selection = "4b454dff";
        selection-text = "cdc3ceff";
        border = "4b454ddd";
        match = "dfb8f6ff";
        selection-match = "dfb8f6ff";
      };
    };
  };
}
