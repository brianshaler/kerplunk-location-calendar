module.exports = Square = (segments=1) ->
  positions = []
  for vcol in [0..segments]
    for vrow in [0..segments]
      positions.push [
        -1 + vcol / segments * 2
        -1 + vrow / segments * 2
      ]

  vcols = segments + 1
  elements = []

  for ecol in [0...segments]
    for erow in [0...segments]
      vrow = erow
      vcol = ecol
      elements.push [
        vcol + vrow * vcols
        1 + vcol + vrow * vcols
        vcol + (vrow + 1) * vcols
      ]
      elements.push [
        1 + vcol + vrow * vcols
        vcol + (vrow + 1) * vcols
        1 + vcol + (vrow + 1) * vcols
      ]

	position: positions
	elements: elements
	count: elements.length * 3
