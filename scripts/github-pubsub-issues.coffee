# Description:
#   An HTTP Listener that notifies about new Github issues
#
# Dependencies:
#   "hubot-pubsub": "1.0.0"
#
# URLS:
#   POST /github/issues/pubsub/<pubsub-event>
#
# Authors:
#   spajus

module.exports = (robot) ->

  robot.router.post "/github/issues/pubsub/:event", (req, res) ->
    res.end("")

    event = req.params.event

    announceIssue req.body, (data) ->
      robot.emit 'pubsub:publish', event, data


announceIssue = (data, cb) ->

  if data.action
    mentioned = data.issue.body.match(/(^|\s)(@[\w\-\/]+)/g)

    if mentioned
      unique = (array) ->
        output = {}
        output[array[key]] = array[key] for key in [0...array.length]
        value for key, value of output

      mentioned = mentioned.map (nick) -> nick.trim()
      mentioned = unique mentioned

      mentioned_line = "\nMentioned: #{mentioned.join(", ")}"
    else
      mentioned_line = ''
    
    cb "Issue #{data.action}: \"#{data.issue.title}\" " +
       "by #{data.issue.user.login}: #{data.issue.html_url}#{mentioned_line}"
    
