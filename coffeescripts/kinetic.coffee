exportObj = exports ? this

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
