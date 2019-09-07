# STG利用状況
module.exports = (robot) ->
    # MARK: static variables
    SAMPLE_URL = 'sample'
    SAMPLE_COMMENT = 'sample_comment'
    SAMPLE_CATEGORY = 'sample_category'
    STOCK_URLS = 'stock_urls'
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
        args = msg.match[1].split(/\s+/)
        stockUrl = {}
        for arg in args
            # url文字列だったら最初のものを保存
            if arg.indexOf("http") is 0
                stockUrl['url'] = arg
                break
        # urlが含まれてなければreturnする
        if not stockUrl['url']?
            msg.send "stockするurlが入ってないよー"
            return
        for arg in args
            # カテゴリを吸い上げる
            if arg.indexOf("c_") is 0
                stockUrl['category'] = arg
                break
        for arg in args
            # コメントを吸い上げる
            if arg.indexOf("http") isnt 0 and arg.indexOf("c_") isnt 0
                stockUrl['comment'] = arg
                break
        nextStockNumber = robot.brain.get(NEXT_STOCK_NUBMER) || 0
        stockUrl['id'] = nextStockNumber
        robot.brain.set(NEXT_STOCK_NUBMER, nextStockNumber + 1)
        stockUrls = robot.brain.get(STOCK_URLS) || []
        stockUrls.push(stockUrl)
        robot.brain.set(STOCK_URLS, stockUrls)
        for aaa in stockUrls
            msg.send "登録URLや #{aaa['url']}"
            msg.send "登録カテゴリや #{aaa['category']}"
            msg.send "登録コメントや #{aaa['comment']}"

    # stock_urlsを全部リセットする
    robot.hear /stockbot all reset/i, (msg) ->
        robot.brain.set(STOCK_URLS, null)
        msg.send "stock urlsを全リセットしたよー"