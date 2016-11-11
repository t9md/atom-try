## 0.5.0
- Fix: Deprecation warning calling old `GrammarRegistry.setGrammarOverrideForPath` #2

## 0.4.0
- Fix: When extension is not found in scope2extname table, it add unnecessary extra `.` as extension.

## 0.3.0
- Open try file adjacentPane if available
- new `try:open-file` command which allows to specify file extension.

## 0.2.8 - FIX
- Fix deprecation warn from Atom v1.1.0.
- Update readme to follow vim-mode's command-mode to normal-mode

## 0.2.6 - Improve
- More precise cursor scope detection.

## 0.2.5 - Improve
- Remove spec, its not used.
- Use atom-config-plus
- Separate config as settings.coffee

## 0.2.4 - Improve
- Fix deprecated API.Prep for Atom 1.0 API
- Add configuration order.

## 0.2.3 - improve
- scope2extname coverage is now OK.
- [FIX] scope determination is now precise.
- [DEPRECATE] deprecate `autosave` option, its difficult to handle.
- [FIX] no longer depend global `path`.

## 0.2.2 - improve
- New option `try.split` where to open try buffer. default 'none'
- New option `try.searchAllPanes` to open existing buffer.

## 0.2.1 - improve
- Now `try:paste` open try buffer even if selection is empty
- New option `try.clearSelection` to clear original selection, default true.

## 0.2.0 - improve
- `select` option (default: true)
- `autoIndent` option (default: false)
- deprecated `pasteToBottom` option.
- `pasteTo` option (default: "bottom")

## 0.1.1 - Add GIF anime.
## 0.1.0 - First Release
