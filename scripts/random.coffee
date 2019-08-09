module.exports = (robot) ->

    robot.respond /(?:えら|選)んで (.*)$/i, (msg) ->
    items = msg.match[1].split(/\s+/)
    msg.send draw(items) + " をえらんだよー"