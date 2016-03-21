_ = require 'lodash'
moment = require 'moment'

combine = require './combine'

DAY = 86400 * 1000

stores = {}

module.exports = (opt) ->
  name = opt?.name ? 'data'
  return stores[name] if stores.name

  store = {}
  stores[name] = store

  data = null
  lists = {}
  request = opt?.request
  if opt?.lists
    for _list in opt.lists
      lists[_list.name] =
        name: _list.name
        key: _list.key
        list: []
  ranges = []
  listeners = []

  try
    cachedData = JSON.parse localStorage.getItem name
    data = _.extend {},
      (opt?.initialData)
      cachedData
  catch ex
    'nothing'

  if !data? or typeof data isnt 'object'
    data = {}

  fetchRange = (start, end) ->
    return unless window?
    from = moment.utc start
      .format 'YYYY-MM-DD'
    to = moment.utc end
      .format 'YYYY-MM-DD'

    url = '/location/get.json'
    options =
      from: from
      to: to

    # console.log 'onFetch', start, end,
    #   (new Date(start)),
    #   (new Date(end))

    request.get url, options, (err, data) =>
      return console.log err if err
      return console.log 'no data', url, data unless data?.length > 0

      location = data[0].from_location
      index = 0
      days = []
      for day in [start..end] by DAY
        today = new Date day
        m = moment.utc today
        formatted = m.format 'YYYY-MM-DD'
        if formatted == data[index]?.on
          index++
        location = data[index]?.from_location ? data[index - 1].to_location
        days.push
          time: today.getTime()
          location: location
          date: today
          moment: m
          formatted: formatted

      store.addItemsToList 'calendar', days

  fetchNewRanges = ->
    rangesToFetch = combine _.filter ranges, (range) -> range.pending
    rangesToFetch = _.filter rangesToFetch, (range) ->
      range.end > range.start
    for range in ranges
      range.pending = false
    for rangeToFetch in rangesToFetch
      console.log 'fetch range', rangeToFetch
      fetchRange rangeToFetch.start, rangeToFetch.end

  store.requestRange = (start, end) ->
    requested = _.find ranges, (range) ->
      range.start <= start and range.end >= end
    return if requested?
    overlaps = _.filter ranges, (range) ->
      start < range.start < end or start < range.end < end
    for overlap in overlaps
      if overlap.start <= start and overlap.end > start
        start = overlap.end
      if overlap.end >= end and overlap.start < end
        end = overlap.start
    return unless end - start > 0
    ranges.push
      start: start
      end: end
      pending: true

    setTimeout ->
      fetchNewRanges()
    , 1

    # console.log 'request range', start, end,
    #   (new Date(start)),
    #   (new Date(end))

  store.addChangeListener = (handler, keys) ->
    if typeof keys is 'string'
      keys = [keys]
    listeners.push
      keys: keys
      handler: handler

  store.addFilterListener = (handler, filter = (-> true)) ->
    listeners.push
      filter: filter
      handler: handler

  store.removeListener = (handler) ->
    listeners = _.filter listeners, (listener) ->
      listener.handler != handler

  store.set = (key, value) ->
    if typeof key is 'object'
      obj = key
      keys = Object.keys key
    else
      obj = {}
      obj[key] = value
      keys = [key]

    for key in keys
      data[key] = obj[key]

    toNotify = _.filter listeners, (listener) ->
      if listener.filter?
        return false
      # return listener.filter value, key
      return true if !listener.keys?
      for key in keys
        return true if -1 != listener.keys.indexOf(key)
      false

    for listener in toNotify
      listener.handler obj

    strState = JSON.stringify data
    localStorage.setItem name, strState

  store.addItemToList = (listName, item) ->
    {list, key} = lists[listName]
    throw new Error "unkown list #{listName}" unless key and list
    index = _.sortedIndexBy list, item[key], key
    if list[index]?[key] == item[key]
      list[index] = item
    else
      list.splice index, 0, item

    toNotify = _.filter listeners, (listener) ->
      listener.filter?(item)

    for listener in toNotify
      listener.handler _.filter list, listener.filter

    return

  store.addItemsToList = (listName, items) ->
    {list, key} = lists[listName]
    throw new Error "unkown list #{listName}" unless key and list
    for item in items
      index = _.sortedIndexBy list, item, key
      if list[index]?[key] == item[key]
        list[index] = item
      else
        list.splice index, 0, item

    toNotify = _.filter listeners, (listener) ->
      _.find items, (item) ->
        listener.filter?(item)

    for listener in toNotify
      listener.handler _.filter list, listener.filter
    return

  store.get = (key) ->
    if key?
      if typeof key is 'string'
        return data[key]
      obj = {}
      for k in key
        obj[k] = data[k]
      return obj
    data

  store.getFromList = (listName, filter) ->
    {list, key} = lists[listName]
    throw new Error "unkown list #{listName}" unless key and list
    _.filter list, filter

  store
