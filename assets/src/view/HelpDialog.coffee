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
        m_help_content: cc.Label
    }

    onLoad: ->
        TDGA?.onEvent("openHelp")
        @m_help_content.string = "现实的企业成长变化较慢，于是模拟了这个快速的游戏体验。
        你可以买股票，卖股票来获得收益。操作也很方便啦，买入股票，或卖出股票，然后点击下一年，
        就能迅速看到股价的变化了。
        1、买股票 ，直接点击页面上的股票条，然后在购买界面进行操作。
        2、卖股票，点开我的持仓，然后选择想卖的股票，在卖出界面进行操作
        没有其他操作了，快去体验吧，有什么问题可以关注我的公众号来提问。
        "


    onBack: ->
        cc.director.loadScene("WelcomeDialog")

    update: (dt) ->
        # do your update here
}
