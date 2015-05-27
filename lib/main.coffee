{CompositeDisposable} = require 'atom'
_    = require 'underscore-plus'
path = require 'path'

scope2extname = require './scope2extname'

expandPath = (str) ->
  if str.substr(0, 2) == '~/'
    str = (process.env.HOME or process.env.HOMEPATH or process.env.HOMEDIR or process.cwd()) + str.substr(1);
  path.resolve str

Config =
  root:
    order: 1
    type: 'string'
    default: path.join(atom.config.get('core.projectHome'), "try")
    description: "Root directory of your try buffer"
  basename:
    order: 2
    type: 'string'
    default: 'try'
    description: "Basename of try buffer"
  clearSelection:
    order: 3
    type: 'boolean'
    default: true
    description: "Clear original selection"
  pasteTo:
    order: 4
    type: 'string'
    default: "bottom"
    enum: ["bottom", "top", "here"]
    description: "Where selected text is pasted."
  select:
    order: 5
    type: 'boolean'
    default: true
    description: "Select pasted text"
  autoIndent:
    order: 6
    type: 'boolean'
    default: false
    description: "Indent pasted text"
  split:
    order: 7
    type: 'string'
    default: 'none'
    enum: ["none", "left", "right" ]
    description: "Where try buffer opend"
  searchAllPanes:
    order: 8
    type: 'boolean'
    default: false
    description: "Open existing try buffer if exists"

module.exports =
  subscriptions: null
  config: Config
  grammarOverriddenPaths: {}

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
      'try:paste': => @paste()

  deactivate: ->
    @subscriptions.dispose()
    for filePath of @grammarOverriddenPaths
      atom.grammars.clearGrammarOverrideForPath filePath

  serialize: ->

  getSupportedScopeNames: ->
    atom.grammars.getGrammars().map (grammar) -> grammar.scopeName

  detectCursorScope: ->
    supportedScopeNames = @getSupportedScopeNames()

    cursor = @getActiveTextEditor().getLastCursor()
    scopesArray = cursor.getScopeDescriptor().getScopesArray()
    scope = _.detect scopesArray.reverse(), (scope) ->
      scope in supportedScopeNames
    scope

  overrideGrammarForPath: (filePath, scopeName) ->
    return if @grammarOverriddenPaths[filePath] is scopeName
    atom.grammars.clearGrammarOverrideForPath filePath
    atom.grammars.setGrammarOverrideForPath filePath, scopeName
    @grammarOverriddenPaths[filePath] = scopeName

  getActiveTextEditor: ->
    atom.workspace.getActiveTextEditor()

  determineFilePath: (scopeName, URI) ->
    rootDir  = expandPath atom.config.get('try.root')
    basename = atom.config.get('try.basename')

    # Strategy
    # Determine appropriate filename extension in following order.
    #  1. From scope2extname table
    #  2. Original filename's extension
    #  3. ScopeName itself.
    ext  = scope2extname[scopeName]
    ext ?= (path.extname URI).substr(0)
    ext ?= scopeName
    path.join rootDir, "#{basename}.#{ext}"

  paste: ->
    editor    = @getActiveTextEditor()
    URI       = editor.getURI()
    selection = editor.getLastSelection()
    scopeName = @detectCursorScope()
    filePath  = @determineFilePath scopeName, URI
    @overrideGrammarForPath filePath, scopeName

    options = searchAllPanes: atom.config.get('try.searchAllPanes')
    if atom.config.get('try.split') isnt 'none'
      options.split = atom.config.get 'try.split'

    atom.workspace.open(filePath, options).done (editor) =>
      switch atom.config.get('try.pasteTo')
        when 'top'    then editor.moveToTop()
        when 'bottom' then editor.moveToBottom()

      unless selection.isEmpty()
        editor.insertText selection.getText(),
          select: atom.config.get('try.select')
          autoIndent: atom.config.get('try.autoIndent')

        selection.clear() if atom.config.get('try.clearSelection')
