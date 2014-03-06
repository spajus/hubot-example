# Description
#   Triggers Jenkins jobs from chatroom
#
# Configuration:
#   HUBOT_JENKINS_URI - Base Jenkins URI
#   HUBOT_JENKINS_BUILD_TOKEN - Token for triggering Jenkins builds
#
# Commands:
#   hubot build <job> [param=value ...] - build Jenkins job by name
#
# Author:
#   spajus

module.exports = (robot) ->

  jenkins_uri = process.env.HUBOT_JENKINS_URI
  build_token = process.env.HUBOT_JENKINS_BUILD_TOKEN

  robot.respond /build ([\w_-]+)/i, (msg) ->
    job = msg.match[1]
    url = "#{jenkins_uri}/job/#{encodeURI(job)}/build"
    msg.robot.http(url).query(token: build_token).get() (err, res, body) ->
      item_url = res.headers.location
      msg.robot.http("#{item_url}api/json").get() (err, res, body) ->
        data = JSON.parse body
        if data.executable
          msg.send "Building #{data.task.name} (#{data.executable.url})"
        else if data.task
          msg.send "Added #{data.task.name} (#{data.task.url}) to build queue: #{data.why}"
        else
          msg.send "Building #{data.name} (#{data.url})"

  robot.respond /build ([\w_-]+) (.+)$/i, (msg) ->
    job = msg.match[1]
    params = msg.match[2].split /\s+/
    query = { token: build_token }
    for param in params
      [k, v] = param.split '='
      query[k] = v
    url = "#{jenkins_uri}/job/#{encodeURI(job)}/buildWithParameters"
    msg.robot.http(url).query(query).get() (err, res, body) ->
      item_url = res.headers.location
      msg.robot.http("#{item_url}api/json").get() (err, res, body) ->
        data = JSON.parse body
        if data.executable
          msg.send "Building #{data.task.name} (#{data.executable.url})"
        else if data.task
          msg.send "Added #{data.task.name} (#{data.task.url}) to build queue: #{data.why}"
        else
          msg.send "Building #{data.name} (#{data.url})"


