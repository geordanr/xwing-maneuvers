exportObj = exports ? this

# All measurements here are in mm

SMALL_BASE_WIDTH = 40
LARGE_BASE_WIDTH = 80

TEMPLATE_WIDTH = SMALL_BASE_WIDTH / 2

BANK_INSIDE_RADII = [
  ''
  75
  122
  173
]

TURN_INSIDE_RADII = [
  ''
  27
  52
  79
]

exportObj.draw = ->
  canvas = document.getElementById('playarea')
  if canvas.getContext?
    ctx = canvas.getContext '2d'

    ctx.save()
    ctx.translate 40, 40
    exportObj.drawSmallBase(ctx)
    ctx.restore()

    ctx.save()
    ctx.translate 40 + exportObj.getNubOffset(SMALL_BASE_WIDTH), 40
    exportObj.drawStraight ctx, 1
    ctx.restore()

    ctx.save()
    ctx.translate 100, 200
    exportObj.drawBank ctx, 3, 'left'
    ctx.restore()

    ctx.save()
    ctx.translate 200, 100
    exportObj.drawTurn ctx, 1, 'right'
    ctx.restore()

exportObj.init = (ctx) ->
  ctx.lineWidth = 1

exportObj.drawSmallBase = (ctx) ->
  exportObj.drawBase ctx, SMALL_BASE_WIDTH

exportObj.drawBase = (ctx, width) ->
  ctx.strokeRect 0, 0, width, width
  ctx.beginPath()
  ctx.moveTo 1, 0
  ctx.lineTo (width / 2), (width / 2)
  ctx.lineTo (width - 1), 0
  ctx.stroke()

exportObj.getNubOffset = (base_width) ->
  (base_width - TEMPLATE_WIDTH) / 2

exportObj.drawStraight = (ctx, length) ->
  ctx.strokeRect 0, 0, TEMPLATE_WIDTH, -SMALL_BASE_WIDTH * length

exportObj.drawBank = (ctx, length, direction) ->
  radius = BANK_INSIDE_RADII[length]

  ctx.beginPath()
  switch direction
    when 'left'
      angle = -Math.PI / 4.0
      ctx.arc -radius, 0, radius, angle, 0
      ctx.lineTo TEMPLATE_WIDTH, 0
      ctx.arc -radius, 0, radius + TEMPLATE_WIDTH, 0, angle, true
    when 'right'
      angle = -3 * Math.PI / 4.0
      ctx.arc radius + TEMPLATE_WIDTH, 0, radius, angle, Math.PI, true
      ctx.lineTo 0, 0
      ctx.arc radius + TEMPLATE_WIDTH, 0, radius + TEMPLATE_WIDTH, Math.PI, angle
    else
      throw new Error("Invalid direction #{direction}")

  ctx.closePath()
  ctx.stroke()

exportObj.drawTurn = (ctx, length, direction) ->
  angle = -Math.PI / 2
  radius = TURN_INSIDE_RADII[length]

  ctx.beginPath()

  switch direction
    when 'left'
      ctx.arc -radius, 0, radius, angle, 0
      ctx.lineTo TEMPLATE_WIDTH, 0
      ctx.arc -radius, 0, radius + TEMPLATE_WIDTH, 0, angle, true
    when 'right'
      ctx.arc radius + TEMPLATE_WIDTH, 0, radius + TEMPLATE_WIDTH, angle, Math.PI, true
      ctx.lineTo TEMPLATE_WIDTH, 0
      ctx.arc radius + TEMPLATE_WIDTH, 0, radius, Math.PI, angle
    else
      throw new Error("Invalid direction #{direction}")

  ctx.closePath()
  ctx.stroke()
