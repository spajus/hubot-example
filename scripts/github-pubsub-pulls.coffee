# Description:
#   hubot-pubsub based GitHub pull request notifier
#
# Dependencies:
#   "hubot-pubsub": "1.0.0"
#
# URLS:
#   POST /github/pulls/pubsub/<pubsub-event>
#
# Authors:
#   spajus

module.exports = (robot) ->

  robot.router.post "/github/pulls/pubsub/:event", (req, res) ->

    event = req.params.event
    res.end("")

    announcePullRequest req.body, (data) ->
      robot.emit 'pubsub:publish', event, data

announcePullRequest = (data, cb) ->
  if data.action == 'opened'
    mentioned = data.pull_request.body.match(/(^|\s)(@[\w\-\/]+)/g)

    if mentioned
      unique = (array) ->
        output = {}
        output[array[key]] = array[key] for key in [0...array.length]
        value for key, value of output

      mentioned = mentioned.filter (nick) ->
        slashes = nick.match(/\//g)
        slashes is null or slashes.length < 2

      mentioned = mentioned.map (nick) -> nick.trim()
      mentioned = unique mentioned

      mentioned_line = "\nMentioned: #{mentioned.join(", ")}"
    else
      mentioned_line = ''

    cb "New pull request \"#{data.pull_request.title}\" " + 
       "by #{data.pull_request.user.login}: " +  
       "#{data.pull_request.html_url}#{mentioned_line}"
