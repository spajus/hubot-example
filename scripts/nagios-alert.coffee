# Description:
#   Receives Nagios alerts and posts them to chatroom
#
# Dependencies:
#   "hubot-pubsub": "1.0.0"
#
# URLS:
#   POST /nagios/alert (message=<message>)

module.exports = (robot) ->
  robot.router.post "/nagios/alert", (req, res) ->
    res.end()
    robot.emit 'pubsub:publish', 'nagios.alert', req.body.message
