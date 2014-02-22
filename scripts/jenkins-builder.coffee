# Description
#   Triggers Jenkins jobs from chatroom
#
# Configuration:
#   HUBOT_JENKINS_URI - Base Jenkins URI
#   HUBOT_JENKINS_BUILD_TOKEN - Token for triggering Jenkins builds
#
# Commands:
#   hubot build <job> - build Jenkins job by name
#
# Author:
#   spajus

module.exports = (robot) ->

  jenkins_uri = process.env.HUBOT_JENKINS_URI
  build_token = process.env.HUBOT_JENKINS_BUILD_TOKEN

  robot.respond /build (.+)/i, (msg) ->
    job = msg.match[1]
    url = "#{jenkins_uri}/job/#{encodeURI(job)}/build?token=#{encodeURI(build_token)}"
    msg.robot.http(url).get() (err, res, body) ->
      item_url = res.headers.location
      msg.robot.http("#{item_url}api/json").get() (err, res, body) ->
        data = JSON.parse body
        if data.executable
          msg.send "Building #{data.task.name} (#{data.executable.url})"
        else
          msg.send "Added #{data.task.name} (#{data.task.url}) to build queue: #{data.why}"
