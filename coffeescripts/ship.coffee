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

    # Turn 0
    turn = new Turn
      ship: this
      start_position: @start_position
    turn.execute()
    @turns = [turn]

    @layer = new Kinetic.Layer({draggable:true})
    @layer.on 'mouseenter', (e) ->
      document.body.style.cursor = 'move'
    @layer.on 'mouseleave', (e) ->
      document.body.style.cursor = 'default'
    @stage.add @layer

  addTurn: (args) ->
    turn = new Turn
      ship: this
      start_position: @turns[@turns.length - 1].final_position
      before: args.before
      during: args.during
      after: args.after
    turn.execute()
    @turns.push turn

  drawTurnMovement: (i, args) ->
    @turns[i].drawMovements @layer, args

  drawTurnFinalPosition: (i, args) ->
    @turns[i].drawFinalPositionOnly @layer, args

  drawAllTurnMovements: (args) ->
    for turn in @turns
      turn.drawMovements @layer, args

class Turn
  constructor: (args) ->
    @ship = args.ship
    @base_at_start = new exportObj.Base
      size: @ship.size
      position: args.start_position
    @before = args.before
    @during = args.during
    @after = args.after

    @bases = []
    @templates = []

    @final_position = null

  execute: ->
    # Creates bases and templates, but does not draw them.
    @bases = []
    @templates = []
    cur_base = @base_at_start
    for movement in [@before, @during, @after]
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
