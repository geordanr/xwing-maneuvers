exportObj = exports ? this

class exportObj.Base
  # A ship base at a given position
  constructor: (args) ->
    @size = args.size
    @position = args.position

    @firingarcs = []

    @width = switch @size
      when 'small'
        exportObj.SMALL_BASE_WIDTH
      when 'large'
        exportObj.LARGE_BASE_WIDTH
      else
        throw new Error("Invalid size #{@size}")

    throw new Error("Position required") unless @position instanceof exportObj.Position

    @group = new Kinetic.Group
      name: 'baseGroup'
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
      name: 'printed_firing_arc'
      points: [
        3, 0
        @width / 2, @width / 2
        @width - 3, 0
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

    @firingarc = null

  destroy: ->
    @group.destroyChildren()
    @group.destroy()

  draw: (layer, args={}) ->
    layer.add @group
    for child in @group.children
      child.stroke args.stroke ? 'black'
      child.strokeWidth args.strokeWidth ? 1
      child.fill args.fill ? ''
      child.draw()

  hide: ->
    for child in @group.children
      child.hide()

  show: ->
    for child in @group.children
      child.show()

  getRotation: ->
    # We may not have been assigned to a layer yet
    rot = if @group.getLayer()? then @group.getLayer().rotation() else 0
    rot += @group.rotation()
    rot % 360

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

  getLargeBarrelRollTransform: (side, distance_from_front) ->
    if distance_from_front > @width - exportObj.SMALL_BASE_WIDTH
      throw new Error("Barrel roll template for Large ships placed too far back (#{distance_from_front} but base width is #{@width}) and template length is #{exportObj.SMALL_BASE_WIDTH}")

    distance_from_front += exportObj.TEMPLATE_WIDTH

    switch side
      when 'left'
        @group.getAbsoluteTransform().copy().translate(0, distance_from_front)
      when 'right'
        @group.getAbsoluteTransform().copy().translate(@width, distance_from_front)
      else
        throw new Error("Invalid side #{side}")

  getCenterTransform: ->
    @group.getAbsoluteTransform().copy().translate(@width / 2, @width / 2)

  newBaseFromMovement: (movement) ->
    {transform, heading_deg} = movement.getBaseTransformAndHeading this
    p = transform.point {x:0, y:0}
    new exportObj.Base
      size: @size
      position: new Position
        center_x: p.x
        center_y: p.y
        heading_deg: heading_deg

  addFiringArc: (args) ->
    firingarc = new exportObj.FiringArc
      base: this
      rotation: args?.rotation
      angle: args?.angle
    @firingarcs.push firingarc
    firingarc

  addRangeBand: (args) ->
    unless @range_band?
      @range_band = new exportObj.RangeBand
        base: this
    @range_band
