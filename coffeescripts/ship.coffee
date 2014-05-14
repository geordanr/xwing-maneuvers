exportObj = exports ? this

# because I drew the bases facing up
exportObj.NORTH = 0
exportObj.EAST = Math.PI / 2
exportObj.SOUTH = Math.PI
exportObj.WEST = -Math.PI / 2

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

  placeTemplate: (type, distance, direction) ->
    @ctx.save()
    try
      exportObj.transformToCenterAndHeading @ctx, @center_x, @center_y, @heading_radians
      exportObj.translateToNubsFromCenter @ctx, @size
      switch type
        when 'straight', 'koiogran'
          exportObj.drawStraight @ctx, distance
        when 'bank'
          exportObj.drawBank @ctx, distance, direction
        when 'turn'
          exportObj.drawTurn @ctx, distance, direction
        else
          throw new Error("Invalid template type #{type}")
    catch e
      throw e
    finally
      @ctx.restore()
