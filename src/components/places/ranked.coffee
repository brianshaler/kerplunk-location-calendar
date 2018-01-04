module.exports = ranked = (totals) ->
  keys = Object.keys(totals)
  keys.sort (a, b) => if totals[a] > totals[b] then -1 else 1
  keys
