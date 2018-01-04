module.exports = Days = (startDate, endDate) ->
  days = []

  d = new Date(startDate)
  while d <= endDate
    day =
      d: new Date(d),
      key: "#{d.getFullYear()}-#{d.getMonth()}-#{d.getDate()}"
    days.push(day)
    d.setDate(d.getDate() + 1)

  days
