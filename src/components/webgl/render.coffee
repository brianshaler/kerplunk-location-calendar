startTime = Date.now()

module.exports = render = (viz, state) ->
  { regl, setup } = viz
  {
    canvasWidth
    canvasHeight
    config
    startDate
    endDate
    # summaryLegend
    summaryMap
  } = state

  {
    patternSize
    squareSize
  } = config

  regl.clear
    color: [0, 0, 0, 0]
    depth: 1

  # console.log('renderGL', instances.length, width, height)

  # const inDuration = 800
  # const inHold = 5200
  # const outDuration = 800
  # const outHold = 1200
  # const cycle = inDuration + inHold + outDuration + outHold

  # const cycleP = Date.now() % cycle

  {
    targetState
    previousState
    animationStart
  } = state
  # console.log({previousState, targetState})

  ease = (_p) -> 0.5 + 0.5 * Math.sin(-Math.PI / 2 + Math.PI * _p)
  # const mix = (m1, m2, _p) => [
  #   m1[0] + (m2[0] - m1[0]) * _p,
  #   m1[1] + (m2[1] - m1[1]) * _p,
  #   m1[2] + (m2[2] - m1[2]) * _p,
  # ]

  duration = 600
  uneased = if Date.now() >= animationStart + duration
    1
  else
    (Date.now() - animationStart) / duration
  p = ease uneased

  # let p = 0

  # if (cycleP < inDuration) {
  #   p = ease(cycleP / inDuration)
  # } else if (cycleP < inDuration + inHold) {
  #   p = 1
  # } else if (cycleP < inDuration + inHold + outDuration) {
  #   p = 1 - ease((cycleP - inDuration - inHold) / outDuration)
  # } else {
  #   p = 0
  # }
  # p = 1

  setup
    canvasSize: [canvasWidth, canvasHeight]
    p: p
    time: (Date.now() - startTime) / 1000
    z: 0.1
    patternSize: patternSize
    previousState
    targetState
    width: squareSize
    height: squareSize
    tex: viz.texture
    textureCount: viz.textureCount
  , ->
    if viz.bgTexture()
      {
        minLat
        maxLat
        minLng
        maxLng
      } = summaryMap
      # console.log('drawBG ' + JSON.stringify([minLng, minLat, maxLng, maxLat]))
      crop = [
        (minLng + 180) / 360
        1 - (maxLat + 90) / 180
        (maxLng + 180) / 360
        1 - (minLat + 90) / 180
      ]
      # console.log('crop: ' + JSON.stringify(crop))
      # const aspect = window.innerWidth / window.innerHeight
      # const cropAspect = (crop[2] - crop[0]) / (crop[3] - crop[1])
      # if (cropAspect > aspect) {
      #   crop[3] = crop[1] + (crop[2] - crop[0]) / aspect
      # }
      viz.drawBG
        p: p * targetState[2] + (1 - p) * previousState[2]
        tex: viz.bgTexture()
        crop: crop
        vScale: window.innerHeight / state.height
    selDuration = 400
    # animating = state.selectedMonthAt > 0 || state.deselectedMonthAt > 0
    animatingIn = state.selectedMonthAt > 0
    selP1 = (Date.now() - (state.selectedMonthAt || state.deselectedMonthAt || (Date.now() + 1000))) / selDuration

    selP = Math.max(0, Math.min(1, selP1))

    # if ((state.selectedMonth && selP1 < 1.5) || (state.deselectedMonth && selP1 < 1.5)) {
    #
    #   const selectedMonthIndex = viz.months.findIndex(m => m === state.selectedMonth || m === state.deselectedMonth)
    #   const selCalMonthRow = Math.floor(selectedMonthIndex / monthColumns)
    #   const selCalMonthCol = selectedMonthIndex - selCalMonthRow * monthColumns
    #   const selCalMonthX = selCalMonthCol * (squareSize + squareMargin) * 8
    #   const selCalMonthY = selCalMonthRow * (squareSize + squareMargin) * 7.5 + textHeight
    #
    #   viz.months.forEach((month, index) => {
    #     const calMonthRow = Math.floor(index / monthColumns)
    #     const calMonthCol = index - calMonthRow * monthColumns
    #
    #     const calMonthX = pageMargin + calMonthCol * (squareSize + squareMargin) * 8
    #     const calMonthY = pageMargin + calMonthRow * (squareSize + squareMargin) * 7.5 + textHeight
    #
    #     const p = animatingIn ? selP : 1 - selP
    #
    #     month.updateCalendarPosition(calMonthX - selCalMonthX * p, calMonthY - selCalMonthY * p)
    #   })
    # }

    viz.months
    .filter (m) -> m.getDate() >= startDate and m.getDate() < endDate
    .forEach (month) ->
      return if month == state.selectedMonth or month == state.deselectedMonth

      selected = 0
      if state.deselectedMonth
        selected = if state.deselectedMonth == month
          Math.max(0, 1 - selP)
        else
          Math.min(0, -1 + selP)
      else if state.selectedMonth
        selected = if state.selectedMonth == month
          Math.min(1, selP)
        else
          Math.max(-1, -selP)
      # console.log('month', animatingIn, selP, month.getKey(), selected)
      month.draw
        selected: selected
        scale: 1
        # scale: !animating ? 1 : 1 + (animatingIn ? selP : 1 - selP),
    if state.selectedMonth or state.deselectedMonth
      setup
        canvasSize: [canvasWidth, canvasHeight]
        p: selP1
        time: (Date.now() - startTime) / 1000
        z: 0
        patternSize: patternSize
        previousState: if animatingIn then [1, 0, 0] else [0, 1, 0],
        targetState: if animatingIn then [0, 1, 0] else [1, 0, 0],
        width: squareSize
        height: squareSize
        tex: viz.texture
        textureCount: viz.textureCount
      , ->
        viz.monthLegend.draw
          selected: 0
          scale: 1
