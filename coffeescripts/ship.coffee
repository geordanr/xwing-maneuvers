exportObj = exports ? this

class exportObj.Ship
  constructor: (args) ->
    @stage = args.stage
    @name = args.name
    @size = args.size
    @start_position = new exportObj.Position
      center_x: args.x
      center_y: args.y
      heading_deg: args.heading_deg

    @draw_options = {}

    # Turn 0
    turn = new Turn
      ship: this
      start_position: @start_position
    turn.execute()
    @turns = [turn]

    @layer = new Kinetic.Layer
      draggable: true
      x: @start_position.x
      y: @start_position.y
      offset: @start_position

    @layer.on 'mouseenter', (e) ->
      document.body.style.cursor = 'move'
    .on 'mouseleave', (e) ->
      document.body.style.cursor = 'default'
    .on 'click', (e) =>
      $(exportObj).trigger 'xwm:shipSelected', this
    @stage.add @layer

  addTurn: (args) ->
    turn = new Turn
      ship: this
      start_position: @turns[@turns.length - 1].final_position
    turn.execute()
    @turns.push turn
    turn

  setDrawOptions: (args) ->
    # Default draws all turns; otherwise, takes a list of ints
    # (can be a CoffeeScript range [0..10])
    @draw_options.turns = args.turns ? null

    # e.g. {stroke: 'blue', strokeWidth: 3}
    @draw_options.kinetic_draw_args = args.kinetic_draw_args ? null

    # If set, draws only the final position for each turn
    @draw_options.final_positions_only = Boolean(args.final_positions_only ? false)

  draw: ->
    @layer.clear()
    for turn_idx in @draw_options.turns ? [0...@turns.length]
      if turn_idx < @turns.length
        if @draw_options.final_positions_only
          @turns[turn_idx].drawFinalPositionOnly @layer, @draw_options.kinetic_draw_args
        else
          @turns[turn_idx].drawMovements @layer, @draw_options.kinetic_draw_args

  moveToTop: ->
    @layer.moveToTop()

class Turn
  constructor: (args) ->
    @ship = args.ship
    @base_at_start = new exportObj.Base
      size: @ship.size
      position: args.start_position

    @movements = []
    @bases = []
    @templates = []

    @final_position = null

  execute: ->
    # Creates bases and templates, but does not draw them.
    @bases = []
    @templates = []
    cur_base = @base_at_start
    for movement in @movements
      if movement?
        @templates.push movement.getTemplateForBase cur_base
        new_base = cur_base.newBaseFromMovement movement
        @bases.push new_base
        cur_base = new_base
    if @bases.length > 0
      @final_position = @bases[@bases.length - 1].position
    else
      # no movement (e.g. 0 stop)
      @bases = [@base_at_start]
      @final_position = @base_at_start.position

  drawMovements: (layer, args={}) ->
    for base in @bases
      base.draw layer, args
    for template in @templates
      template.draw layer, args

  drawFinalPositionOnly: (layer, args={}) ->
    @bases[@bases.length - 1].draw layer, args

  addMovement: (movement) ->
    @movements.push movement
    # should I @execute() here?
    @execute()
