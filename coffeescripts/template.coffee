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
      when 'left'
        origin = @base.getBarrelRollTransform('left', args.distance_from_front).point
          x: 0
          y: 0
        origin_rotation_deg = (@base.getRotation() + 270) % 360
      when 'right'
        origin = @base.getBarrelRollTransform('right', args.distance_from_front).point
          x: 0
          y: 0
        origin_rotation_deg = (@base.getRotation() + 90) % 360

    @shape.x origin.x
    @shape.y origin.y
    @shape.rotation origin_rotation_deg

  draw: (layer, args) ->
    layer.add @shape
    @shape.stroke args.stroke ? 'black'
    @shape.strokeWidth args.strokeWidth ? 1
    @shape.draw()

  makeShape: ->
    throw new Error('Base class; implement me!')

class exportObj.templates.Straight extends Template
  constructor: (args) ->
    super args

  makeShape: ->
    new Kinetic.Rect
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
          ctx.strokeShape this

class exportObj.templates.Turn extends Template
  constructor: (args) ->
    super args

  makeShape: ->
    dir = @direction
    dist = @speed
    do (dir, dist) ->
      new Kinetic.Shape
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
          ctx.strokeShape this

class Deprecated
  deprecated_move: (shipinst) ->
    # TODO: transform base center based on template origin

    # Returns new ShipInstance at new location
    rotation = 0

    start_center =
      x: shipinst.group.getOffsetX()
      y: shipinst.group.getOffsetY()

    end_center = switch @type
      when 'barrelroll'
        x_offset = ship.width + (@speed * exportObj.SMALL_BASE_WIDTH)
        switch @direction
          when 'left'
            t.translate -x_offset, -@end_speed_from_front + @start_speed_from_front
          when 'right'
            t.translate x_offset, -@end_speed_from_front + @start_speed_from_front
          when 'leftforward'
            #t.strokeStyle = 'red'
            #ship.draw()
            t.translate -ship.width / 2, @start_speed_from_front - (ship.width / 2) - exportObj.BANK_INSIDE_RADII[@speed]
            #t.strokeStyle = 'green'
            #ship.draw()
            t.rotate Math.PI / 4
            #t.strokeStyle = 'blue'
            #ship.draw()
            t.translate -ship.width / 2, -@end_speed_from_front + (ship.width / 2) + exportObj.BANK_INSIDE_RADII[@speed]
            #t.strokeStyle = 'orange'
          when 'leftback'
            t.translate -ship.width / 2, @start_speed_from_front - (ship.width / 2) + exportObj.TEMPLATE_WIDTH + exportObj.BANK_INSIDE_RADII[@speed]
            t.rotate -Math.PI / 4
            t.translate -ship.width / 2, -exportObj.BANK_INSIDE_RADII[@speed] - exportObj.TEMPLATE_WIDTH + (ship.width / 2) - @end_speed_from_front
          when 'rightforward'
            #t.strokeStyle = 'red'
            #ship.draw()
            t.translate ship.width / 2, @start_speed_from_front - (ship.width / 2) - exportObj.BANK_INSIDE_RADII[@speed]
            #t.strokeStyle = 'green'
            #ship.draw()
            t.rotate -Math.PI / 4
            #t.strokeStyle = 'blue'
            #ship.draw()
            t.translate ship.width / 2, -@end_speed_from_front + (ship.width / 2) + exportObj.BANK_INSIDE_RADII[@speed]
            #t.strokeStyle = 'orange'
          when 'rightback'
            t.translate ship.width / 2, @start_speed_from_front - (ship.width / 2) + exportObj.TEMPLATE_WIDTH + exportObj.BANK_INSIDE_RADII[@speed]
            t.rotate Math.PI / 4
            t.translate ship.width / 2, -exportObj.BANK_INSIDE_RADII[@speed] - exportObj.TEMPLATE_WIDTH + (ship.width / 2) - @end_speed_from_front
          else
            throw new Error("Invalid direction #{@direction}")
      else
        throw new Error("Invalid template type #{@type}")

    # Spin if we K-turned
    if @type == 'koiogran'
      rotation = 180

    # Finally, apply the transformation (rotation gets set later)
    new_center = shipinst.group.getTransform().point end_center

    new ShipInstance
      ship: shipinst.ship
      x: new_center.x
      y: new_center.y
      heading_deg: shipinst.group.getRotation() + rotation
