cronJob = require('cron').CronJob

module.exports = (robot) ->

    send = (channel, msg) ->
        robot.send {room: channel}, msg

	# *(sec) *(min) *(hour) *(day) *(month) *(day of the week)
    # #_fuwamakiと言う部屋に、月曜の11:00時に実行
    cronjob = new cronJob('00 42 * * * *', () ->
        send '#_fuwamaki', "cron test"
    )
    cronjob.start()

    robot.hear /cronbot start/i, (msg) ->
        cronjob.start()
        msg.send "cronスタートするよ"
        return