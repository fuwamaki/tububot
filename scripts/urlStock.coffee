# STG利用状況
module.exports = (robot) ->
    # MARK: static variables
    STOCK_URLS = 'stock_urls'
    NEXT_STOCK_NUBMER = 'next_stock_number'

    # ストックURL一覧
    stock_urls = ->
        robot.brain.get(STOCK_URLS) || []

    # カテゴリ一覧
    categories = ->
        array = []
        for stockUrl in stock_urls()
            if stockUrl['category']?
                if stockUrl['category'] in array
                else array.push(stockUrl['category'])
        return array

    # カテゴリごとのストックURL一覧
    urls_per_category = (msg, category) ->
        for stockUrl in stock_urls() when stockUrl['category'] is category
                    msg.send "#{stockUrl['id']}: #{stockUrl['url']} comment: #{stockUrl['comment']}"

    # MARK: GET

    # fetch ストックURL一覧
    robot.hear /stockbot fetch all urls/i, (msg) ->
        for stockUrl in stock_urls()
            msg.send "#{stockUrl['id']}: #{stockUrl['url']} category:#{stockUrl['category']} comment: #{stockUrl['comment']}"

    # fetch カテゴリ一覧
    robot.hear /stockbot fetch categories/i, (msg) ->
        result = categories()
        if result is [] then "カテゴリがないよー"
        else msg.send "カテゴリ一覧だよー: #{result}"

    # fetch カテゴリごとのストックURL一覧
    robot.hear /stockbot fetch c_urls/i, (msg) ->
        for category in categories()
            msg.send "#{category}:"
            urls_per_category msg, category
        # カテゴリなしのストックURL一覧
        msg.send "カテゴリなし:"
        for stockUrl in stock_urls() when not stockUrl['category']?
            msg.send "#{stockUrl['id']}: #{stockUrl['url']} comment: #{stockUrl['comment']}"

    # MARK: SET

    # urlをstockする
    robot.hear /stock (.*)$/i, (msg) ->
        args = msg.match[1].split(/\s+/)
        urlInfo = {}
        for arg in args
            # url文字列だったら最初のものを保存
            if arg.indexOf("http") is 0
                urlInfo['url'] = arg
                break
        # urlが含まれてなければreturnする
        if not urlInfo['url']?
            msg.send "stockするurlが入ってないよー"
            return
        for arg in args
            # カテゴリを吸い上げる
            if arg.indexOf("c_") is 0
                urlInfo['category'] = arg
                break
        for arg in args
            # コメントを吸い上げる
            if arg.indexOf("http") isnt 0 and arg.indexOf("c_") isnt 0
                urlInfo['comment'] = arg
                break
        # idをset
        nextStockNumber = robot.brain.get(NEXT_STOCK_NUBMER) || 0
        urlInfo['id'] = nextStockNumber
        robot.brain.set(NEXT_STOCK_NUBMER, nextStockNumber + 1)
        # stockUrlsにurlInfoをset
        stockUrls = stock_urls()
        stockUrls.push(urlInfo)
        robot.brain.set(STOCK_URLS, stockUrls)
        msg.send "登録したよー #{urlInfo['id']}: #{urlInfo['url']} category:#{urlInfo['category']} comment: #{urlInfo['comment']}"            

    # MARK: DELETE

    # stock_urlsを全部リセットする
    robot.hear /stockbot all reset/i, (msg) ->
        robot.brain.set(STOCK_URLS, null)
        msg.send "stock urlsを全リセットしたよー"

# - [x] urlをstockしてくれる(set)
# - urlをコメント付きでstockしてくれる(set)
# - urlをカテゴリ付きでstockしてくれる(set)
# - [x] urlをコメント・カテゴリ付きでstockしてくれる(set)
# - url stockにコメントを付けれる(update)
# - url stockにカテゴリを付けれる(update)
# - url stock情報を更新できる(update)
# - カテゴリ一覧を見れる(get)
# - 特定のurl情報を見れる(get)
# - 特定のカテゴリのurl一覧を見れる(get)
# - 全url一覧を見れる(get)
# - 特定のurl stockを削除(delete)
# - 特定のカテゴリのurlを削除(delete)
# - 全url stockを削除(delete) 確認必須