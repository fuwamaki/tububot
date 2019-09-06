# STG利用状況
module.exports = (robot) ->
    # MARK: static variables
    SAMPLE = 'sample'
    STOCK_URLS = 'urls'
    NEXT_STOCK_NUBMER = 'next_stock_number'

    # 返すロジック
    # goFree = (msg, env, name) ->
    #     usingUser = robot.brain.get(env)
    #     if name is usingUser
    #         robot.brain.set(env, null)
    #         msg.send ":stgbot: > #{env} を解放したよー"
    #     else
    #         msg.send ":stgbot: > #{name} は #{env} をそもそも使ってないよ？"

    # urlをstockする
    robot.hear /stock (.*)$/i, (msg) ->
        url = msg.match[1].split(/\s+/)
        robot.brain.set(SAMPLE, url)
        msg.send "登録や #{url}"
