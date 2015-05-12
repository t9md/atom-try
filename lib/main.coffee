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
  clearSelection:
    type: 'boolean'
    default: true
    description: "Clear original selection"
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
  split:
    type: 'string'
    default: 'none'
    enum: ["none", "left", "right" ]
    description: "Where try buffer opend"
  searchAllPanes:
    type: 'boolean'
    default: false
    description: "Open existing try buffer if exists"

module.exports =
  subscriptions: null
  config: Config

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
      'try:paste': => @paste()
      'try:detect-cursor-scope': => @detectCursorScope()

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->

  detectCursorScope: ->
    cursor = @getActiveTextEditor().getCursor()
    scopesArray = cursor.getScopeDescriptor().getScopesArray()
    scope = _.detect scopesArray.reverse(), (scope) ->
      scope.indexOf('source.') is 0
    scope ?= _.last(scopesArray)
    scope

  # Deperecate
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

  instanceEval: (self, callback) ->
    callback.bind(self)()

  with: (self, callback) ->
    callback(self)

  overrideGrammarForPath: (filePath, scopeName) ->
    # Experiment-1
    # @instanceEval atom.grammars, ->
    #   @clearGrammarOverrideForPath filePath
    #   @setGrammarOverrideForPath filePath, scopeName

    # Experiment-2
    # @with atom.grammars, (self) ->
    #   self.clearGrammarOverrideForPath filePath
    #   self.setGrammarOverrideForPath filePath, scopeName

    # Experiment-3
    # (->
    #   @clearGrammarOverrideForPath filePath
    #   @setGrammarOverrideForPath filePath, scopeName)
    #   .bind(atom.grammars)()

    atom.grammars.clearGrammarOverrideForPath filePath
    atom.grammars.setGrammarOverrideForPath filePath, scopeName

  getActiveTextEditor: ->
    atom.workspace.getActiveTextEditor()

  getFilePath: (scopeName) ->
    rootDir  = expandPath atom.config.get('try.root')
    basename = atom.config.get('try.basename')
    path.join rootDir, "#{basename}.#{scopeName}"

  paste: ->
    editor    = @getActiveTextEditor()
    selection = editor.getSelection()
    scopeName = @detectCursorScope()
    filePath = @getFilePath scopeName
    @overrideGrammarForPath filePath, scopeName

    options = searchAllPanes: atom.config.get('try.searchAllPanes')
    if atom.config.get('try.split') isnt 'none'
      options.split = atom.config.get 'try.split'

    atom.workspace.open(filePath, options).done (editor) =>
      if atom.config.get('try.autosave')
        pane = atom.workspace.getActivePane()

        # [FIXME] auto-save event is bounded only this pane, so when we manually
        # split pane, auto-save won't invoked for that pane.
        # I need, buffer.onWillDestroy().
        # [BUG] Check if other file in this pane affect!!
        @subscriptions.add pane.onWillDestroyItem ({item})->
          return unless item.isModified?()
          item.save()

      switch atom.config.get('try.pasteTo')
        when 'top'    then editor.moveToTop()
        when 'bottom' then editor.moveToBottom()

      unless selection.isEmpty()
        editor.insertText selection.getText(),
          select: atom.config.get('try.select')
          autoIndent: atom.config.get('try.autoIndent')

        selection.clear() if atom.config.get('try.clearSelection')
