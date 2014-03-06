module.exports = (robot) ->
  robot.respond /do dangerous stuff/i, (msg) ->
    if robot.auth.hasRole(msg.envelope.user, 'developer')
      doDangerousStuff(msg)
    else
      msg.reply "Sorry, you don't have 'developer' role"

  doDangerousStuff = (msg) ->
    msg.send "Doing dangerous stuff"

