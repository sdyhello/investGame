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
        m_high_score: cc.Label
        m_version_label: cc.Label
    }
    onLoad: ->
        @_isFinish = utils.getItem("gameFinish") or false
        highScore = utils.getItem("highScore") or 0
        @m_high_score.string = "最好成绩: " +  utils.formatNum(highScore)
        TDGA?.onPageLeave()
        cc.debug?.setDisplayStats?(false)
        console.log("isFinish:#{@_isFinish}")
        @m_version_label.string = "version: 2.0"
        # jsb.reflection.callStaticMethod("org/cocos2dx/javascript/AdManage", "showBannerAd", "()V")

    onBegin: ->
        TDGA?.onEvent("begin")
        if @_isFinish is true
            utils.triggerEvent("resetGame")
            utils.triggerEvent("selectKLine")
            utils.setItem("gameFinish", false)
        cc.director.loadScene("game")

    onReset: ->
        TDGA?.onEvent("reset")
        utils.triggerEvent("resetGame")

    onHelp: ->
        cc.director.loadScene("HelpDialog")

    update: (dt) ->
        # do your update here
}
