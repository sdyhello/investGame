class UserData
    constructor: ->
        @reset()

    getYear: ->
        @_data["year"]

    addYear: ->
        @_data["year"] += 1

    getMoney: ->
        @_data["money"]

    setMoney: (money) ->
        @_data["money"] = money

    getOwnStocks: ->
        @_data["ownStocks"]

    setOwnStocks: (stocks) ->
        @_data["ownStocks"] = stocks

    reset: ->
        @_data = {
            "name": ""
            "year": 0
            "money": 1000000
            "ownStocks": []
        }

    save: ->
        @_data

    load: (val) ->
        @_data = val

module.exports = UserData

