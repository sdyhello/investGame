
StockData = require '../model/StockData'
StockInfo = require "../config/stockInfo"
UserData = require "../model/UserData"
utils = require "../common/Utils"

USER_DATA_KEY = "user.data.key"
STOCK_DATA_KEY = "stock.data.key"

K_LINE = [
        [1, 6, 6, 7, 7, 6, 6, 10, 20, 50, 60,
            100, 150, -20, -10, -30, -6, 6, 6, -7, 8,
            -5, 5, -5, 6, -20, -10, 10, 10, 30, 50,
            60, 10, 80, 20, 10, 20, -10, -20, 30, -20,
            5, 6, 7, 9, 10, -20, -10, 90, -30, 80,
        ], [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        ], [1, -5, -5, -10, 10, -5, -3, -3, -3, -3, -3,
            -5, -5, -10, 10, -5, -3, -3, -3, -3, -3,
            -5, -5, -10, 10, -5, -3, -3, -3, -3, -3,
            -5, -5, -10, 10, -5, -3, -3, -3, -3, -3,
            -5, -5, -10, 10, -5, -3, -3, -3, -3, -3,
        ], [1, 6, 6, 6, 6, 6, 6, 10, 15, 6, 6,
            -6, -6, -6, -6, -6, -6, -10, -15, -6, -6,
            6, 6, 6, 6, 6, 6, 10, 15, 6, 6,
            -6, -6, -6, -6, -6, -6, -10, -15, -6, -6,
            6, 6, 6, 6, 6, 6, 10, 15, 6, 6,
        ],  [1, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
            5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
            5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
            5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
            5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
        ]
        ]
NORMAL_PE = 30

cc.Class {
    extends: cc.Component

    onLoad: ->
        @_userData = new UserData()
        @_loadUserData()
        @_registerEventListener()
        @_initStockInfo()
        @_loadStockData()
        @_kLineIndex = 0
        @_dividendMoney = 0
        cc.game.addPersistRootNode(this.node)

    _loadUserData: ->
        defaultData = @_userData.save()
        saveData = utils.getItem(USER_DATA_KEY) or defaultData
        @_userData.load(saveData)

    _loadStockData: ->
        for key, stockData of @_allStockDataObj
            defaultData = stockData.save()
            saveData = utils.getItem(STOCK_DATA_KEY + key) or defaultData
            stockData.load(saveData)
        return

    _registerEventListener: ->
        utils.bindEvent('buyStock', ({ stockCode, num }) =>
            stockData = @_allStockDataObj[stockCode]
            price = stockData.getPrice()
            allCostMoney = num * price
            stockName = stockData.getName()
            currentMoney = @_userData.getMoney()
            if currentMoney >= allCostMoney
                afterBuyMoney = currentMoney - allCostMoney
                @_userData.setMoney(afterBuyMoney)
                currentStocks = @_userData.getOwnStocks()

                isExistStock = false
                for stock in currentStocks
                    if stock.stockName is stockName
                        isExistStock = true
                        price = (stock.num * stock.price + num * price) / (stock.num + num) * 100
                        stock.price = Math.floor(price / 100)
                        stock.num += num
                        break
                if isExistStock is false
                    currentStocks.push { stockCode, stockName, num , price }

                @_userData.setOwnStocks(currentStocks)
                @_saveUserData()
            console.log("msg : " + JSON.stringify { stockName, num, price })
        )

        utils.bindEvent('nextYear', (callback) =>
            year = @_userData.getYear()

            if @_randomInt(1, 10) in [1]
                priceReturn = true
            else if @_randomInt(1, 10) in [5]
                PeReturn = true
                
            if year < K_LINE[@_kLineIndex].length - 1
                @_userData.addYear()
                @_updateStockData(priceReturn, PeReturn)
                @_dividendMoney = @_dividend()
                @_saveUserData()
                @_saveStockData()
                callback(true)
            else
                callback(false)
                cc.director.loadScene("EndDialog")
        )

        utils.bindEvent("getOwnStockNum", ({ stockCode, callback }) =>
            callback(@_getStockNum(stockCode))
        )

        utils.bindEvent('saleStock', ({ stockCode, num }) =>
            stockOwnNum = @_getStockNum(stockCode)
            if stockOwnNum < num
                return

            stockData = @_allStockDataObj[stockCode]
            price = stockData.getPrice()
            allAddMoney = num * price
            currentMoney = @_userData.getMoney()
            afterMoney = currentMoney + allAddMoney
            @_userData.setMoney(afterMoney)

            @_delStockNum(stockCode, num)
        )

        utils.bindEvent("getMoney", (callback) =>
            money = Math.floor(@_userData.getMoney())
            allOwnStocks = @_userData.getOwnStocks()
            stockMoney = 0
            for stockInfo in allOwnStocks
                stockPrice = @_getStockPriceByStockCode(stockInfo.stockCode)
                stockNum = stockInfo.num
                stockMoney += (stockNum * stockPrice)
            stockMoney = Math.floor(stockMoney)
            callback({ money, stockMoney })
        )

        utils.bindEvent("getStockPrice", ({ callback, stockCode }) =>
            callback(@_getStockPriceByStockCode(stockCode))
        )

        utils.bindEvent("getStockPE", ({ callback, stockCode }) =>
            stockData = @_allStockDataObj[stockCode]
            callback(stockData.getPE())
        )

        utils.bindEvent("getStockName", ({ callback, stockCode }) =>
            stockData = @_allStockDataObj[stockCode]
            callback(stockData.getName())
        )

        utils.bindEvent("getStockPriceWaveAndTips", ({ callback, stockCode }) =>
            stockData = @_allStockDataObj[stockCode]
            callback(stockData.getPriceWave(), stockData.getTipsType())
        )

        utils.bindEvent("showExchangeDialog", ->
            cc.director.loadScene("ExchangePanel")
        )

        utils.bindEvent("getYear", (callback) =>
            callback(@_userData.getYear())
        )

        utils.bindEvent("openMyStockDialog", ->
            cc.director.loadScene("OwnStocksDialog")
        )

        utils.bindEvent("getOwnStocks", (callback) =>
            callback(@_userData.getOwnStocks())
        )

        utils.bindEvent("resetGame", =>
            @_userData.reset()
            @_saveUserData()

            for key, stockData of @_allStockDataObj
                utils.setItem(STOCK_DATA_KEY + key, null)

            @_initStockInfo()
            for key, stockData of @_allStockDataObj
                defaultData = stockData.save()
                localData = utils.getItem(STOCK_DATA_KEY + key)
                
                saveData = localData or defaultData
                stockData.load(saveData)
            return
        )

        utils.bindEvent("selectKLine", =>
            count = utils.getItem("playCount") or 0
            if count is 1
                @_kLineIndex = 0
            else
                @_kLineIndex = @_randomInt(0, 4)
        )

        utils.bindEvent("getKline", (callback) =>
                callback(@_kLineIndex)
            )

        utils.bindEvent("getDividendMoney", (callback) =>
                callback(@_dividendMoney)
            )
    _dividend: ->
        if @_randomInt(1, 10) is 1
            return -1
        allStocks = @_userData.getOwnStocks()
        totalDividMoney = 0
        for stockInfo in allStocks
            stockData = @_allStockDataObj[stockInfo.stockCode]
            dividend = stockData.getDividend()
            singleStockDividendMoney = dividend * stockData.getPrice()
            dividendMoney = Math.floor((stockInfo.num * singleStockDividendMoney) * 100) / 100
            totalDividMoney += dividendMoney
            price = stockData.getPrice()
            stockData.setPrice(Math.floor((price - singleStockDividendMoney) * 100) / 100)
            money = @_userData.getMoney()
            @_userData.setMoney(money + dividendMoney)

            PE = stockData.getPE()
            PE = Math.floor((PE * (1 - dividend)) * 100) / 100
            stockData.setPE(PE)
        totalDividMoney = Math.floor(totalDividMoney)
        return totalDividMoney

    _delStockNum: (stockCode, num) ->
        stocks = @_userData.getOwnStocks()
        targetStock = null
        for stock, index in stocks
            if stockCode is stock.stockCode
                targetStock = stock
                break
        afterDelNum = targetStock.num - num
        if afterDelNum is 0
            stocks.splice(index, 1)
        else
            targetStock.num = afterDelNum

    _getStockNum: (stockCode) ->
        stocks = @_userData.getOwnStocks()
        for stock in stocks
            if stockCode is stock.stockCode
                return stock.num
        return 0

    _getStockPriceByStockCode: (stockCode) ->
        stockData = @_allStockDataObj[stockCode]
        stockData.getPrice()

    _randomInt: (min, max) ->
        Math.floor(Math.random() * (max - min + 1)) + min

    _updateStockData: (priceReturn, PeReturn) ->
        year = @_userData.getYear()
        baseChange = K_LINE[@_kLineIndex][year]
        for key, stockData of @_allStockDataObj
            if priceReturn is true or PeReturn is true
                superPE = 0
                if priceReturn is true
                    superPE = NORMAL_PE
                    stockData.setTipsType("normalPe")
                if PeReturn is true
                    superPE = stockData.getOriginPE()
                    stockData.setTipsType("originPe")
                superPE = superPE + @_randomInt(-2, 2)
                PE = stockData.getPE()
                disPE = superPE - PE
                addPercent = Math.floor((disPE / PE) * 100) / 100
                price = stockData.getPrice()
                afterPrice = Math.floor(price * (1 + addPercent) * 100) / 100
                stockData.setPriceWave(Math.floor(addPercent * 100))
                stockData.setPrice(afterPrice)
                stockData.setPE(superPE)
            else
                price = stockData.getPrice()

                priceWave = @_randomInt(-60, 100)
                
                stockData.setTipsType("normal")
                randomPrice = @_randomInt(-priceWave, priceWave)
                afterPrice = Math.floor((((randomPrice + baseChange) / 100 + 1) * price) * 100)
                afterPrice = afterPrice  / 100
                stockData.setPriceWave(randomPrice + baseChange)
                stockData.setPrice(afterPrice)

                PE = stockData.getPE()
                changeRatio = randomPrice + baseChange
                peWave = stockData.getPEWave()
                afterPE = Math.floor((((changeRatio * (1 - peWave)) / 100 + 1) * PE) * 100) / 100
                stockData.setPE(afterPE)
            
        return

    _saveUserData: ->
        data = @_userData.save()
        utils.setItem(USER_DATA_KEY, data)

    _saveStockData: ->
        for key, stockData of @_allStockDataObj
            data = stockData.save()
            utils.setItem(STOCK_DATA_KEY + key, data)
        return

    _setItem: (name, value) ->
        cc.sys.localStorage.setItem(name, JSON.stringify value)

    _getItem: (name) ->
        try JSON.parse cc.sys.localStorage.getItem(name)

    _initStockInfo: ->
        @_allStockDataObj = {}
        for key, value of StockInfo
            stockData = new StockData(value)
            peWave = @_randomInt(1, 10) / 10
            stockData.setPEWave(peWave)
            dividend = @_randomInt(1, 10) / 100
            stockData.setDividend(dividend)
            price = @_randomInt(10, 200)
            stockData.setPrice(price)
            pe = @_randomInt(5, 100)
            stockData.setPE(pe)
            @_allStockDataObj[key] = stockData
        return
}

