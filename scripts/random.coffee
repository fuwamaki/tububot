module.exports = (robot) ->

	robot.respond /(?:えら|選)んで (.*)$/i, (res) ->
		items = res.match[1].split(/\s+/)
		res.reply draw(items) + " をえらんだよー"

	draw = (items) ->
		index = Math.floor(Math.random() * items.length)
		items[index]
