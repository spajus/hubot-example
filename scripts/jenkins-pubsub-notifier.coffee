# Description:
#   An HTTP Listener that notifies about new Jenkins build failures
#
# Dependencies:
#   "hubot-pubsub": "1.0.0"
#
# URLS:
#   POST /jenkins/status
#
# Authors:
#   spajus

module.exports = (robot) ->

  robot.router.post "/jenkins/status", (req, res) ->
    @failing ||= []
    res.end('')
    data = req.body
    return unless data.build.phase == 'FINISHED'

    if data.build.status == 'FAILURE' || data.build.status == 'UNSTABLE'
      if data.name in @failing
        broke = 'still broken'
      else
        broke = 'just broke'
        @failing.push data.name
      message = "#{broke} #{data.name} " +
        "#{data.build.display_name} (#{data.build.full_url})"

    if data.build.status == 'SUCCESS'
      if data.name in @failing
        index = @failing.indexOf data.name
        @failing.splice index, 1 if index isnt -1
        message = "restored #{data.name} " +
          "#{data.build.display_name} (#{data.build.full_url})"

    if message
      event = "build.#{data.build.status}"
      robot.emit 'pubsub:publish', event, message

