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

  transformShip: (ship) ->
    # We always move half our base length, as far as I can tell
    ship.ctx.translate 0, -ship.width / 2

    switch @type
      when 'straight'
        ship.ctx.translate 0, -@distance * SMALL_BASE_WIDTH
      when 'bank'
        switch @direction
          when 'left'
            ship.ctx.translate -(exportObj.BANK_INSIDE_RADII[@distance] + (exportObj.TEMPLATE_WIDTH / 2) ), 0
            ship.ctx.rotate -Math.PI / 4
            ship.ctx.translate exportObj.BANK_INSIDE_RADII[@distance] + (exportObj.TEMPLATE_WIDTH / 2), 0
          when 'right'
            ship.ctx.translate exportObj.BANK_INSIDE_RADII[@distance] + (exportObj.TEMPLATE_WIDTH / 2), 0
            ship.ctx.rotate Math.PI / 4
            ship.ctx.translate -(exportObj.BANK_INSIDE_RADII[@distance] + (exportObj.TEMPLATE_WIDTH /2 )), 0
          else
            throw new Error("Invalid direction #{@direction}")
      when 'turn'
        switch @direction
          when 'left'
            ship.ctx.translate -(exportObj.TURN_INSIDE_RADII[@distance] + (exportObj.TEMPLATE_WIDTH / 2) ), 0
            ship.ctx.rotate -Math.PI / 2
            ship.ctx.translate exportObj.TURN_INSIDE_RADII[@distance] + (exportObj.TEMPLATE_WIDTH / 2), 0
          when 'right'
            ship.ctx.translate exportObj.TURN_INSIDE_RADII[@distance] + (exportObj.TEMPLATE_WIDTH / 2), 0
            ship.ctx.rotate Math.PI / 2
            ship.ctx.translate -(exportObj.TURN_INSIDE_RADII[@distance] + (exportObj.TEMPLATE_WIDTH /2 )), 0
          else
            throw new Error("Invalid direction #{@direction}")
      when 'koiogran'
        ''
      else
        throw new Error("Invalid template type #{@type}")

    # And move up some more
    ship.ctx.translate 0, -ship.width / 2

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

class exportObj.Movement
  constructor: (args) ->
    # Before comes from Advanced Sensors.
    # Before/after can be a boost or barrel roll.
    @before = args.before
    @template = args.template
    @after = args.after

class exportObj.Ship
  constructor: (args) ->
    @name = args.name
    @size = args.size
    @ctx = args.ctx

    @center_x = args.center_x ? 0
    @center_y = args.center_y ? 0
    @heading_radians = args.heading_radians ? exportObj.NORTH

    @width = switch @size
      when 'small'
        exportObj.SMALL_BASE_WIDTH
      when 'large'
        exportObj.LARGE_BASE_WIDTH
      else
        throw new Error("Invalid size #{@size}")

    @move_history = []

  addMove: (movement) ->
    @move_history.push movement

  drawMovements: ->
    @ctx.save()
    # Draw initial position
    exportObj.transformToCenterAndHeading @ctx, @width, @center_x, @center_y, @heading_radians
    @draw()
    try
      for movement in @move_history
        # TODO: before/after
        @placeTemplate movement.template
        movement.template.transformShip this
        @draw()
    catch e
      throw e
    finally
      @ctx.restore()

  draw: ->
    switch @size
      when 'small'
        exportObj.drawSmallBase @ctx
      when 'large'
        exportObj.drawLargeBase @ctx
      else
        throw new Error("Invalid size #{@size}")

  placeTemplate: (template) ->
    @ctx.save()
    try
      exportObj.translateToNubsFromCenter @ctx, @width
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
