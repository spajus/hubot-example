# Description
#   Find and close old issues in GitHub
#
# Dependencies:
#   "githubot": "0.4.1"
#   "moment": "2.5.0"
#   "hubot-pubsub": "1.0.0"
#   "cron"
#
# Configuration:
#   HUBOT_GITHUB_TOKEN (optional, if you want to search in private repos)
#   HUBOT_GITHUB_ORG - your GitHub organization
#
# Commands:
#   hubot close old issues in <repo> - Close outdated issues in given repo
#
# Author:
#   spajus

# Override these with your target repos. Keep list empty if using org.
target_repos = [
  'spajus/hubot-example',
  'spajus/hubot-control'
]

# Override with your org. Keep blank if non relevant.
target_org = ''

# Set your time zone
timezone = 'America/Los_Angeles'

# Set desired time. 00 00 9 * * 1-5 is monday-friday at 9 AM.
cron_expression = '00 00 9 * * 1-5'

module.exports = (robot) ->

  github = require('githubot')(robot, apiVersion: 'preview')
  cronJob = require('cron').CronJob
  moment = require('moment')

  new cronJob(cron_expression, closeOldIssues, null, true, timezone)

  closeOldIssues = ->
    org = target_org || process.env.HUBOT_GITHUB_ORG
    if org
      robot.emit 'github:org:issues:close', org
    for repo in target_repos
      robot.emit 'github:repo:issues:close', repo

  robot.respond /close old issues (in )?(.+\/[^\s]+)/i, (msg) ->
    repo = msg.match[2]
    closeOldIssuesIn repo, (data) ->
      msg.send data

  robot.on 'github:org:issues:close', (org) ->
    github.get "/orgs/#{org}/repos", (data) ->
      for repo in data
        closeOldIssuesIn repo.full_name, (data) ->
          robot.emit 'pubsub:publish', 'github.issue.close', data

  robot.on 'github:repo:issues:close', (repo) ->
    closeOldIssuesIn repo, (data) ->
      robot.emit 'pubsub:publish', 'github.issue.close', data

  closeOldIssuesIn = (repo, cb) ->
    github.handleErrors (response) ->
      cb "Error: #{response.statusCode} #{response.error}. Repo: #{repo}"
    github.get "repos/#{repo}/issues?state=open", (data) ->
      reply = ''
      found = false
      old_time = moment().subtract 'months', 1
      for issue in data
        issue_time = moment issue.updated_at, 'YYYY-MM-DDTHH:mm:ssZ'
        if issue_time < old_time
          found = true
          post_data = { body: "Closing old issue: updated #{issue_time.fromNow()}" }
          github.post "repos/#{repo}/issues/#{issue.number}/comments", post_data, (post_resp) ->
            console.log "Posted comment: #{post_resp.html_url}"
          close_data = { state: 'closed' }
          github.request 'PATCH', "repos/#{repo}/issues/#{issue.number}", close_data, (close_resp) ->
            console.log "Closed issue: #{close_resp.html_url}"
          reply = "#{reply}#{issue.title} (#{issue.html_url}) updated #{issue_time.fromNow()}\n"
      if found
        cb "Found #{data.length} open issues in #{repo}. Closed old ones:\n#{reply}"
      else
        cb "No old issues found in #{repo}"

