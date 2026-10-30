# Getting smart skipping into upstream jellyfin-androidtv

Checklist for turning the local smart-skip change into an accepted upstream contribution.
The maintainers cannot be forced; the goal is to make accepting the change cheap and refusing it awkward.

## The pitch in one paragraph

Skipping through a long video with the remote is slow: every press of fast forward or rewind moves a fixed
5–30 s, so a ten-minute jump takes twenty presses. Kodi solved this years ago with "skip steps"
(10s, 30s, 1m, 3m, 5m, 10m, with a 750 ms skip delay). The change is opt-in, default off, 98 lines in 6 files,
no new dependency, and it reuses the player's existing pending-skip timer.

## Step 1: feature request (before the PR)

1. Search the enhancement label first; the template makes you confirm you did:
   https://github.com/jellyfin/jellyfin-androidtv/labels/enhancement
2. Open a new issue with the "Feature request" template:
   https://github.com/jellyfin/jellyfin-androidtv/issues/new/choose
3. Link the prior art the maintainers already merged or discussed:
   - #5510 (open): holding the D-pad should repeat skips. Related, but still linear.
   - #1325 (merged 2022): stacking of repeated presses. Shows they care about this interaction.
4. Pre-empt the "legacy player" objection: PlaybackController is being replaced by the new playback module.
   Offer to port the same behaviour there once they confirm interest, otherwise the answer will be
   "will be handled in the rewrite".

Draft issue body:

```
Problem description
Skipping through a long video with the remote is slow. Each press of fast forward or rewind moves a fixed
amount (5–30 s), so jumping ten minutes takes twenty presses. Holding the button does not help (see #5510).

Proposed solution
An opt-in "smart skipping" setting next to "Skip forward length". Repeated presses within the existing skip
delay step through 5s, 30s, 1m, 5m and 15m, in the spirit of Kodi's skip steps. A press in the opposite direction
steps back. An on-screen indicator shows the pending offset (for example "+1:00"), the seek bar previews the
target on every press and the seek fires once presses stop. The d-pad left/right keys skip directly while the
controls are hidden or the seek bar has focus, so no on-screen button is needed.
Default off, no change for existing users. I have a 98-line implementation for PlaybackController ready as
a PR and can port it to the new playback module as well.

Alternatives considered
Hold-to-repeat (#5510): simpler but still linear, and long holds are hard to stop precisely.
A larger fixed skip length: makes small corrections impossible.

Additional information
Kodi defaults: skip steps 10s/30s/1m/3m/5m/10m, skip delay 750 ms.
```

## Step 2: the pull request

- Branch from current master, one commit, nothing else bundled.
- Title in the imperative: `Add smart skipping with Kodi-style skip steps`.
- Fill in the PR template (.github/pull_request_template.md):
  - **Changes**: 1–5 sentences, same content as the issue's proposed solution.
  - **Code assistance**: must be filled in. State that the code was written with LLM assistance
    (Claude Code) and reviewed and tested by you.
  - **Issues**: `Fixes #<your issue number>`.
- Only add English strings in `app/src/main/res/values/strings.xml`; Weblate handles translations.
- Before pushing: `./gradlew :app:compileDebugJavaWithJavac detekt` with JDK 21 must pass
  (CI runs `assembleDebug`, `detekt lint` and `test`).
- Contributing guide: https://jellyfin.org/docs/general/contributing/

Draft PR "Changes" section:

```
Adds an opt-in "Enable smart skipping" setting under Playback > Advanced. When enabled, repeated fast
forward or rewind presses step through 5s, 30s, 1m, 5m and 15m (a ladder in the spirit of Kodi's skip steps), a press in
the opposite direction steps back, and the seek is performed once presses stop, reusing the existing skip delay.
An on-screen indicator shows the pending offset, and the d-pad left/right keys skip directly while the controls
are hidden or the seek bar has focus.
With the setting off the configured skip lengths behave exactly as before.
```

## Step 3: after submitting

- Answer review comments within a day or two; small PRs that respond quickly get merged.
- No reaction after two weeks: one polite nudge in the PR, then ask in the Jellyfin Matrix/forum.
- If they prefer the new playback module: say yes, and port it there in a follow-up PR.
- If declined: keep the change in this fork and rebase it on every upstream release. The whole change is
  the 6 files listed in `git log -1 --stat` of the commit, so rebasing is cheap.

## References

- Kodi skip steps / skip delay settings: `videoplayer.seeksteps` and `videoplayer.seekdelay` in Kodi's
  `system/settings/settings.xml` (default steps -600,-300,-180,-60,-30,-10,10,30,60,180,300,600, delay 750 ms).
- Related upstream items: #5510, #1325.
