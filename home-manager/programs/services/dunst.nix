{ colors, font, ... }: {
  services. dunst = {
    enable = true;

    settings = {
      global = {
        width = 500;
        height = 300;

        offset = "10x53";
        origin = "top-right";

        transparency = 10;
        frame_width = 1;

        frame_color = colors.background.secondary;
        font = font.primary;

        mouse_left = "do_action";
        mouse_middle = "close_current";
        mouse_right = "context";
      };

      urgency_normal = {
        background = colors.background.primary;
        foreground = colors.text.primary;
        timeout = 10;
      };
    };
  };

}
