React = require 'react'
SparkMD5 = require 'spark-md5'
md5 = SparkMD5.hash

pattern = require './pattern'

{DOM} = React

module.exports = React.createFactory React.createClass
  getDefaultProps: ->
    onSelectDate: -> console.log 'Box.onSelectDate not set'

  onClick: (e) ->
    e.preventDefault()
    @props.pushState e, true
    #@props.onSelectDate @props.day

  componentDidMount: ->
    @draw()

  componentWillUpdate: ->
    @draw()

  draw: ->
    return unless @props.day and @isMounted()
    cvs = React.findDOMNode @refs?.box
    return unless cvs?.getContext
    cvs.width = 12
    cvs.height = 12
    ctx = cvs.getContext '2d'
    return unless ctx

    ctx.fillStyle = '#0f0'
    ctx.fillRect 0, 0, cvs.width, cvs.height

    day = @props.day
    location = day.location
    region = if location.region?.length > 0
      "#{location.region}, "
    else
      ''
    display = "#{location.city}, #{region}#{location.country}"
    title = "#{day.moment.format 'MM/DD/YYYY'}: #{display}"
    c = pattern display
    for x in [0..cvs.width-c.width] by c.width
      for y in [0..cvs.height-c.height] by c.height
        ctx.drawImage c, x, y

  render: ->
    unless @props.day
      return DOM.div className: 'calendar-box'

    day = @props.day
    location = day.location
    region = if location.region?.length > 0
      "#{location.region}, "
    else
      ''
    display = "#{location.city}, #{region}#{location.country}"
    title = "#{day.moment.format 'MM/DD/YYYY'}: #{display}"
    # c = indexedColor display
    # pattern = getPattern c.c1, c.c2, c.pattern
    DOM.a
      className: 'calendar-box'
      href: if @props.isUser
        "/admin/location/edit/#{@props.day.moment.format 'YYYY/MM/DD'}"
      else
        "/location/view/#{@props.day.moment.format 'YYYY/MM/DD'}"
      onClick: @props.pushState
      title: title
      # style:
      #   background: "transparent url(#{pattern}) top left repeat repeat"
    ,
      DOM.canvas
        ref: 'box'
