path = require 'path'

class Settings
  constructor: (@scope, @config) ->

  get: (param) ->
    atom.config.get "#{@scope}.#{param}"

  set: (param, value) ->
    atom.config.set "#{@scope}.#{param}", value

  toggle: (param) ->
    @set(param, not @get(param))

  observe: (param, fn) ->
    atom.config.observe "#{@scope}.#{param}", fn

module.exports = new Settings 'try',
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
