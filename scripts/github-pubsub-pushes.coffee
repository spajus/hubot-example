# Description:
#   hubot-pubsub based GitHub push notifier
#
# Dependencies:
#   "hubot-pubsub": "1.0.0"
#
# Commands:
#   None
#
# URLS:
#   POST /github/pushes/pubsub/<pubsub-event>
#
# Authors:
#   spajus

module.exports = (robot) ->

  robot.router.post "/github/pushes/pubsub/:event", (req, res) ->
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
          message = "#{prefix}#{payload.pusher.name} merged #{payload.commits.length} " +
                    "commits on #{payload.repository.name}:" +
                    "#{payload.ref.replace('refs/heads/', '')} " +
                    "(compare: #{payload.compare})"
          robot.emit 'pubsub:publish', event, message
          if payload.commits.length < 10
            for commit in payload.commits
              robot.emit 'pubsub:publish', event,
                         "  * #{commit.author.name}: #{commit.message} (#{commit.url})"
        else
          message = "#{prefix}#{payload.commits[0].author.name} " +
                    "(#{payload.commits[0].author.username}) " +
                    "pushed #{payload.commits.length} commits to " +
                    "#{payload.repository.name}:#{payload.ref.replace('refs/heads/', '')}"
          if payload.commits.length > 1
            message += " (compare: #{payload.compare})"
            robot.emit 'pubsub:publish', event, message
            for commit in payload.commits
              robot.emit 'pubsub:publish', event, "  * #{commit.message} (#{commit.url})"
          else
            robot.emit 'pubsub:publish', event, message
            for commit in payload.commits
              do (commit) ->
                robot.emit 'pubsub:publish', event, "  * #{commit.message} (#{commit.url})"
      else
        if payload.created
          if payload.base_ref
            base_ref = ': ' + payload.base_ref.replace('refs/heads/', '')
          else
            base_ref = ''
          robot.emit 'pubsub:publish', event, "#{prefix}#{payload.pusher.name} " +
                     "created: #{payload.ref.replace('refs/heads/', '')}#{base_ref}"
        if payload.deleted
          robot.emit 'pubsub:publish', event, "#{prefix}#{payload.pusher.name} " +
                     "deleted: #{payload.ref.replace('refs/heads/', '')}"
    catch error
      console.log "github-pubsub-pushes error: #{error}. Payload: #{req.body}"
