exportObj = exports ? this

exportObj.templates = {}

class Template
  # Created such that the bottom center of the template is 0, 0, extending up (-y)
  # Not to be confused with movements; these only facilitate drawing the templates.
  # Different movements may be drawn using the same template, but will have different
  # base transforms.
  constructor: (args) ->
    @speed = args.speed
    @direction = args.direction
    @base = args.base
    @where = args.where

    @shape = @makeShape()

    switch @where
      when 'front_nubs'
        origin = @base.getFrontNubTransform().point
          x: 0
          y: 0
        origin_rotation_deg = @base.getRotation()
      when 'rear_nubs'
        origin = @base.getRearNubTransform().point
          x: 0
          y: 0
        origin_rotation_deg = (@base.getRotation() + 180) % 360
      when 'left', 'leftforward', 'leftbackward'
        origin = @base.getBarrelRollTransform('left', args.distance_from_front).point
          x: 0
          y: 0
        origin_rotation_deg = (@base.getRotation() + 270) % 360
      when 'right', 'rightforward', 'rightbackward'
        origin = @base.getBarrelRollTransform('right', args.distance_from_front).point
          x: 0
          y: 0
        origin_rotation_deg = (@base.getRotation() + 90) % 360
      else
        throw new Error("Invalid template placement #{@where}")

    @shape.x origin.x
    @shape.y origin.y
    @shape.rotation origin_rotation_deg

  draw: (layer, args={}) ->
    layer.add @shape
    @shape.stroke args.stroke ? 'black'
    @shape.strokeWidth args.strokeWidth ? 1
    @shape.fill args.fill ? ''
    @shape.draw()

  makeShape: ->
    throw new Error('Base class; implement me!')

class exportObj.templates.Straight extends Template
  constructor: (args) ->
    super args

  makeShape: ->
    new Kinetic.Rect
      name: 'template'
      offsetX: exportObj.TEMPLATE_WIDTH / 2
      offsetY: 0
      width: exportObj.TEMPLATE_WIDTH
      height: -exportObj.SMALL_BASE_WIDTH * @speed

class exportObj.templates.Koiogran extends exportObj.templates.Straight
  constructor: (args) ->
    super args

class exportObj.templates.Bank extends Template
  constructor: (args) ->
    super args

  makeShape: ->
    dir = @direction
    dist = @speed
    do (dir, dist) ->
      new Kinetic.Shape
        name: 'template'
        drawFunc: (ctx) ->
          radius = exportObj.BANK_INSIDE_RADII[dist]

          ctx.beginPath()
          switch dir
            when 'left', 'leftbackward', 'rightforward'
              angle = -Math.PI / 4.0
              ctx.arc -radius - (exportObj.TEMPLATE_WIDTH / 2), 0, radius, angle, 0
              ctx.lineTo exportObj.TEMPLATE_WIDTH / 2, 0
              ctx.arc -radius - (exportObj.TEMPLATE_WIDTH / 2), 0, radius + exportObj.TEMPLATE_WIDTH, 0, angle, true
            when 'right', 'leftforward', 'rightbackward'
              angle = -3 * Math.PI / 4.0
              ctx.arc radius + (exportObj.TEMPLATE_WIDTH / 2), 0, radius, angle, Math.PI, true
              ctx.lineTo -exportObj.TEMPLATE_WIDTH / 2, 0
              ctx.arc radius + (exportObj.TEMPLATE_WIDTH / 2), 0, radius + exportObj.TEMPLATE_WIDTH, Math.PI, angle
            else
              throw new Error("Invalid direction #{dir}")
          ctx.closePath()
          ctx.fillStrokeShape this

class exportObj.templates.Turn extends Template
  constructor: (args) ->
    super args

  makeShape: ->
    dir = @direction
    dist = @speed
    do (dir, dist) ->
      new Kinetic.Shape
        name: 'template'
        drawFunc: (ctx) ->
          angle = -Math.PI / 2
          radius = exportObj.TURN_INSIDE_RADII[dist]

          ctx.beginPath()

          switch dir
            when 'left'
              ctx.arc -radius - (exportObj.TEMPLATE_WIDTH / 2), 0, radius, angle, 0
              ctx.lineTo exportObj.TEMPLATE_WIDTH / 2, 0
              ctx.arc -radius - (exportObj.TEMPLATE_WIDTH / 2), 0, radius + exportObj.TEMPLATE_WIDTH, 0, angle, true
            when 'right'
              ctx.arc radius + (exportObj.TEMPLATE_WIDTH / 2), 0, radius + exportObj.TEMPLATE_WIDTH, angle, Math.PI, true
              ctx.lineTo exportObj.TEMPLATE_WIDTH / 2, 0
              ctx.arc radius + (exportObj.TEMPLATE_WIDTH / 2), 0, radius, Math.PI, angle
            else
              throw new Error("Invalid direction #{dir}")

          ctx.closePath()
          ctx.fillStrokeShape this
