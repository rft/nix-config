# TextMate scope rules for the titanium palette. Shared by vscodium's token
# colours and bat's tmTheme so code highlights the same in both.
let
  t = import ./titanium-palette.nix;
  rule = scope: foreground: fontStyle: { inherit scope foreground fontStyle; };
in
[
  (rule [ "comment" "punctuation.definition.comment" ] t.comment "italic")
  (rule [ "keyword" "storage" "storage.type" "keyword.control" ] t.electricBlue null)
  (rule [ "keyword.operator" "punctuation" ] t.dimAluminum null)
  (rule [ "string" "string.quoted" "string.template" ] t.readoutGreen null)
  (rule [ "constant.character.escape" "string.regexp" ] t.warningAmber null)
  (rule [ "constant.numeric" "constant.language" "constant.other" ] t.warningAmber null)
  (rule [ "entity.name.function" "support.function" "meta.function-call" ] t.titaniumGold null)
  (rule [
    "entity.name.type"
    "entity.name.class"
    "support.type"
    "support.class"
    "entity.other.inherited-class"
  ] t.deepBlue null)
  (rule [ "variable" "variable.other" "meta.definition.variable" ] t.brightAluminum null)
  (rule [ "variable.parameter" ] t.dimAluminum "italic")
  (rule [ "variable.language" "support.variable" ] t.electricBlue "italic")
  (rule [ "entity.name.tag" ] t.electricBlue null)
  (rule [ "entity.other.attribute-name" ] t.titaniumGold null)
  (rule [ "invalid" ] t.alertRed null)
  (rule [ "markup.heading" ] t.electricBlue "bold")
  (rule [ "markup.bold" ] t.titaniumGold "bold")
  (rule [ "markup.italic" ] t.brightAluminum "italic")
  (rule [ "markup.inline.raw" "markup.fenced_code" ] t.readoutGreen null)
  (rule [ "markup.underline.link" ] t.electricBlue null)
  (rule [ "markup.inserted" ] t.readoutGreen null)
  (rule [ "markup.deleted" ] t.alertRed null)
  (rule [ "markup.changed" ] t.warningAmber null)
]
