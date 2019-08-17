utils = require "../common/Utils"

cc.Class {
    extends: cc.Component

    properties: {
        m_own_stock_prefab: cc.Prefab,
        m_own_stocks_content: cc.Node,
    }

    onLoad: ->
        TDGA?.onEvent("ownStock")
        @_showAllStocks()

    _initOwnStockInfo: (panel, stockInfo) ->
        name = cc.find("name", panel).getComponent(cc.Label)
        name.string = stockInfo.stockName
        numLable = cc.find("num", panel).getComponent(cc.Label)
        numLable.string = stockInfo.num
        priceLable = cc.find("price", panel).getComponent(cc.Label)
        priceLable.string = stockInfo.price

    _showAllStocks: ->
        ownStocks = []
        utils.triggerEvent("getOwnStocks", (value) -> ownStocks = value)
        stockPanel = cc.instantiate(@m_own_stock_prefab)
        @m_own_stocks_content.addChild(stockPanel)
        @_initOwnStockInfo(stockPanel, { stockName: "名称", num: "数量", price: "成本价格" })
        for stockInfo in ownStocks
            stockPanel = cc.instantiate(@m_own_stock_prefab)
            @m_own_stocks_content.addChild(stockPanel)
            @_initOwnStockInfo(stockPanel, stockInfo)
            button = cc.find("touch", stockPanel).getComponent(cc.Button)
            @_addTouchEvent(button, stockInfo.stockCode)
        return

    _addTouchEvent: (button, stockCode) ->
        clickEventHandler = new cc.Component.EventHandler()
        clickEventHandler.target = this.node # 这个 node 节点是你的事件处理代码组件所属的节点
        clickEventHandler.component = "OwnStocksDialog" #这个是代码文件名
        clickEventHandler.handler = "onTouchItem" #
        clickEventHandler.customEventData = stockCode

        ccButton = button.getComponent(cc.Button)
        ccButton.clickEvents.push(clickEventHandler)

    onTouchItem: (event, customEventData) ->
        stockCode = customEventData
        @_onExchangeStockCode = stockCode
        utils.setDataOnNode({ stockCode, type: "sale" })
        utils.triggerEvent("showExchangeDialog")

    onClose: ->
        cc.director.loadScene("game")
}
