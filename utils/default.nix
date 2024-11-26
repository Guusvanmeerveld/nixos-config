{...}: rec {
  hexToDecimal = hex: (builtins.fromTOML "a = 0x${hex}").a;

  makeTransparent = hex: transparancy: let
    r = hexToDecimal (builtins.substring 1 2 hex);
    g = hexToDecimal (builtins.substring 3 2 hex);
    b = hexToDecimal (builtins.substring 5 2 hex);
    a = transparancy; # Set your desired alpha value here (0.0 to 1.0)
  in "rgba(${toString r}, ${toString g}, ${toString b}, ${toString a})";
}
