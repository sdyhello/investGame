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
        m_score_label: cc.Label,

    }

    onLoad: ->
        moneyCash = 0
        marketMoney = 0
        
        klineIndex = 0
        utils.triggerEvent("getKline", (kLine) ->
            klineIndex = kLine
        )
        utils.triggerEvent("getMoney", ({ money, stockMoney }) =>
            moneyCash = money
            marketMoney = stockMoney
            all = moneyCash + marketMoney
            lastHighScore = utils.getItem("highScore") or 0

            biMoney = utils.formatNum(all)
            TDGA?.onEvent("gameFinish", { score: biMoney + "____#{klineIndex}" })

            if lastHighScore < all
                utils.setItem("highScore", all)
            @m_score_label.string = "你的总资产是: " + utils.formatNum(all)
        )
        utils.setItem("gameFinish", true)

    onBack: ->
        cc.director.loadScene("WelcomeDialog")

    update: (dt) ->
        # do your update here
}
