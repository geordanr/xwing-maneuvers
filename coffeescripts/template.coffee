exportObj = exports ? this

class exportObj.Template
  # Created such that the bottom center of the template is 0, 0, extending up (-y)
  constructor: (args) ->
    @type = args.type
    @speed = args.speed
    @direction = args.direction
    @position = args.position

    @shape = switch @type
      when 'straight', 'koiogran'
        new Kinetic.Rect
          offsetX: exportObj.TEMPLATE_WIDTH / 2
          offsetY: 0
          width: exportObj.TEMPLATE_WIDTH
          height: -exportObj.SMALL_BASE_WIDTH * @speed
      when 'bank'
        dir = @direction
        dist = @speed
        do (dir, dist) ->
          new Kinetic.Shape
            drawFunc: (ctx) ->
              radius = exportObj.BANK_INSIDE_RADII[dist]

              ctx.beginPath()
              switch dir
                when 'left'
                  angle = -Math.PI / 4.0
                  ctx.arc -radius - (exportObj.TEMPLATE_WIDTH / 2), 0, radius, angle, 0
                  ctx.lineTo exportObj.TEMPLATE_WIDTH / 2, 0
                  ctx.arc -radius - (exportObj.TEMPLATE_WIDTH / 2), 0, radius + exportObj.TEMPLATE_WIDTH, 0, angle, true
                when 'right'
                  angle = -3 * Math.PI / 4.0
                  ctx.arc radius + (exportObj.TEMPLATE_WIDTH / 2), 0, radius, angle, Math.PI, true
                  ctx.lineTo -exportObj.TEMPLATE_WIDTH / 2, 0
                  ctx.arc radius + (exportObj.TEMPLATE_WIDTH / 2), 0, radius + exportObj.TEMPLATE_WIDTH, Math.PI, angle
                else
                  throw new Error("Invalid direction #{dir}")
              ctx.closePath()
              ctx.strokeShape this
      when 'turn'
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

    @shape.x @position.center_x
    @shape.y @position.center_y
    @shape.rotation @position.heading_deg

  draw: (layer, args) ->
    layer.add @shape
    @shape.stroke args.stroke ? 'black'
    @shape.strokeWidth args.strokeWidth ? 1
    @shape.draw()

  deprecated_move: (shipinst) ->
    # TODO: transform base center based on template origin

    # Returns new ShipInstance at new location
    rotation = 0

    start_center =
      x: shipinst.group.getOffsetX()
      y: shipinst.group.getOffsetY()

    end_center = switch @type
      when 'straight'
        new Kinetic.Transform().translate(0, -@speed * exportObj.SMALL_BASE_WIDTH - shipinst.width).point start_center
      when 'bank'
        switch @direction
          when 'left'
            d = exportObj.BANK_INSIDE_RADII[@speed] - ((shipinst.width - exportObj.TEMPLATE_WIDTH) / 2)
            rotation = -45
            end_center = new Kinetic.Transform().translate(d, -shipinst.width).point start_center
            end_center = new Kinetic.Transform().rotate(-Math.PI / 4).point end_center
            end_center = new Kinetic.Transform().translate(-d, 0).point end_center
          when 'right'
            d = exportObj.BANK_INSIDE_RADII[@speed] + ((shipinst.width + exportObj.TEMPLATE_WIDTH) / 2)
            rotation = 45
            end_center = new Kinetic.Transform().translate(-d, -shipinst.width).point start_center
            end_center = new Kinetic.Transform().rotate(Math.PI / 4).point end_center
            end_center = new Kinetic.Transform().translate(d, 0).point end_center
          else
            throw new Error("Invalid direction #{@direction}")
      when 'turn'
        switch @direction
          when 'left'
            d = exportObj.TURN_INSIDE_RADII[@speed] - ((shipinst.width - exportObj.TEMPLATE_WIDTH) / 2)
            rotation = -90
            end_center = new Kinetic.Transform().translate(d, -shipinst.width).point start_center
            end_center = new Kinetic.Transform().rotate(-Math.PI / 2).point end_center
            end_center = new Kinetic.Transform().translate(-d, 0).point end_center
          when 'right'
            d = exportObj.TURN_INSIDE_RADII[@speed] + ((shipinst.width + exportObj.TEMPLATE_WIDTH) / 2)
            rotation = 90
            end_center = new Kinetic.Transform().translate(-d, -shipinst.width).point start_center
            end_center = new Kinetic.Transform().rotate(Math.PI / 2).point end_center
            end_center = new Kinetic.Transform().translate(d, 0).point end_center
          else
            throw new Error("Invalid direction #{@direction}")
      when 'koiogran'
        rotation = 180
        end_center = new Kinetic.Transform().translate(-shipinst.group.getOffsetX(), -shipinst.group.getOffsetY()).point start_center
        end_center = new Kinetic.Transform().rotate(Math.PI).point end_center
        end_center = new Kinetic.Transform().translate(shipinst.group.getOffsetX(), -shipinst.group.getOffsetY() - (@speed * exportObj.SMALL_BASE_WIDTH)).point end_center
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
