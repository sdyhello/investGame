        # name: "各力电器",
        # price: 15,
        # priceWave: 10
        # ROE: 30
        # roeWave: 5
        # PE: 15
        # PEWave: 5
class StockData
    constructor: (@_info) ->
        @reset()

    reset: ->
        @_data = {
            "name": @_info.name
            "price": @_info.price
            "PE": @_info.PE
            "peWave": 0
            "dividend": 0
            "desc": ""
            "price": 0
            "priceWave": 0
            "tipsType": -1
        }

    getName: -> @_data["name"]
    getPrice: -> @_data["price"]
    setPrice: (price) ->
        if price < 1
            price = 1
        @_data["price"] = price
    getPriceWave: -> @_data["priceWave"]
    setPriceWave: (value) -> @_data["priceWave"] = value
    getPE: -> @_data["PE"]
    setPE: (PE) -> @_data["PE"] = PE
    getPEWave: -> @_data["peWave"]
    setPEWave: (value) -> @_data["peWave"] = value
    getOriginPE: -> @_info.PE
    getDividend: -> @_data["dividend"]
    setDividend: (value) -> @_data["dividend"] = value
    setTipsType: (type) -> @_data["tipsType"] = type
    getTipsType: -> @_data["tipsType"]
    save: -> @_data
    load: (val) -> @_data = val

module.exports = StockData
