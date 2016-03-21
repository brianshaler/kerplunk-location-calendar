_ = require 'lodash'

module.exports = combine = (list) ->
  _ list
  .map (item) ->
    {start, end} = item
    for other in list
      if start <= other.start <= end and other.end > end
        end = other.end
      if start <= other.end <= end and other.start < start
        start = other.start
    start: start
    end: end
  .sortBy (item) ->
    -(item.end - item.start)
  .reduce (memo, item) ->
    {start, end} = item
    for existing, index in memo
      if start >= existing.start and end <= existing.end
        return memo
      if start <= existing.start and end >= existing.end
        memo[index] = item
        return memo
    memo.push item
    memo
  , []

# arr1 = [
#   {start: 3, end: 5}
#   {start: 11, end: 12}
#   {start: 8, end: 10}
#   {start: 1, end: 3}
#   {start: 4, end: 9}
# ]
# console.log arr1, combine arr1
