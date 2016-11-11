{Disposable, CompositeDisposable} = require 'atom'
ElementID = 'try-input'
PlaceHolderText = "extension e.g. js"

# InputBase, InputElementBase
# -------------------------
class Input extends HTMLElement
  createdCallback: ->
    @innerHTML = """
    <div class='try-input-container'>
      <atom-text-editor mini id="#{ElementID}"></atom-text-editor>
    </div>
    """
    @panel = atom.workspace.addBottomPanel(item: this, visible: false)
    this

  destroy: ->
    @editor.destroy()
    @panel?.destroy()
    {@editor, @panel, @editorElement} = {}
    @remove()

  handleEvents: ->
    atom.commands.add @editorElement,
      'core:confirm': => @confirm()
      'core:cancel': => @cancel()
      'blur': => @cancel() unless @finished

  readInput: ->
    unless @editorElement
      @editorElement = document.getElementById(ElementID)
      @editor = @editorElement.getModel()
      @editor.setPlaceholderText(PlaceHolderText)

    @finished = false
    @panel.show()
    @editorElement.focus()
    @commandSubscriptions = @handleEvents()

    # Cancel on tab switch
    disposable = atom.workspace.onDidChangeActivePaneItem =>
      disposable.dispose()
      @cancel() unless @finished

    new Promise (@resolve) =>

  confirm: ->
    @resolve(@editor.getText())
    @cancel()

  cancel: ->
    @commandSubscriptions?.dispose()
    @resolve = null
    @finished = true
    atom.workspace.getActivePane().activate()
    @editor.setText ''
    @panel?.hide()

module.exports = document.registerElement ElementID,
  extends: 'div'
  prototype: Input.prototype
