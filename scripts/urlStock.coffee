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

    # Hello World!!
    robot.hear /stockbot hello/i, (msg) ->
        msg.send "Hello \nWorld!!"

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
    robot.hear /stockbot fetch category urls (.*)$/i, (msg) ->
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

    # MARK: UPDATE

    # 特定IDのurl更新
    robot.hear /stockbot update url (.*)$/i, (msg) ->
        args = msg.match[1].split(/\s+/)
        for key, value of stock_urls() when "#{value['id']}" is args[0]
            msg.send "before - #{value['id']}: #{value['url']} category:#{value['category']} comment: #{value['comment']}"
            newStockUrl = {}
            newStockUrl['id'] = value['id']
            newStockUrl['url'] = args[1]
            newStockUrl['category'] = value['category']
            newStockUrl['comment'] = value['comment']
            msg.send "after - #{newStockUrl['id']}: #{newStockUrl['url']} category:#{newStockUrl['category']} comment: #{newStockUrl['comment']}"
            msg.send "更新したよー"
            stock_urls().splice(key, 1, newStockUrl)

    # 特定IDのcategory更新
    robot.hear /stockbot update category (.*)$/i, (msg) ->
        args = msg.match[1].split(/\s+/)
        for key, value of stock_urls() when "#{value['id']}" is args[0]
            msg.send "before - #{value['id']}: #{value['url']} category:#{value['category']} comment: #{value['comment']}"
            newStockUrl = {}
            newStockUrl['id'] = value['id']
            newStockUrl['url'] = value['url']
            newStockUrl['category'] = args[1]
            newStockUrl['comment'] = value['comment']
            msg.send "after - #{newStockUrl['id']}: #{newStockUrl['url']} category:#{newStockUrl['category']} comment: #{newStockUrl['comment']}"
            msg.send "更新したよー"
            stock_urls().splice(key, 1, newStockUrl)

    # 特定IDのcomment更新
    robot.hear /stockbot update comment (.*)$/i, (msg) ->
        args = msg.match[1].split(/\s+/)
        for key, value of stock_urls() when "#{value['id']}" is args[0]
            msg.send "before - #{value['id']}: #{value['url']} category:#{value['category']} comment: #{value['comment']}"
            newStockUrl = {}
            newStockUrl['id'] = value['id']
            newStockUrl['url'] = value['url']
            newStockUrl['category'] = value['category']
            newStockUrl['comment'] = args[1]
            msg.send "after - #{newStockUrl['id']}: #{newStockUrl['url']} category:#{newStockUrl['category']} comment: #{newStockUrl['comment']}"
            msg.send "更新したよー"
            stock_urls().splice(key, 1, newStockUrl)

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
    robot.hear /stockbot urls all reset/i, (msg) ->
        robot.brain.set(STOCK_URLS, null)
        msg.send "stock urlsを全リセットしたよー"

    # help
    robot.hear /stockbot help/i, (msg) ->
        msg.send "stock URL値: URLをストックする"
        msg.send "stock URL値 カテゴリ名(c_なんとか): URLをストックする"
        msg.send "stock URL値 コメント: URLをコメント付きでストックする"
        msg.send "stockbot fetch all urls: 全ストックURLを教えてくれる"
        msg.send "stockbot fetch urls per categories: カテゴリごとで全ストックURLを教えてくれる"
        msg.send "stockbot fetch categories: 全カテゴリを教えてくれる"
        msg.send "stockbot fetch category urls カテゴリ名(c_なんとか): 特定カテゴリのストックURLを教えてくれる"
        msg.send "stockbot fetch url ID値: 特定IDのストックURLを教えてくれる"
        msg.send "stockbot update url ID値 URL値: 特定IDのURLを更新する"
        msg.send "stockbot update category ID値 カテゴリ値: 特定IDのカテゴリを更新する"
        msg.send "stockbot update comment ID値 コメント: 特定IDのコメントを更新する"
        msg.send "stockbot delete ID値: 特定IDのストックURLを削除する"
        msg.send "stockbot category delete ID値: 特定カテゴリのストックURLを全て削除する"
        msg.send "stockbot urls all reset: ストックURLを全て削除する"
