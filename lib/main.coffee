{CompositeDisposable} = require 'atom'
path = require 'path'
fs = require 'fs-plus'
settings = require './settings'

scope2extname = require './scope2extname'

module.exports =
  config: settings.config

  activate: ->
    @subscriptions = new CompositeDisposable
    paste = @paste.bind(this)
    @subscriptions.add atom.commands.add 'atom-text-editor',
      'try:paste': -> paste(@getModel())
      'try:open-file': => @openTryFile()

  deactivate: ->
    @subscriptions.dispose()
    {@subscriptions, @input} = {}

  # Strategy
  # Determine appropriate filename extension in following order.
  #  1. From scope2extname table
  #  2. Original filename's extension
  #  3. ScopeName itself.
  getExtension: (scopeName, URI) ->
    extension = scope2extname[scopeName]
    extension ?= path.extname(URI).substr(1)
    extension ?= scopeName
    extension

  paste: (editor) ->
    selection = editor.getLastSelection()
    scopeName = editor.getGrammar().scopeName
    extension = @getExtension(scopeName, editor.getURI())

    @openTryFile(extension).then (tryEditor) ->
      atom.textEditors.setGrammarOverride(tryEditor, scopeName)
      unless selection.isEmpty()
        switch settings.get('pasteTo')
          when 'top' then tryEditor.moveToTop()
          when 'bottom' then tryEditor.moveToBottom()

        options = {select: settings.get('select'), autoIndent: settings.get('autoIndent')}
        tryEditor.insertText(selection.getText(), options)
        selection.clear() if settings.get('clearSelection')

  openTryFile: (extension=null) ->
    if extension
      getExtensionPromise = Promise.resolve(extension)
    else
      @input ?= new (require('./input'))
      getExtensionPromise = @input.readInput().then (extension) ->
        Promise.resolve(extension)

    getExtensionPromise.then (extension) ->
      rootDir = fs.normalize(settings.get('root'))
      basename = settings.get('basename')
      filePath = path.join(rootDir, "#{basename}.#{extension}")

      options = {searchAllPanes: settings.get('searchAllPanes')}
      split = settings.get('split')
      options.split = split unless split is 'none'
      atom.workspace.open(filePath, options)
