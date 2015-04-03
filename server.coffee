chokidar = require 'chokidar'
config = require './config'
path = require 'path'
fs = require 'fs'
WebTorrent = require('webtorrent')
mkdirp = require('mkdirp')

client = new WebTorrent()

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

watcher.on 'add', (torrent_file) -> 
  if path.extname(torrent_file).toLowerCase() is '.torrent'
    client.download torrent_file, (torrent) ->
      console.log('Torrent info hash:', torrent.infoHash)

      torrent.files.forEach (file) ->
        console.log file.path + " " + file.length/(1024*1024) + "MB"
        destination_file = path.join config.media_folder, file.path
        mkdirp.sync path.dirname destination_file
        
        destination = fs.createWriteStream(destination_file)
        destination.on 'open', ->
          stream = file.createReadStream()
          stream.pipe(destination)

          downloaded = 0
          stream.on 'data', (chunk) ->
            downloaded += chunk.length
            percentage = Math.floor (downloaded / file.length)*100
            console.log '%s: %d\% %d/%d bytes downloaded', file.name, percentage, downloaded, file.length

          stream.on 'error', (err) ->
            console.log "%s: error %s", file.name, err
            fs.close(stream) (err) ->
              console.log err

          stream.on 'finish', () ->
            console.log "%s: finish", file.name

          stream.on 'end', () ->
            console.log "%s: end", file.name
            
          stream.on 'close', () ->
            console.log "%s: close", file.name
      
      # delete torrent file
      fs.unlink torrent_file, (err) ->
        if err then throw err
        console.log 'successfully deleted ', torrent_file
      