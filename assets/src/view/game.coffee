stockInfoObj = require "../config/stockInfo"
utils = require "../common/Utils"
cc.Class {
    extends: cc.Component

    properties: {
        # foo:
        #   default: null      # The default value will be used only when the component attaching
        #                        to a node for the first time
        #   type: cc
        #   serializable: true # [optional], default is true
        #   visible: true      # [optional], default is true
        #   displayName: 'Foo' # [optional], default is property name
        #   readonly: false    # [optional], default is false
        m_content: cc.Node,
        m_stock_prefab: cc.Prefab,
        m_year: cc.Label,
        m_money: cc.Label,
        m_stock_money: cc.Label
        m_last_year: cc.Label,
        m_tips_Label: cc.Label
    }

    onLoad: ->
        # cc.game.addPersistRootNode(this.node)
        @_stockPanelTable = []
        @_updateYear()
        @_updateMoney()
        @_initStockPanel()
        @_updateStockInfo()
        @_setCount()
        @_showDividendInfo()

    _setCount: ->
        count = utils.getItem("playCount") or 0
        utils.setItem("playCount", count + 1)
        
    _initTips: (string) ->
        @m_tips_Label.string = string

    _updateMoney: ->
        moneyCash = 0
        marketMoney = 0
        utils.triggerEvent("getMoney",
            ({ money, stockMoney }) ->
                moneyCash = money
                marketMoney = stockMoney
        )
        @m_money.string = "游戏币: " + utils.formatNum(moneyCash)
        @m_stock_money.string = "市值: " + utils.formatNum(marketMoney)

    _initStockPanel: ->
        for stockCode , value of stockInfoObj
            stockPanel = cc.instantiate(@m_stock_prefab)
            @m_content.addChild(stockPanel)
            @_stockPanelTable.push stockPanel
            button = cc.find("touch", stockPanel)
            @_addTouchEvent(button, stockCode)
        return

    _initName: (stockCode, stockIndex) ->
        nameLabel = cc.find("infoNode/name", @_stockPanelTable[stockIndex]).getComponent(cc.Label)
        utils.triggerEvent("getStockName", {
            stockCode: stockCode
            callback: (name) ->
                nameLabel.string = name
        })
        

    _initPrice: (stockCode, stockIndex) ->
        priceLabel = cc.find("infoNode/price", @_stockPanelTable[stockIndex]).getComponent(cc.Label)
        utils.triggerEvent("getStockPrice", {
            stockCode: stockCode
            callback: (price) ->
                priceLabel.string = "市价: " + price
        })

    _initPE: (stockCode, stockIndex) ->
        peLabel = cc.find("infoNode/pe", @_stockPanelTable[stockIndex]).getComponent(cc.Label)
        utils.triggerEvent("getStockPE", {
            stockCode: stockCode
            callback: (PE) ->
                peLabel.string = "PE: " + PE
        })

    _initDesc: (stockCode, stockIndex) ->
        descNode = cc.find("infoNode/desc", @_stockPanelTable[stockIndex])
        descLabel = descNode.getComponent(cc.Label)

        utils.triggerEvent("getStockPriceWaveAndTips", {
            stockCode: stockCode
            callback: (priceWave, tipsType) ->
                desc = ""
                priceAddPercent = if priceWave > 0 then "(+#{priceWave}%)" else "(#{priceWave}%)"
                switch tipsType
                    when "normalPe"
                        desc = "均值回归" + priceAddPercent
                        descLabel.node.color = cc.Color.MAGENTA
                    when "originPe"
                        desc = "人气分散" + priceAddPercent
                        descLabel.node.color = cc.Color.CYAN
                    when "normal"
                        if priceWave < 0
                            desc = priceAddPercent
                            descLabel.node.color = cc.Color.GREEN
                        else if priceWave > 0
                            desc = priceAddPercent
                            descLabel.node.color = cc.Color.RED
                descLabel.string = desc
        })

    _updateStockInfo: ->
        year = -1
        utils.triggerEvent("getYear", (value) -> year = value)
        stockIndex = 0
        for stockCode , value of stockInfoObj
            @_initName(stockCode, stockIndex)
            @_initPrice(stockCode, stockIndex)
            @_initPE(stockCode, stockIndex)
            @_initDesc(stockCode, stockIndex)
            stockIndex++
        return

    _addTouchEvent: (button, stockCode) ->
        clickEventHandler = new cc.Component.EventHandler()
        clickEventHandler.target = this.node # 这个 node 节点是你的事件处理代码组件所属的节点
        clickEventHandler.component = "game" #这个是代码文件名
        clickEventHandler.handler = "onTouchItem" #
        clickEventHandler.customEventData = stockCode

        ccButton = button.getComponent(cc.Button)
        ccButton.clickEvents.push(clickEventHandler)

    onTouchItem: (event, customEventData) ->
        console.log("customEventData:#{JSON.stringify customEventData}")
        stockCode = customEventData
        @_onExchangeStockCode = stockCode
        utils.setDataOnNode({ stockCode, type: "buy" })
        utils.triggerEvent("showExchangeDialog")

    _updateYear: ->
        year = -1
        utils.triggerEvent("getYear", (value) -> year = value)
        @m_year.string = "年份: " + (year + 2019)
        @m_last_year.string = "还剩 " + (50 - year) + " 年"

    onNextYear: ->
        TDGA?.onEvent("nextYear")
        isAddYearSuccess = false

        utils.triggerEvent("nextYear", (status) ->
            isAddYearSuccess = status
        )
        return unless isAddYearSuccess
        @_showDividendInfo()
        @_updateYear()
        @_updateMoney()
        @_updateStockInfo()

    _showDividendInfo: ->
        dividendMoney = 0
        utils.triggerEvent("getDividendMoney", (money) ->
            dividendMoney = money
        )
        if dividendMoney > 0
            string = "股票分红，获得: " + utils.formatNum(dividendMoney) + "元"
        else if dividendMoney is -1
            string = "今年公司不分红，具体原因请看公告"
        else
            string = "有股票才有分红哦"
        @_initTips(string)

    onOpenOwnStock: ->
        utils.triggerEvent("openMyStockDialog")

    onExit: ->
        moneyCash = 0
        marketMoney = 0
        utils.triggerEvent("getMoney",
            ({ money, stockMoney }) ->
                moneyCash = money
                marketMoney = stockMoney
        )

        eventObj = { currentMoney: (moneyCash + marketMoney) + "" }

        TDGA?.onEvent("gameReturn", eventObj)
        cc.director.loadScene("WelcomeDialog")
}
