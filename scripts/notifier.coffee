# Description:
#   Send message to chatroom using HTTP POST
#
# URLS:
#   POST /hubot/notify/<room> (message=<message>)

module.exports = (robot) ->
  robot.router.post '/hubot/notify/:room', (req, res) ->
    room = req.params.room
    message = req.body.message
    robot.messageRoom room, message
    res.end()
