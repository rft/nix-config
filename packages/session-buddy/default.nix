{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
  jq,
}:

# Session Buddy v4 dropped v3's right-click "Save session" menu. This repacks the
# Web Store build with a context menu that triggers the page's own "Save tabs"
# command, so saves land in the normal collections list. The manifest keeps its
# `key`, so the unpacked copy has the store ID and reads the same IndexedDB data.
stdenvNoCC.mkDerivation {
  pname = "session-buddy";
  version = "4.1.2";

  # The Web Store only serves the latest version — bump the hash (and check the
  # patch still applies) whenever Session Buddy updates.
  src = fetchurl {
    name = "session-buddy.crx";
    url = "https://clients2.google.com/service/update2/crx?response=redirect&prodversion=140.0&acceptformat=crx2,crx3&x=id%3Dedacconmaakjimmfgnblocblbcdcpbko%26uc";
    hash = "sha256-XZSwJX3SS8XfBY1u3JFRPVSCwm1sMA6UNOcqll7Scqo=";
  };

  nativeBuildInputs = [
    unzip
    jq
  ];

  # A CRX is a zip with a signature header; unzip warns about it and exits 1.
  unpackPhase = ''
    mkdir source && cd source
    unzip -q "$src" || [ $? -eq 1 ]
    rm -rf _metadata
  '';

  buildPhase = ''
    jq '.permissions += ["contextMenus"] | del(.update_url)' manifest.json > manifest.tmp
    mv manifest.tmp manifest.json

    # The page only handles its command while it is the active tab; also accept
    # the same command as a message addressed to this tab.
    substituteInPlace main.bundle.js --replace-fail \
      'chrome.commands.onCommand.addListener(e),function(){chrome.commands.onCommand.removeListener(e)}' \
      'chrome.commands.onCommand.addListener(e),chrome.runtime.onMessage.addListener(e.nixMsg=function(m,s,r){if(m&&m.nixSbCommand&&s.id===chrome.runtime.id){chrome.tabs.getCurrent().then(function(t){t&&t.id===m.tabId&&e(m.nixSbCommand,t)});r(!0)}}),function(){chrome.commands.onCommand.removeListener(e),chrome.runtime.onMessage.removeListener(e.nixMsg)}'

    cat ${./context-menu.js} >> background.bundle.js
  '';

  installPhase = ''
    cp -r . $out
  '';

  meta = {
    description = "Session Buddy with a right-click \"Save session\" menu";
    homepage = "https://sessionbuddy.com";
    license = lib.licenses.unfree;
    platforms = lib.platforms.all;
  };
}
