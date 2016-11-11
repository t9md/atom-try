# Try
Paste texts to predetermined place.

![gif](https://raw.githubusercontent.com/t9md/t9md/12fba4ff60861ae1acd973407c93a62edf61c956/img/atom-try.gif)

# Why?

While I'm reading code and encounter the code which I can not understand how it works.  
What I should do in such situation is **try** that code and see how it works.  
This package improve your repetitive copy and paste workflow into one step.

1. Select buffer
2. Invoke `try:paste` command.
3. Your selected code is pasted at bottom of try buffer.
4. Start try&see by running script runner package like [script](https://atom.io/packages/script).

# Features

- Paste selected text to bottom of `try` buffer by default.
- Without selection, simply open `try` buffer.
- `try` buffer is merely simple file, not special scratch buffer.

# Commands
- `try:paste`: paste to try file.
- `try:open-file`: open try file by reading extension from user interactively.

# How to use

Select text in editor then
- Invoke `try:paste` via command palette or keymap.

# Keymap
No keymap by default.

e.g.

* With `F10`

```coffeescript
'atom-text-editor:not([mini])':
  'f10': 'try:paste'
```

* if you are using  [vim-mode-plus](https://atom.io/packages/vim-mode-plus), following are suggestion which I use.

```coffeescript
'atom-text-editor.vim-mode-plus.normal-mode':
  'space T': 'try:open-file'
  'T': 'try:paste'
'atom-text-editor.vim-mode.visual-mode':
  'T': 'try:paste'
```
