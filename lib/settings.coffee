path       = require 'path'
ConfigPlus = require 'atom-config-plus'

config =
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

module.exports = new ConfigPlus 'try', config
