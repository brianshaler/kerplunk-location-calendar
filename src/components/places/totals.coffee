module.exports = totals = (placeIds) ->
  placeIds.reduce (memo, placeId) ->
    if !memo[placeId]
      memo[placeId] = 0
    memo[placeId] += 1
    memo
  , {}
