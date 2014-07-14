exportObj = exports ? this

class exportObj.Base
  # A ship base at a given position
  constructor: (args) ->
    @size = args.size
    @position = args.position

    @width = switch @size
      when 'small'
        exportObj.SMALL_BASE_WIDTH
      when 'large'
        exportObj.LARGE_BASE_WIDTH
      else
        throw new Error("Invalid size #{@size}")

    throw new Error("Position required") unless @position instanceof exportObj.Position

    @group = new Kinetic.Group
      x: @position.center_x
      y: @position.center_y
      offsetX: @width / 2
      offsetY: @width / 2
      rotation: @position.heading_deg

    @group.add new Kinetic.Rect
      name: 'base'
      x: 0
      y: 0
      width: @width
      height: @width

    @group.add new Kinetic.Line
      name: 'firing_arc'
      points: [
        1, 0
        @width / 2, @width / 2
        @width - 1, 0
      ]

    nub_offset = exportObj.TEMPLATE_WIDTH / 2

    @group.add new Kinetic.Rect
      name: 'nub'
      x: (@width / 2) - nub_offset - 1
      y: -2
      width: 1
      height: 2

    @group.add new Kinetic.Rect
      name: 'nub'
      x: (@width / 2) + nub_offset - 1
      y: - 2
      width: 1
      height: 2

    @group.add new Kinetic.Rect
      name: 'nub'
      x: (@width / 2) - nub_offset - 1
      y: @width
      width: 1
      height: 2

    @group.add new Kinetic.Rect
      name: 'nub'
      x: (@width / 2) + nub_offset - 1
      y: @width
      width: 1
      height: 2

  draw: (layer, args) ->
    layer.add @group
    for child in @group.children
      child.stroke args.stroke ? 'black'
      child.strokeWidth args.strokeWidth ? 1
      child.draw()

  getRotation: ->
    @group.rotation()

  getFrontNubTransform: ->
    @group.getAbsoluteTransform().copy().translate(@width / 2, 0)

  getRearNubTransform: ->
    @group.getAbsoluteTransform().copy().translate(@width / 2, @width)

  getBarrelRollTransform: (side, distance_from_front) ->
    if distance_from_front > @width - exportObj.TEMPLATE_WIDTH
      throw new Error("Barrel roll template placed too far back (#{distance_from_front} but base width is #{@width}) and template width is #{exportObj.TEMPLATE_WIDTH}")

    distance_from_front += exportObj.TEMPLATE_WIDTH / 2

    switch side
      when 'left', 'leftforward', 'leftbackward'
        @group.getAbsoluteTransform().copy().translate(0, distance_from_front)
      when 'right', 'rightforward', 'rightbackward'
        @group.getAbsoluteTransform().copy().translate(@width, distance_from_front)
      else
        throw new Error("Invalid side #{side}")

  newBaseFromMovement: (movement) ->
    {transform, heading_deg} = movement.getBaseTransformAndHeading this
    p = transform.point {x:0, y:0}
    new exportObj.Base
      size: @size
      position: new Position
        center_x: p.x
        center_y: p.y
        heading_deg: heading_deg
