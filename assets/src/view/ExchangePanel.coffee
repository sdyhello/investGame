stockInfoObj = require "../config/stockInfo"
utils = require "../common/Utils"

cc.Class {
    extends: cc.Component
    properties: {
        m_input_label: cc.EditBox,
        m_buy_button: cc.Node,
        m_sale_button: cc.Node,
        m_max_num: cc.Label,
    }
        
    onLoad: ->
        { stockCode, type } = utils.getDataFromNode()
        TDGA?.onEvent("exchange", { type: type })
        @_stockCode = stockCode
        @_exchangeType = type
        @_exchangeNum = 100
        @_setExchangeButton()
        @_initBuyNodeInfo(stockCode)
        @_addBuyPanelEditbox()

    _setExchangeButton: ->
        @m_buy_button.active =  @_exchangeType is "buy"
        @m_sale_button.active =  @_exchangeType is "sale"

    _initBuyNodeInfo: (stockCode) ->
        moneyCash = 0
        utils.triggerEvent("getMoney",
            ({ money }) ->
                moneyCash = money
        )
        ownStockNum = 0
        utils.triggerEvent("getOwnStockNum", {
            stockCode: stockCode,
            callback: (num) -> ownStockNum = num
        }
        )

        nameLabel = cc.find("buyNode/name", @node).getComponent(cc.Label)
        utils.triggerEvent("getStockName", {
            stockCode: stockCode,
            callback: (name) ->
                nameLabel.string = name
        })
        priceLable = cc.find("buyNode/price", @node).getComponent(cc.Label)
        utils.triggerEvent("getStockPrice", {
            stockCode: stockCode,
            callback: (price) =>
                priceLable.string = price
                if @_exchangeType is "buy"
                    maxNum = Math.floor(moneyCash / price)
                    @m_max_num.string = maxNum
                    @_maxNum = maxNum
                else if @_exchangeType is "sale"
                    maxNum = ownStockNum
                    @m_max_num.string = maxNum
                    @_maxNum = maxNum
        })

    _addBuyPanelEditbox: ->
        @_addEditBoxEventHandler(@m_input_label)

    _addEditBoxEventHandler: (editboxObj) ->
        editboxEventHandler = new cc.Component.EventHandler()
        editboxEventHandler.target = @node
        editboxEventHandler.component = "ExchangePanel"
        editboxEventHandler.handler = "onTextChanged"
        editboxObj.editingDidEnded.push(editboxEventHandler)

    onTextChanged: (editbox) ->
        @_exchangeNum = parseInt(editbox.string)

    onBuy: ->
        num = @_exchangeNum
        stockCode = @_stockCode
        utils.triggerEvent('buyStock', { stockCode, num })
        cc.director.loadScene("game")

    onSale: ->
        num = @_exchangeNum
        stockCode = @_stockCode
        utils.triggerEvent("saleStock", { stockCode, num })

        utils.triggerEvent("getOwnStocks", (ownStockTable) ->
            if ownStockTable.length > 0
                cc.director.loadScene("OwnStocksDialog")
            else
                cc.director.loadScene("game")
        )

    onClose: ->
        if @_exchangeType is "buy"
            cc.director.loadScene("game")
        else if @_exchangeType is "sale"
            cc.director.loadScene("OwnStocksDialog")

    onMaxNum: ->
        @_exchangeNum = @_maxNum
        @m_input_label.placeholder = @_exchangeNum
}

