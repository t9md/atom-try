{CompositeDisposable} = require 'atom'
_        = require 'underscore-plus'
path     = require 'path'
fs       = require 'fs-plus'
settings = require './settings'

scope2extname = require './scope2extname'

module.exports =
  subscriptions: null
  config: settings.config
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
    atom.grammars.getGrammars().map (grammar) ->
      grammar.scopeName

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
    rootDir  = fs.normalize settings.get('root')
    basename = settings.get 'basename'

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

    options = searchAllPanes: settings.get('searchAllPanes')
    if settings.get('split') isnt 'none'
      options.split = settings.get 'split'

      switch settings.get 'pasteTo'
        when 'top'    then editor.moveToTop()
        when 'bottom' then editor.moveToBottom()

      unless selection.isEmpty()
        editor.insertText selection.getText(),
          select: settings.get 'select'
          autoIndent: settings.get 'autoIndent'

        selection.clear() if settings.get('clearSelection')
