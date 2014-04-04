# Description:
#   hubot-pubsub based GitLab issue notifier
#
# Dependencies:
#   "hubot-pubsub": "1.0.0"
#
# Commands:
#   None
#
# Configuration:
#   GITLAB_ROOT_URL
#   GITLAB_API_TOKEN
#
# URLS:
#   POST /gitlab/issues/pubsub/<pubsub-event>
#
# Authors:
#   spajus

module.exports = (robot) ->
  api_root = "#{process.env.GITLAB_ROOT_URL}/api/v3"
  robot.router.post "/gitlab/issues/pubsub/:event", (req, res) ->
    res.end('')
    event = req.params.event
    try
      payload = req.body
      attribs = payload.object_attributes
      project_url = "#{api_root}/projects/#{attribs.project_id}"
      robot.http(project_url)
        .header('PRIVATE-TOKEN', process.env.GITLAB_API_TOKEN)
        .get() (err, res, body) ->
          body = JSON.parse(body)
          issue_url = "#{body.web_url}/issues/#{attribs.id}"
          issue_message = "#{payload.object_kind} #{attribs.state}: #{attribs.title}"
          message = "#{issue_message} (#{issue_url})"
          robot.emit 'pubsub:publish', event, message
    catch error
      console.log "gitlab-pubsub-issues error: #{error}. Payload: #{req.body}"
