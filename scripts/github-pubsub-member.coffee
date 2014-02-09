# Description:
#   An HTTP Listener that notifies about repo membership changes
#
# Dependencies:
#   "hubot-pubsub": "1.0.0"
#
# URLS:
#   POST /github/member/pubsub/<pubsub-event>
#
# Authors:
#   spajus

module.exports = (robot) ->

  robot.router.post "/github/member/pubsub/:event", (req, res) ->
    res.end("")
    event = req.params.event
    announceMemberChange req.body, (data) ->
      robot.emit 'pubsub:publish', event, data

  announceMemberChange = (data, cb) ->
    if data.action
      who = data.member.login
      by_who = data.sender.login
      repo = data.repository.full_name
      action = data.action
      cb "#{repo} membership change: @#{by_who} #{action} @#{who}" 
