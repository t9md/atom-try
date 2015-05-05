{CompositeDisposable} = require 'atom'
scope2extname = require './scope2extname'
_ = require 'underscore-plus'

expandPath = (str) ->
  if str.substr(0, 2) == '~/'
    str = (process.env.HOME or process.env.HOMEPATH or process.env.HOMEDIR or process.cwd()) + str.substr(1);
  path.resolve str

Config =
  root:
    type: 'string'
    default: path.join(atom.config.get('core.projectHome'), "try")
    description: "Root directory of your try buffer"
  basename:
    type: 'string'
    default: 'try'
    description: "Basename of try buffer"
  pasteTo:
    type: 'string'
    default: "bottom"
    enum: ["bottom", "top", "here"]
    description: "Where selected text is pasted."
  select:
    type: 'boolean'
    default: true
    description: "Select pasted text"
  autoIndent:
    type: 'boolean'
    default: false
    description: "Indent pasted text"
  autosave:
    type: 'boolean'
    default: true
    description: "Autosave for try buffer"

module.exports =
  subscriptions: null
  config: Config

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
    basename = atom.config.get('try.basename')
    path.join rootDir, "#{basename}#{extname}"

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

      pasteTo = atom.config.get('try.pasteTo')
      if pasteTo is "top"
        editor.moveToTop()
      else if pasteTo is "bottom"
        editor.moveToBottom()

      options =
        select: atom.config.get('try.select')
        autoIndent: atom.config.get('try.autoIndent')
      editor.insertText text, options
