module.exports = dayStrToDate = (str) ->
  [strYear, strMonth, strDate] = str.split('-')
  year = parseInt(strYear, 10)
  month = parseInt(strMonth, 10) - 1
  day = parseInt(strDate, 10)

  new Date year, month, day
