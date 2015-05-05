{CompositeDisposable} = require 'atom'
scope2extname = require './scope2extname'
_ = require 'underscore-plus'

expandPath = (str) ->
  if str.substr(0, 2) == '~/'
    str = (process.env.HOME || process.env.HOMEPATH || process.env.HOMEDIR || process.cwd()) + str.substr(1);
  path.resolve str

module.exports =
  subscriptions: null

  config:
    root:
      type: 'string'
      default: path.join(atom.config.get('core.projectHome'), "try")
      description: "Root directory of your try buffer"
    basename:
      type: 'string'
      default: 'try'
      description: "Basename of try buffer"
    pasteToBottom:
      type: 'boolean'
      default: true
      description: "Paste to bottom of try buffer"
    autosave:
      type: 'boolean'
      default: true
      description: "Autosave for try buffer"

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
      'try:paste': => @paste()

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->

  getURIFor: (editor) ->
    # We need handle nested sope like coffeescript in markdown,
    # so use deepest scope information on Cursor.
    scopes = editor.getCursor().getScopeDescriptor().getScopesArray()
    extname = path.extname _.last(scopes)

    if scope2extname[extname.substring(1)]?
      # do some translation from scope name to common extname.
      extname = scope2extname[extname.substring(1)]

    if extname is '.null-grammar'
      # fallback to filename's extention.
      extname = path.extname editor.getPath()

    rootDir = expandPath atom.config.get('try.root')
    path.join rootDir, "#{atom.config.get('try.basename')}#{extname}"

  paste: ->
    editor = atom.workspace.getActiveTextEditor()
    text   = editor.getSelectedText()
    return unless text

    atom.workspace.open(@getURIFor(editor), split: 'right', searchAllPanes: true).done (editor) =>
      if atom.config.get('try.autosave')
        pane = atom.workspace.getActivePane()

        # [FIXME] auto-save event is bounded only this pane, so when we manually
        # split pane, auto-save won't invoked for that pane.
        # I need, buffer.onWillDestroy().
        @subscriptions.add pane.onWillDestroyItem ({item})->
          return unless item.isModified?()
          item.save()

      editor.moveToBottom() if atom.config.get('try.pasteToBottom')
      editor.insertText(text)
