# Description:
#   Greet the world
#
# Commands:
#   hubot greet - Say hello to the world
#
# Author:
#   spajus
module.exports = (robot) ->
  robot.respond /greet/i, (msg) ->
    msg.send "Hello, World!"
