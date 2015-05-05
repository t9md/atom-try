# Try
Paste fragment of code into try buffer then try it!

![gif](https://raw.githubusercontent.com/t9md/t9md/12fba4ff60861ae1acd973407c93a62edf61c956/img/atom-try.gif)

# Why?
While I'm reading code and encounter the code which I can't understand how it works.  
What I should do in such situation is **try** that code and see how it works.  
This package improve your repetitive copy and paste workflow into one step.

1. Select buffer
2. Incoke `try:paste` command.
3. Your selected code is pasted at bottom of try buffer.
4. Start try&see by running script runner package like [script](https://atom.io/packages/script).

# Features

- Paste selected text to bottom of try buffer by default.
- Autosave try buffer.
- Use scope at cursor position to support nested scope like CoffeeScript in Markdown.

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

* if you are using  [vim-mode](https://atom.io/packages/vim-mode)

```coffeescript
'atom-text-editor.vim-mode.visual-mode':
  'space t': 'try:paste'
```

# To improve scope2extname.

Leave comment on [Improve scope 2 extname mapping](https://github.com/t9md/atom-try/issues/1).

# TODO
- [x] highlight pasted text on try buffer
- [ ] improve coverage of `scope2extname`.
