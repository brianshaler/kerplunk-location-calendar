pad = (str, len=2) ->
  (Array(len).fill('0').join('') + str).slice(-len)

module.exports = dateToDayStr = (date) ->
  YYYY = date.getFullYear()
  MM = pad date.getMonth() + 1
  DD = pad date.getDate()
  "#{YYYY}-#{MM}-#{DD}"
