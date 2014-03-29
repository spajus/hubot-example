# Description:
#   hubot-pubsub based GitLab push notifier
#
# Dependencies:
#   "hubot-pubsub": "1.0.0"
#
# Commands:
#   None
#
# URLS:
#   POST /gitlab/pushes/pubsub/<pubsub-event>
#
# Authors:
#   spajus

module.exports = (robot) ->

  robot.router.post "/gitlab/pushes/pubsub/:event", (req, res) ->
    res.end('')
    event = req.params.event
    try
      payload = req.body
      prefix = ">>> "
      if payload.commits.length > 0
        merge_commit = false
        author = payload.commits[0].author.name
        for commit in payload.commits
          if commit.author.name != author
            merge_commit = true
            break
        if merge_commit
          message = "#{prefix} merged #{payload.commits.length} " +
                    "commits on #{payload.repository.name}:" +
                    payload.ref.replace('refs/heads/', '')
          robot.emit 'pubsub:publish', event, message
          if payload.commits.length < 10
            for commit in payload.commits
              robot.emit 'pubsub:publish', event,
                         "  * #{commit.author.name}: #{commit.message} (#{commit.url})"
        else
          message = "#{prefix}#{payload.commits[0].author.name} " +
                    "pushed #{payload.commits.length} commits to " +
                    "#{payload.repository.name}:#{payload.ref.replace('refs/heads/', '')}"
          robot.emit 'pubsub:publish', event, message
          for commit in payload.commits
            robot.emit 'pubsub:publish', event, "  * #{commit.message} (#{commit.url})"
    catch error
      console.log "gitlab-pubsub-pushes error: #{error}. Payload: #{req.body}"
