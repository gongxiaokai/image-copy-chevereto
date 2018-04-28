module.exports =
  config:
    Api:
      title: "Your api url"
      description: "Input your api url like `https://xxx.com/api/1/upload`"
      type: 'string'
      default: "https://imgurl.xyz/api/1/upload"
    ApiKey:
      title: "ApiKey"
      description: "Input your api key, you can find it in your dashboard, default is my key ,Do not mark sure always available"
      type: 'string'
      default: "a7bb2b091e3f2961e59551a8cf6e05b2"

  activate: (state) ->
    @attachEvent()

  attachEvent: ->
    workspaceElement = atom.views.getView(atom.workspace)
    workspaceElement.addEventListener 'keydown', (e) =>
      # cmd + paste
      if (e.metaKey && e.keyCode == 86)
        # clipboard readImage
        clipboard = require('clipboard')
        img = clipboard.readImage()
        return if img.isEmpty()

        clipboard.writeText('')

        # insert loading text
        editor = atom.workspace.getActiveTextEditor()
        range = editor.insertText('uploading...');

        @postToImgur img, (imgUrl) ->
          # replace loading text to markdown img format
          markdown = "![](#{imgUrl})"
          editor.setTextInBufferRange(range[0], markdown)

  postToImgur: (img, callback) ->

    req = require('request')
    options = {
      uri: atom.config.get('image-copy-chevereto.Api')
      formData: {
        action : 'upload'
        key : atom.config.get('image-copy-chevereto.ApiKey')
        source : img.toPNG().toString('base64')
      }
      json: true
    }
    req.post options, (error, response, body) ->
      if (!error && response.statusCode == 200)
        callback(body.image.display_url) if callback && body.image.display_url
      else
        callback('error ')
