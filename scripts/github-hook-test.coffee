# Description:
#   Dumps HTTP requests received to /github/test
#
# URLS:
#   GET /github/test
#   POST /github/test
#   PUT /github/test

module.exports = (robot) ->

  robot.router.get "/github/test", (req, res) ->
    dump 'Received GET:', req, res

  robot.router.post "/github/test", (req, res) ->
    dump 'Received POST:', req, res

  robot.router.put "/github/test", (req, res) ->
    dump 'Received PUT:', req, res

  dump = (message, req, res) ->
    console.log message, JSON.stringify(req.body, null, 2)
    res.end()
