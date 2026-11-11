// Set to false to open reviews in the browser (linear.app) instead of the desktop app.
export const OPEN_IN_DESKTOP = true;

// Linear adds this to its "Open in GitHub" links.
const ESCAPE_PARAM = "from";
const ESCAPE_VALUE = "linear";

// Returns { key, owner, repo, number, escaped } for a GitHub PR page URL, or null.
// Matches /owner/repo/pull/123 and its sub-pages (files, commits, checks, ...).
export function parsePullRequest(rawUrl) {
  let url;
  try {
    url = new URL(rawUrl);
  } catch {
    return null;
  }
  if (url.hostname !== "github.com") return null;

  const match = url.pathname.match(/^\/([^/]+)\/([^/]+)\/pull\/(\d+)(?:\/|$)/);
  if (!match) return null;

  const [, owner, repo, number] = match;
  return {
    key: `${owner}/${repo}#${number}`.toLowerCase(),
    owner,
    repo,
    number,
    escaped: url.searchParams.get(ESCAPE_PARAM) === ESCAPE_VALUE,
  };
}

// linear.app/review/<owner>/<repo>/pull/<n> resolves to the review page in your workspace
// (this is where linear.review/<owner>/<repo>/pull/<n> redirects to).
export function linearReviewUrl(pr, desktop = OPEN_IN_DESKTOP) {
  const path = `linear.app/review/${pr.owner}/${pr.repo}/pull/${pr.number}`;
  return desktop ? `linear://${path}` : `https://${path}`;
}
