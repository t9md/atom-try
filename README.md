# Try
Paste fragment of code into try buffer then try it!

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
- Invoke `try:paste`.
- Chose `Paste to Try` from context menu.

# Keymap
No keymap by default.

e.g.

* With `F10`

```coffeescript
'atom-text-editor:not([mini])':
  'f10':       'try:paste'
```

* if you are using  [vim-mode](https://atom.io/packages/vim-mode)

```coffeescript
'atom-text-editor.vim-mode.visual-mode':
  'space t': 'try:paste'
```

# TODO

- highlight pasted text on try buffer
- improve coverage of `scope2extname`.
