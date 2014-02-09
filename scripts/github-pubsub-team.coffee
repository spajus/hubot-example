# Description:
#   An HTTP Listener that notifies about repository team changes
#
# Dependencies:
#   "hubot-pubsub": "1.0.0"
#
# URLS:
#   POST /github/team/pubsub/<pubsub-event>
#
# Authors:
#   spajus

module.exports = (robot) ->

  robot.router.post "/github/team/pubsub/:event", (req, res) ->
    res.end("")
    event = req.params.event
    announceTeamChange req.body, (data) ->
      robot.emit 'pubsub:publish', event, data

  announceTeamChange = (data, cb) ->
    team = data.team.name
    team_perm = data.team.permission
    org = data.sender.login
    repo = data.repository.full_name
    cb "@#{org}/#{team} received #{team_perm} rights on #{repo}"

