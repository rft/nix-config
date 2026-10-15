
// Appended by packages/session-buddy: right-click "Save session".
{
  const menuId = "nix-save-session";
  const mainPages = ["/session-buddy.html", "/main.html", "/mainUI.html", "/m.html"];

  chrome.contextMenus.removeAll(() =>
    chrome.contextMenus.create({
      id: menuId,
      title: "Save session",
      contexts: ["page", "frame", "selection", "link", "image", "video", "audio", "editable", "action"],
    }),
  );

  chrome.contextMenus.onClicked.addListener(async (info, tab) => {
    if (info.menuItemId !== menuId) return;

    const base = chrome.runtime.getURL("");
    const open = await chrome.tabs.query({});
    let page = open.find((t) => t.url?.startsWith(base) && mainPages.includes(new URL(t.url).pathname));
    if (page) {
      await chrome.tabs.update(page.id, { active: true });
      await chrome.windows.update(page.windowId, { focused: true });
    } else {
      page = await chrome.tabs.create({ url: base + "session-buddy.html", windowId: tab?.windowId });
    }

    // A freshly opened page needs a moment before its listener is registered.
    for (let i = 0; i < 50; i++) {
      try {
        if (await chrome.tabs.sendMessage(page.id, { nixSbCommand: "save-session", tabId: page.id })) return;
      } catch {}
      await new Promise((r) => setTimeout(r, 200));
    }
    console.error("Session Buddy page never answered the save request");
  });
}
