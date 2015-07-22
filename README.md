# Try
Paste fragment of code into try buffer then try it!

![gif](https://raw.githubusercontent.com/t9md/t9md/12fba4ff60861ae1acd973407c93a62edf61c956/img/atom-try.gif)

# Why?
While I'm reading code and encounter the code which I can't understand how it works.  
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
- Detect grammar from scope of cursor position(e.g. CoffeeScript in Markdown), this ensure you got precise `try` buffer grammar.

# How to use

Select text in editor then
- Invoke `try:paste` via command palette or keymap.
- Chose `Paste to Try` from context menu.

# Keymap
No keymap by default.

e.g.

* With `F10`

```coffeescript
'atom-text-editor:not([mini])':
  'f10': 'try:paste'
```

* if you are using  [vim-mode](https://atom.io/packages/vim-mode), following are suggestion which I use.

```coffeescript
'atom-text-editor.vim-mode.normal-mode':
  'space t': 'try:paste'
'atom-text-editor.vim-mode.visual-mode':
  'T': 'try:paste'
```

# TODO
- [x] highlight pasted text on try buffer
- [x] improve coverage of `scope2extname`.
