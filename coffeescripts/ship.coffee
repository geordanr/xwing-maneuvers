exportObj = exports ? this

# because I drew the bases facing up
exportObj.NORTH = 0
exportObj.EAST = Math.PI / 2
exportObj.SOUTH = Math.PI
exportObj.WEST = -Math.PI / 2

class exportObj.Template
  constructor: (args) ->
    @type = args.type
    @distance = args.distance
    @direction = args.direction

exportObj.STRAIGHT1 = new exportObj.Template
  type: 'straight'
  distance: 1

exportObj.STRAIGHT2 = new exportObj.Template
  type: 'straight'
  distance: 2

exportObj.STRAIGHT3 = new exportObj.Template
  type: 'straight'
  distance: 3

exportObj.STRAIGHT4 = new exportObj.Template
  type: 'straight'
  distance: 4

exportObj.BANKLEFT1 = new exportObj.Template
  type: 'bank'
  direction: 'left'
  distance: 1

exportObj.BANKLEFT2 = new exportObj.Template
  type: 'bank'
  direction: 'left'
  distance: 2

exportObj.BANKLEFT3 = new exportObj.Template
  type: 'bank'
  direction: 'left'
  distance: 3

exportObj.BANKRIGHT1 = new exportObj.Template
  type: 'bank'
  direction: 'right'
  distance: 1

exportObj.BANKRIGHT2 = new exportObj.Template
  type: 'bank'
  direction: 'right'
  distance: 2

exportObj.BANKRIGHT3 = new exportObj.Template
  type: 'bank'
  direction: 'right'
  distance: 3

exportObj.TURNLEFT1 = new exportObj.Template
  type: 'turn'
  direction: 'left'
  distance: 1

exportObj.TURNLEFT2 = new exportObj.Template
  type: 'turn'
  direction: 'left'
  distance: 2

exportObj.TURNLEFT3 = new exportObj.Template
  type: 'turn'
  direction: 'left'
  distance: 3

exportObj.TURNRIGHT1 = new exportObj.Template
  type: 'turn'
  direction: 'right'
  distance: 1

exportObj.TURNRIGHT2 = new exportObj.Template
  type: 'turn'
  direction: 'right'
  distance: 2

exportObj.TURNRIGHT3 = new exportObj.Template
  type: 'turn'
  direction: 'right'
  distance: 3

class exportObj.Ship
  constructor: (args) ->
    @name = args.name
    @size = args.size
    @ctx = args.ctx

    @center_x = args.center_x ? 0
    @center_y = args.center_y ? 0
    @heading_radians = args.heading_radians ? exportObj.NORTH

  draw: ->
    @ctx.save()
    exportObj.transformToCenterAndHeading @ctx, @center_x, @center_y, @heading_radians
    try
      switch @size
        when 'small'
          exportObj.drawSmallBase @ctx
        when 'large'
          exportObj.drawLargeBase @ctx
        else
          throw new Error("Invalid size #{@size}")
    catch e
      throw e
    finally
      @ctx.restore()

  placeTemplate: (template) ->
    @ctx.save()
    try
      exportObj.transformToCenterAndHeading @ctx, @center_x, @center_y, @heading_radians
      exportObj.translateToNubsFromCenter @ctx, @size
      switch template.type
        when 'straight', 'koiogran'
          exportObj.drawStraight @ctx, template.distance
        when 'bank'
          exportObj.drawBank @ctx, template.distance, template.direction
        when 'turn'
          exportObj.drawTurn @ctx, template.distance, template.direction
        else
          throw new Error("Invalid template type #{template.type}")
    catch e
      throw e
    finally
      @ctx.restore()

  move: (template) ->
