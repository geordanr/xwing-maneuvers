exportObj = exports ? this

class exportObj.FiringArc
  # A firing arc for a given base
  constructor: (args) ->
    @base = args.base
    @rotation = parseFloat(args.rotation ? 0) # 0 is up
    @angle = parseFloat(args.angle ? exportObj.PRIMARY_FIRING_ARC_DEG)

    @group = new Kinetic.Group
      name: 'firing_arc_group'
      x: @base.position.x
      y: @base.position.y
      #offsetX: base_center_point.x
      #offsetY: base_center_point.y
      rotation: (@base.position.heading_deg + @rotation + 270) % 360

    @addArcAtRange exportObj.RANGE1, 0.3
    @addArcAtRange exportObj.RANGE2, 0.2
    @addArcAtRange exportObj.RANGE3, 0.1

  addArcAtRange: (range, alpha) ->
    @group.add new Kinetic.Arc
      name: 'firing_arc_range_left_arc'
      x: @base.width / 2
      y: -@base.width / 2
      angle: @angle / 2
      innerRadius: 0
      outerRadius: range
      fillRed: 255
      fillAlpha: alpha
      rotationDeg: -@angle / 2

    @group.add new Kinetic.Arc
      name: 'firing_arc_range_right_arc'
      x: @base.width / 2
      y: @base.width / 2
      angle: @angle / 2
      innerRadius: 0
      outerRadius: range
      fillRed: 255
      fillAlpha: alpha

    @group.add new Kinetic.Rect
      name: 'firinc_arc_range_center'
      x: @base.width / 2
      y: -@base.width / 2
      width: range
      height: @base.width
      fillRed: 255
      fillAlpha: alpha

  destroy: ->

  draw: (layer) ->
    layer = @base.group.getLayer() unless layer?
    layer.add @group
    for child in @group.children
      child.draw()
