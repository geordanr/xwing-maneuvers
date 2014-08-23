exportObj = exports ? this

class exportObj.FiringArc
  # A firing arc for a given base
  constructor: (args) ->
    @base = args.base
    @rotation = parseFloat(args.rotation ? 0) # 0 is up
    @angle = parseFloat(args.angle ? exportObj.PRIMARY_FIRING_ARC_DEG)

    @layer = args.layer ? @base.group.getLayer()

    @isVisible = false

    @group = new Kinetic.Group
      name: 'firing_arc_group'
      x: @base.position.x
      y: @base.position.y
      rotation: (@base.position.heading_deg + @rotation + 270) % 360
      listening: false
    @layer.add @group

    @addArcAtRange exportObj.RANGE1, 0.3
    @addArcAtRange exportObj.RANGE2, 0.2
    @addArcAtRange exportObj.RANGE3, 0.1

  addArcAtRange: (range, alpha) ->
    y_offset = (@base.width / 2) * Math.tan((Math.PI * @angle / 180) / 2)

    @group.add new Kinetic.Arc
      name: 'firing_arc_range_left_arc'
      x: @base.width / 2
      y: -y_offset
      angle: @angle / 2
      innerRadius: 0
      outerRadius: range
      fillRed: 255
      fillAlpha: alpha
      rotationDeg: -@angle / 2

    @group.add new Kinetic.Arc
      name: 'firing_arc_range_right_arc'
      x: @base.width / 2
      y: y_offset
      angle: @angle / 2
      innerRadius: 0
      outerRadius: range
      fillRed: 255
      fillAlpha: alpha

    @group.add new Kinetic.Rect
      name: 'firinc_arc_range_center'
      x: @base.width / 2
      y: -y_offset
      width: range
      height: 2 * y_offset
      fillRed: 255
      fillAlpha: alpha

  destroy: ->
    @group.destroy()

  draw: ->
    @layer.clear()
    if @isVisible
      @group.show()
    else
      @group.hide()
    @layer.draw()
    this

  hide: ->
    @isVisible = false
    @draw()

  show: ->
    @isVisible = true
    @draw()

  toggle: ->
    if @isVisible
      @hide()
    else
      @show()
