# GitHub → Linear Reviews

Chrome extension. When a tab goes to a GitHub pull request (`github.com/<owner>/<repo>/pull/<n>`
and its sub-pages), it opens the PR in Linear Reviews in the desktop app
(`linear://linear.app/review/<owner>/<repo>/pull/<n>`), then steps the tab back, or closes it
if the tab was opened only for that PR.

GitHub stays reachable when you come from Linear: its "Open in GitHub" link adds
`?from=linear`, and that tab can then browse that PR on GitHub until it closes. You can also
add `?from=linear` by hand.

To open reviews in the browser instead of the desktop app, set `OPEN_IN_DESKTOP = false` in
`rules.js`.

Installed by `.chezmoiscripts/run_onchange_after_install-github-to-linear-extension.sh.tmpl`.
