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

    # 特定IDのストックURL
    stock_url = (id) ->
        for stockUrl in stock_urls() when "#{stockUrl['id']}" is id
            return stockUrl
        return null

    # 特定IDのストックURLを削除
    delete_stock_url = (id) ->
        for key, value of stock_urls() when "#{value['id']}" is id
            stock_urls().splice(key, 1)
            return true
        return false

    # 特定カテゴリのストックURLを削除
    delete_category = (category) ->
        # 注意: stock_urls().splice をするとstock_urls()の値が変わるので勝手にfor文をbreakしてしまう
        for key, value of stock_urls() when "#{value['category']}" is category
            stock_urls().splice(key, 1)
            return true
        return false

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
    robot.hear /stockbot fetch urls per categories/i, (msg) ->
        for category in categories()
            msg.send "#{category}:"
            urls_per_category msg, category
        # カテゴリなしのストックURL一覧
        msg.send "カテゴリなし:"
        for stockUrl in stock_urls() when not stockUrl['category']?
            msg.send "#{stockUrl['id']}: #{stockUrl['url']} comment: #{stockUrl['comment']}"

    # fetch 特定のカテゴリのストックURL一覧
    robot.hear /stockbot fetch urls (.*)$/i, (msg) ->
        args = msg.match[1].split(/\s+/)
        if args[0].indexOf("c_") is 0
            msg.send "#{args[0]}:"
            urls_per_category msg, args[0]

    # fetch 特定IDのurl情報
    robot.hear /stockbot fetch url (.*)$/i, (msg) ->
        args = msg.match[1].split(/\s+/)
        stockUrl = stock_url args[0]
        if stockUrl? then msg.send "#{stockUrl['id']}: #{stockUrl['url']} category:#{stockUrl['category']} comment: #{stockUrl['comment']}"
        else msg.send "#{args[0]}のURLはないよー"

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

    # 特定IDのストックURLを削除
    robot.hear /stockbot delete (.*)$/i, (msg) ->
        args = msg.match[1].split(/\s+/)
        result = delete_stock_url args[0]
        if result is true then msg.send "ID #{args[0]} を削除したよー"
        else msg.send "ID #{args[0]} は存在しないみたいだよー"

    # 特定カテゴリのストックURLを削除
    robot.hear /stockbot category delete (.*)$/i, (msg) ->
        args = msg.match[1].split(/\s+/)
        count = 0
        while delete_category args[0]
            count += 1
        if count > 0 then msg.send "カテゴリ #{args[0]} を #{count}個 削除したよー"
        else msg.send "カテゴリ #{args[0]} は存在しないみたいだよー"

    # stock_urlsを全部リセットする
    robot.hear /stockbot all reset/i, (msg) ->
        robot.brain.set(STOCK_URLS, null)
        msg.send "stock urlsを全リセットしたよー"

# - [x] urlをstockしてくれる(set)
# - [x] urlをコメント付きでstockしてくれる(set)
# - [x] urlをカテゴリ付きでstockしてくれる(set)
# - [x] urlをコメント・カテゴリ付きでstockしてくれる(set)
# - url stockにコメントを付けれる(update)
# - url stockにカテゴリを付けれる(update)
# - url stock情報を更新できる(update)
# - [x] カテゴリ一覧を見れる(get)
# - [x] 特定のurl情報を見れる(get)
# - [x] 特定のカテゴリのurl一覧を見れる(get)
# - [x] 全url一覧を見れる(get)
# - [x] 特定のurl stockを削除(delete)
# - [x] 特定のカテゴリのurlを削除(delete)
# - 全url stockを削除(delete) 確認必須