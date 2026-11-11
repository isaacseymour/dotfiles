import { OPEN_IN_DESKTOP, parsePullRequest, linearReviewUrl } from "./rules.js";

// Per-tab list of PRs you reached from Linear (?from=linear). GitHub drops the param as soon
// as you click around inside the PR, so remember it for the life of the tab.
const ALLOW_KEY = "allowedByTab";

async function getAllowed() {
  const { [ALLOW_KEY]: allowed = {} } = await chrome.storage.session.get(ALLOW_KEY);
  return allowed;
}

async function allow(tabId, key) {
  const allowed = await getAllowed();
  const keys = new Set(allowed[tabId] || []);
  keys.add(key);
  allowed[tabId] = [...keys];
  await chrome.storage.session.set({ [ALLOW_KEY]: allowed });
}

async function isAllowed(tabId, key) {
  const allowed = await getAllowed();
  return (allowed[tabId] || []).includes(key);
}

chrome.tabs.onRemoved.addListener(async (tabId) => {
  const allowed = await getAllowed();
  if (allowed[tabId]) {
    delete allowed[tabId];
    await chrome.storage.session.set({ [ALLOW_KEY]: allowed });
  }
});

// Tabs we are already redirecting, so the several navigation events for one click
// do not launch Linear more than once.
const inFlight = new Set();

function isBlankPage(url) {
  return !url || url === "about:blank" || url.startsWith("chrome://newtab");
}

async function handle(details) {
  if (details.frameId !== 0) return;

  const pr = parsePullRequest(details.url);
  if (!pr) return;

  const { tabId } = details;
  if (pr.escaped) {
    await allow(tabId, pr.key);
    return;
  }
  if (await isAllowed(tabId, pr.key)) return;
  if (inFlight.has(tabId)) return;
  inFlight.add(tabId);

  try {
    const target = linearReviewUrl(pr);

    if (!OPEN_IN_DESKTOP) {
      await chrome.tabs.update(tabId, { url: target });
      return;
    }

    // An external-protocol navigation leaves the tab on whatever it showed before.
    await chrome.tabs.update(tabId, { url: target });

    // Then get rid of the GitHub page: step back to where you were, or close the tab
    // if it was opened just for this PR (from Slack, email, ...).
    setTimeout(async () => {
      try {
        const tab = await chrome.tabs.get(tabId);
        if (isBlankPage(tab.url) || parsePullRequest(tab.url)) {
          try {
            await chrome.tabs.goBack(tabId);
          } catch {
            await chrome.tabs.remove(tabId); // no history to go back to
          }
        }
      } catch {
        // Tab already gone.
      } finally {
        inFlight.delete(tabId);
      }
    }, 1500);
  } finally {
    if (!OPEN_IN_DESKTOP) inFlight.delete(tabId);
  }
}

const filter = { url: [{ hostEquals: "github.com", pathContains: "/pull/" }] };

chrome.webNavigation.onBeforeNavigate.addListener(
  handle,
  filter,
);

// GitHub is a single-page app: clicking a PR link from a list or an issue does not
// do a full page load.
chrome.webNavigation.onHistoryStateUpdated.addListener(
  handle,
  filter,
);
