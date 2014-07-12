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

  frontNubOrigin: ->
    p = @group.getTransform().point
      x: @width / 2
      y: 0
    new exportObj.Position
      center_x: p.x
      center_y: p.y
      heading_deg: @position.heading_deg

  rearNubOrigin: ->
    p = @group.getTransform().point
      x: @width / 2
      y: @width
    new exportObj.Position
      center_x: p.x
      center_y: p.y
      heading_deg: (@position.heading_deg + 180) % 360

  barrelrollOrigin: (side, distance_from_front) ->
    if distance_from_front > @width - exportObj.TEMPLATE_WIDTH
      throw new Error("Barrel roll template placed too far back (#{distance_from_front} but base width is #{@width}) and template width is #{exportObj.TEMPLATE_WIDTH}")
    distance_from_front += exportObj.TEMPLATE_WIDTH / 2
    switch side
      when 'left'
        p = @group.getTransform().point
          x: 0
          y: distance_from_front
        new exportObj.Position
          center_x: p.x
          center_y: p.y
          heading_deg: (@position.heading_deg + 270) % 360
      when 'right'
        p = @group.getTransform().point
          x: @width
          y: distance_from_front
        new exportObj.Position
          center_x: p.x
          center_y: p.y
          heading_deg: (@position.heading_deg + 90) % 360
      else
        throw new Error("Invalid side #{side}")
