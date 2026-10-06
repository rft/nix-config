# The 16 ANSI colours for the titanium palette, in order color0..color15.
# Used by vscodium's integrated terminal.
let
  t = import ./titanium-palette.nix;
in
[
  t.subtleGray # black
  t.alertRed # red
  t.readoutGreen # green
  t.warningAmber # yellow
  t.deepBlue # blue
  t.titaniumGold # magenta
  t.electricBlue # cyan
  t.dimAluminum # white
  t.comment # bright black
  t.alertRed # bright red
  t.readoutGreen # bright green
  t.warningAmber # bright yellow
  t.electricBlue # bright blue
  t.titaniumGold # bright magenta
  t.electricBlue # bright cyan
  t.brightAluminum # bright white
]
