utils = {
    bindEvent: (eventName, params) ->
        node = cc.director.getScene().getChildByName('LogicNode')
        node.on(eventName, params)

    triggerEvent: (eventName, params) ->
        node = cc.director.getScene().getChildByName('LogicNode')
        node.emit(eventName, params)

    getDataFromNode: ->
        node = cc.director.getScene().getChildByName('RecordNode')
        params = node.getComponent('Record').getData()
        return params

    setDataOnNode: (params) ->
        node = cc.director.getScene().getChildByName('RecordNode').getComponent('Record')
        node.setData(params)

    formatNum: (num) ->
        reg = /\d{1,3}(?=(\d{3})+$)/g
        return (num + '').replace(reg, '$&,')

    setItem: (name, value) ->
        cc.sys.localStorage.setItem(name, JSON.stringify value)

    getItem: (name) ->
        try JSON.parse cc.sys.localStorage.getItem(name)

}
module.exports = utils