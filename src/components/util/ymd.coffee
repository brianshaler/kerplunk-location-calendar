moment = require 'moment'

getUTCYMD = (time = Date.now()) ->
  [year, month, day] = moment.utc time
    .format 'YYYY-MM-DD'
    .split '-'
  [parseInt(year), parseInt(month)-1, parseInt(day)]

YMDtoTime = (YMD) ->
  1000 * moment.utc(YMD).format 'X'

nextMonth = (YMD) ->
  d = new Date YMD[0], YMD[1] + 1, 1
  val = [d.getFullYear(), d.getMonth(), 1]
  val

# tomorrow = (YMD) ->
#   getUTCYMD 86400000 * 1.5 + moment.utc(YMD).format('X') * 1000

monthRange = (minYMD, maxYMD) ->
  YMD = [minYMD[0], minYMD[1], 1]
  endTime = YMDtoTime maxYMD
  time = YMDtoTime YMD
  range = []
  while time < endTime and range.length < 100
    range.push YMD
    YMD = nextMonth YMD
    time = YMDtoTime YMD
  range

# dateRange = (minYMD, maxYMD) ->
#   currentYMD = minYMD
#   endTime = YMDtoTime maxYMD
#   currentTime = YMDtoTime currentYMD
#   range = []
#   while currentTime < endTime and range.length < 100
#     range.push currentYMD
#     currentYMD = tomorrow currentYMD
#     currentTime = YMDtoTime currentYMD
#   range

YMDtoString = (YMD = getUTCYMD()) ->
  moment.utc(YMD).format('YYYY-MM-DD')

module.exports =
  YMDtoTime: YMDtoTime
  nextMonth: nextMonth
  monthRange: monthRange
  YMDtoString: YMDtoString
  getUTCYMD: getUTCYMD
