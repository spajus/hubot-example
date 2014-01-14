# Description:
#   Executes commands from `event-master.coffee`

module.exports = (robot) ->
  robot.on 'slave:command', (action, room) ->
    robot.messageRoom room, "Slave: doing as told: #{action}"
    console.log 'Screw you, master...'
