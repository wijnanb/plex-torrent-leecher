chokidar = require 'chokidar'
config = require './config'
path = require 'path'
fs = require 'fs'

watcher = chokidar.watch config.watch_folder,
  ignored: /[\/\\]\./
  persistent: true

watcher.on 'add', (file) -> console.log('File', file, 'has been added')
watcher.on 'change', (file) -> console.log('File', file, 'has been changed')
watcher.on 'unlink', (file) -> console.log('File', file, 'has been removed')
watcher.on 'addDir', (file) -> console.log('Directory', file, 'has been added')
watcher.on 'unlinkDir', (file) -> lconsole.og('Directory', file, 'has been removed')
watcher.on 'error', (file) -> console.log('Error happened', error)
watcher.on 'ready', () -> console.log('Initial scan complete. Ready for changes.')
watcher.on 'raw', (event, file, details) -> console.log('Raw event info:', event, file, details)

watcher.on 'add', (file) -> 
  if path.extname(file).toLowerCase() is '.torrent'
    # start torrent

    # delete file
    fs.unlink file, (err) ->
      if err then throw err
      console.log 'successfully deleted ', file