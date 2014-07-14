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
    @turns = [
      new Turn
        ship: this
        start_position: @start_position
    ]

    @layer = new Kinetic.Layer()
    @stage.add @layer

  addTurn: (args) ->
    @turns.push new Turn
      ship: this
      start_position: @turns[@turns.length - 1].base_at_start.position
      before: args.before
      during: args.during
      after: args.after

  drawTurns: (args) ->
    for turn in @turns
      turn.draw @layer, args

class Turn
  constructor: (args) ->
    @ship = args.ship
    @base_at_start = new exportObj.Base
      size: @ship.size
      position: args.start_position
    @before = args.before
    @during = args.during
    @after = args.after

  draw: (layer, args={}) ->
    cur_base = @base_at_start
    for movement in [@before, @during, @after]
      if movement?
        template = movement.getTemplateForBase cur_base
        template.draw layer, args
        new_base = cur_base.newBaseFromMovement movement
        new_base.draw layer, args
        cur_base = new_base
