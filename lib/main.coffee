{CompositeDisposable} = require 'atom'
_ = require 'underscore-plus'
path = require 'path'
fs = require 'fs-plus'
settings = require './settings'
Input = null

scope2extname = require './scope2extname'

getAdjacentPaneForPane = (pane) ->
  return unless children = pane.getParent().getChildren?()
  index = children.indexOf(pane)

  _.chain([children[index-1], children[index+1]])
    .filter (pane) ->
      pane?.constructor?.name is 'Pane'
    .last()
    .value()

module.exports =
  config: settings.config
  grammarOverriddenPaths: {}

  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
      'try:paste': => @paste()
      'try:open-file': => @openFile()

  deactivate: ->
    @subscriptions.dispose()
    {@subscriptions, @input} = {}
    atom.grammars.clearGrammarOverrideForPath(filePath) for filePath of @grammarOverriddenPaths

  getSupportedScopeNames: ->
    atom.grammars.getGrammars().map (grammar) ->
      grammar.scopeName

  detectCursorScope: ->
    editor = @getEditor()
    [startRow, endRow] = editor.getLastSelection().getBufferRowRange()
    scopeDescriptor = editor.scopeDescriptorForBufferPosition([startRow, 0])
    scopeNames = scopeDescriptor.getScopesArray().slice().reverse()
    supportedScopeNames = (grammar.scopeName for grammar in atom.grammars.getGrammars())
    for scopeName in scopeNames when scopeName in supportedScopeNames
      return scopeName
    null

  overrideGrammarForPath: (filePath, scopeName) ->
    return if @grammarOverriddenPaths[filePath] is scopeName
    atom.grammars.clearGrammarOverrideForPath(filePath)
    atom.grammars.setGrammarOverrideForPath(filePath, scopeName)
    @grammarOverriddenPaths[filePath] = scopeName

  getEditor: ->
    atom.workspace.getActiveTextEditor()

  determineFilePath: (scopeName, URI) ->
    rootDir = fs.normalize(settings.get('root'))
    basename = settings.get('basename')

    # Strategy
    # Determine appropriate filename extension in following order.
    #  1. From scope2extname table
    #  2. Original filename's extension
    #  3. ScopeName itself.
    ext = scope2extname[scopeName]
    ext ?= (path.extname URI).substr(0)
    ext ?= scopeName
    path.join(rootDir, "#{basename}.#{ext}")

  paste: ->
    editor = @getEditor()
    URI = editor.getURI()
    selection = editor.getLastSelection()
    scopeName = @detectCursorScope()
    filePath = @determineFilePath(scopeName, URI)
    @overrideGrammarForPath(filePath, scopeName)

    @openTryFile(filePath).then (editor) ->
      switch settings.get('pasteTo')
        when 'top' then editor.moveToTop()
        when 'bottom' then editor.moveToBottom()

      unless selection.isEmpty()
        editor.insertText selection.getText(),
          select: settings.get 'select'
          autoIndent: settings.get 'autoIndent'

        selection.clear() if settings.get('clearSelection')

  openTryFile: (filePath) ->
    options = {searchAllPanes: settings.get('searchAllPanes')}
    if pane = getAdjacentPaneForPane(atom.workspace.getActivePane())
      pane.activate()
    else
      options.split = settings.get 'split' if settings.get('split') isnt 'none'
    atom.workspace.open(filePath, options)

  openFile: ->
    Input ?= require('./input')
    placeholderText = "extension e.g. js"
    @input ?= (new Input).initialize(placeholderText)

    @input.readInput().then (ext) =>
      return unless ext
      rootDir = fs.normalize(settings.get('root'))
      basename = settings.get('basename')
      filePath = path.join(rootDir, "#{basename}.#{ext}")
      @openTryFile(filePath)
