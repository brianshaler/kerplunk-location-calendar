fs = require 'fs'
World = require './world'

fs.writeFile 'tmp.json', World.process()
