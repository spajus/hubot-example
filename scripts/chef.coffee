# Description
#   Hubot script that runs Chef's knife
#
# Commands:
#   hubot knife <command> - execute knife command (only in devops chat)
#   hubot server list - list all our servers registered with chef
#   hubot server list <pattern> - list our servers registered with chef matching a pattern
#   hubot server search <pattern> - search for servers matching chef role (* works)
#   hubot servers <pattern> - search for servers matching '*-<pattern>' chef role
#   hubot server roles - list all chef roles
#   hubot server roles <pattern> - list chef roles matching a pattern
#
# Author:
#   spajus

module.exports = (robot) ->

  cp = require 'child_process'
  knife_opts = { cwd: '/home/hubot/knife' }

  handle_response = (msg) ->
    (error, stdout, stderr) ->
      msg.send stdout if stdout
      msg.send "Error: #{stderr}" if stderr

  robot.respond /knife (.*)/i, (msg) ->
    if msg.message.room != '<insert devops room id>'
      msg.send "Do it in devops room please"
      return
    cp.exec "knife #{msg.match[1]}",
      knife_opts, handle_response(msg)

  robot.respond /server list$/i, (msg) ->
    cp.exec "knife node list",
      knife_opts, handle_response(msg)

  robot.respond /server list (.*)/i, (msg) ->
    cp.exec "knife node list | grep #{msg.match[1]}",
      knife_opts, handle_response(msg)

  robot.respond /server roles?$/i, (msg) ->
    cp.exec "knife role list",
      knife_opts, handle_response(msg)

  robot.respond /server roles? (.*)/i, (msg) ->
    cp.exec "knife role list | grep #{msg.match[1]}$",
      knife_opts, handle_response(msg)

  robot.respond /server search (.*)/i, (msg) ->
    cp.exec "knife search node 'roles:#{msg.match[1]}' -a run_list",
      knife_opts, handle_response(msg)

  robot.respond /servers (.*)/i, (msg) ->
    cp.exec "knife search node 'roles:*-#{msg.match[1]}' -i",
      knife_opts, handle_response(msg)

