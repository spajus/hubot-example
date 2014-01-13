# Description:
#   Tells the weather
#
# Configuration:
#   HUBOT_WEATHER_API_URL - Optional openweathermap.org API endpoint to use
#   HUBOT_WEATHER_UNITS - Temperature units to use. 'metric' or 'imperial'
#
# Commands:
#   weather in <location> - Tells about the weather in given location
#
# Author:
#   spajus

process.env.HUBOT_WEATHER_API_URL ||=
  'http://api.openweathermap.org/data/2.5/weather'
process.env.HUBOT_WEATHER_UNITS ||= 'imperial'

module.exports = (robot) ->
  robot.hear /weather in (\w+)/i, (msg) ->
    city = msg.match[1]
    query = "units=#{process.env.HUBOT_WEATHER_UNITS}" +
            "&q=#{encodeURIComponent(city)}"
    url = "#{process.env.HUBOT_WEATHER_API_URL}?#{query}"
    msg.robot.http(url).get() (err, res, body) ->
      data = JSON.parse(body)
      weather = [ "#{Math.round(data.main.temp)} degrees" ]
      for w in data.weather
        weather.push w.description
      msg.reply "It's #{weather.join(', ')} in #{data.name}, #{data.sys.country}"
