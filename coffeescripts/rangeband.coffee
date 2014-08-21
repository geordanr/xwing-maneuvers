exportObj = exports ? this

class exportObj.RangeBand
  # Draws range bands around a given base
  constructor: (args) ->
    @base = args.base

    @group = new Kinetic.Group
      name: 'range_group'
      x: @base.position.x
      y: @base.position.y
      rotation: @base.position.heading_deg
      listening: false

    @layer = args.layer ? @base.group.getLayer()
    @layer.add @group

    @isVisible = false

    @addRangeBandAtRange exportObj.RANGE1, 0.3
    @addRangeBandAtRange exportObj.RANGE2, 0.2
    @addRangeBandAtRange exportObj.RANGE3, 0.1

  addRangeBandAtRange: (range, alpha) ->
    @group.add new Kinetic.Arc
      name: 'range_arc'
      x: @base.width / 2
      y: -@base.width / 2
      angle: 90
      innerRadius: 0
      outerRadius: range
      fillBlue: 255
      fillAlpha: alpha
      rotationDeg: -90

    @group.add new Kinetic.Arc
      name: 'range_arc'
      x: @base.width / 2
      y: @base.width / 2
      angle: 90
      innerRadius: 0
      outerRadius: range
      fillBlue: 255
      fillAlpha: alpha

    @group.add new Kinetic.Arc
      name: 'range_arc'
      x: -@base.width / 2
      y: @base.width / 2
      angle: 90
      innerRadius: 0
      outerRadius: range
      fillBlue: 255
      fillAlpha: alpha
      rotationDeg: 90

    @group.add new Kinetic.Arc
      name: 'range_arc'
      x: -@base.width / 2
      y: -@base.width / 2
      angle: 90
      innerRadius: 0
      outerRadius: range
      fillBlue: 255
      fillAlpha: alpha
      rotationDeg: 180

    @group.add new Kinetic.Rect
      name: 'range_rect'
      x: @base.width / 2
      y: -@base.width / 2
      width: range
      height: @base.width
      fillBlue: 255
      fillAlpha: alpha

    @group.add new Kinetic.Rect
      name: 'range_rect'
      x: -(@base.width / 2) - range
      y: -@base.width / 2
      width: range
      height: @base.width
      fillBlue: 255
      fillAlpha: alpha

    @group.add new Kinetic.Rect
      name: 'range_rect'
      x: -@base.width / 2
      y: @base.width / 2
      width: @base.width
      height: range
      fillBlue: 255
      fillAlpha: alpha

    @group.add new Kinetic.Rect
      name: 'range_rect'
      x: -@base.width / 2
      y: -(@base.width / 2) - range
      width: @base.width
      height: range
      fillBlue: 255
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
