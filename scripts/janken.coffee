module.exports = (robot) ->

    robot.respond /(じゃんけん|ジャンケン)$/, (msg) ->
        items = [':gu-:', ':choki:', ':pa-:']
        index = Math.floor(Math.random() * 3)
        msg.send "#{items[index]}"
