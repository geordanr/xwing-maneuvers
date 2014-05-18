exportObj = exports ? this

# All measurements here are in mm

exportObj.SMALL_BASE_WIDTH = 40
exportObj.LARGE_BASE_WIDTH = 80

exportObj.TEMPLATE_WIDTH = exportObj.SMALL_BASE_WIDTH / 2

exportObj.BANK_INSIDE_RADII = [
  ''
  75
  122
  173
]

exportObj.TURN_INSIDE_RADII = [
  ''
  27
  52
  79
]

class exportObj.Ship
  # A ship and its moves
  constructor: (args) ->
    @name = args.name ? 'Unnamed Ship'
    @size = args.size
    @move_history = []

class exportObj.ShipInstance
  # A single instance of a ship that can be drawn on a layer
  constructor: (args) ->
    @ship = args.ship

    @width = switch @ship.size
      when 'small'
        exportObj.SMALL_BASE_WIDTH
      when 'large'
        exportObj.LARGE_BASE_WIDTH
      else
        throw new Error("Invalid size #{@size}")

    @group = new Kinetic.Group
      x: args.x
      y: args.y
      offsetX: @width / 2
      offsetY: @width / 2
      rotation: args.heading_deg

    @group.add new Kinetic.Rect
      x: 0
      y: 0
      width: @width
      height: @width
      stroke: 'black'
      strokeWidth: 1

    @group.add new Kinetic.Line
      points: [
        1, 0
        @width / 2, @width / 2
        @width - 1, 0
      ]
      stroke: 'black'
      strokeWidth: 1

    nub_offset = exportObj.TEMPLATE_WIDTH / 2
    @group.add new Kinetic.Rect
      x: (@width / 2) - nub_offset - 1
      y: -2
      width: 1
      height: 2
      stroke: 'black'
      strokeWidth: 1

    @group.add new Kinetic.Rect
      x: (@width / 2) + nub_offset - 1
      y: - 2
      width: 1
      height: 2
      stroke: 'black'
      strokeWidth: 1

    @group.add new Kinetic.Rect
      x: (@width / 2) - nub_offset - 1
      y: @width
      width: 1
      height: 2
      stroke: 'black'
      strokeWidth: 1

    @group.add new Kinetic.Rect
      x: (@width / 2) + nub_offset - 1
      y: @width
      width: 1
      height: 2
      stroke: 'black'
      strokeWidth: 1

  placeTemplate: (template) ->
    template.shape.move @group.getTransform().point
      x: @width / 2
      y: 0
    template.shape.rotation @group.getRotation()

class exportObj.Template
  # Created such that the bottom center of the template is 0, 0, extending up (-y)
  constructor: (args) ->
    @type = args.type
    @distance = args.distance
    @direction = args.direction

    @shape = switch @type
      when 'straight', 'koiogran'
        new Kinetic.Rect
          x: 0
          y: 0
          offsetX: exportObj.TEMPLATE_WIDTH / 2
          offsetY: 0
          width: exportObj.TEMPLATE_WIDTH
          height: -exportObj.SMALL_BASE_WIDTH * @distance
          stroke: 'black'
          strokeWidth: 1
      when 'bank'
        dir = @direction
        dist = @distance
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
            stroke: 'black'
            strokeWidth: 1
      when 'turn'
        dir = @direction
        dist = @distance
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
            stroke: 'black'
            strokeWidth: 1

  move: (shipinst) ->
    # Returns new ShipInstance at new location
    rotation = 0

    start_center =
      x: shipinst.group.getOffsetX()
      y: shipinst.group.getOffsetY()

    end_center = switch @type
      when 'straight'
        new Kinetic.Transform().translate(0, -@distance * exportObj.SMALL_BASE_WIDTH - shipinst.width).point start_center
      when 'bank'
        switch @direction
          when 'left'
            d = exportObj.BANK_INSIDE_RADII[@distance] - ((shipinst.width - exportObj.TEMPLATE_WIDTH) / 2)
            rotation = -45
            end_center = new Kinetic.Transform().translate(d, -shipinst.width).point start_center
            end_center = new Kinetic.Transform().rotate(-Math.PI / 4).point end_center
            end_center = new Kinetic.Transform().translate(-d, 0).point end_center
          when 'right'
            d = exportObj.BANK_INSIDE_RADII[@distance] + ((shipinst.width + exportObj.TEMPLATE_WIDTH) / 2)
            rotation = 45
            end_center = new Kinetic.Transform().translate(-d, -shipinst.width).point start_center
            end_center = new Kinetic.Transform().rotate(Math.PI / 4).point end_center
            end_center = new Kinetic.Transform().translate(d, 0).point end_center
          else
            throw new Error("Invalid direction #{@direction}")
      when 'turn'
        switch @direction
          when 'left'
            d = exportObj.TURN_INSIDE_RADII[@distance] - ((shipinst.width - exportObj.TEMPLATE_WIDTH) / 2)
            rotation = -90
            end_center = new Kinetic.Transform().translate(d, -shipinst.width).point start_center
            end_center = new Kinetic.Transform().rotate(-Math.PI / 2).point end_center
            end_center = new Kinetic.Transform().translate(-d, 0).point end_center
          when 'right'
            d = exportObj.TURN_INSIDE_RADII[@distance] + ((shipinst.width + exportObj.TEMPLATE_WIDTH) / 2)
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
        end_center = new Kinetic.Transform().translate(shipinst.group.getOffsetX(), -shipinst.group.getOffsetY() - (@distance * exportObj.SMALL_BASE_WIDTH)).point end_center
      when 'barrelroll'
        x_offset = ship.width + (@distance * exportObj.SMALL_BASE_WIDTH)
        switch @direction
          when 'left'
            t.translate -x_offset, -@end_distance_from_front + @start_distance_from_front
          when 'right'
            t.translate x_offset, -@end_distance_from_front + @start_distance_from_front
          when 'leftforward'
            #t.strokeStyle = 'red'
            #ship.draw()
            t.translate -ship.width / 2, @start_distance_from_front - (ship.width / 2) - exportObj.BANK_INSIDE_RADII[@distance]
            #t.strokeStyle = 'green'
            #ship.draw()
            t.rotate Math.PI / 4
            #t.strokeStyle = 'blue'
            #ship.draw()
            t.translate -ship.width / 2, -@end_distance_from_front + (ship.width / 2) + exportObj.BANK_INSIDE_RADII[@distance]
            #t.strokeStyle = 'orange'
          when 'leftback'
            t.translate -ship.width / 2, @start_distance_from_front - (ship.width / 2) + exportObj.TEMPLATE_WIDTH + exportObj.BANK_INSIDE_RADII[@distance]
            t.rotate -Math.PI / 4
            t.translate -ship.width / 2, -exportObj.BANK_INSIDE_RADII[@distance] - exportObj.TEMPLATE_WIDTH + (ship.width / 2) - @end_distance_from_front
          when 'rightforward'
            #t.strokeStyle = 'red'
            #ship.draw()
            t.translate ship.width / 2, @start_distance_from_front - (ship.width / 2) - exportObj.BANK_INSIDE_RADII[@distance]
            #t.strokeStyle = 'green'
            #ship.draw()
            t.rotate -Math.PI / 4
            #t.strokeStyle = 'blue'
            #ship.draw()
            t.translate ship.width / 2, -@end_distance_from_front + (ship.width / 2) + exportObj.BANK_INSIDE_RADII[@distance]
            #t.strokeStyle = 'orange'
          when 'rightback'
            t.translate ship.width / 2, @start_distance_from_front - (ship.width / 2) + exportObj.TEMPLATE_WIDTH + exportObj.BANK_INSIDE_RADII[@distance]
            t.rotate Math.PI / 4
            t.translate ship.width / 2, -exportObj.BANK_INSIDE_RADII[@distance] - exportObj.TEMPLATE_WIDTH + (ship.width / 2) - @end_distance_from_front
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
