exportObj = exports ? this

exportObj.movements = {}

class exportObj.MovementList extends Array
  constructor: (args) ->
    super args

    @stage = args.stage
    @ship = args.ship
    @color = args.color

    @layer = new Kinetic.Layer()
    @stage.add @layer

  drawMoves: (args) ->
    first = args.first ? 0
    last = args.last ? @length - 1
    [first, last] = [Math.min(first, last, 0), Math.max(first, last, @length - 1)]
    for i in [first..last]
      @[i].draw()

  addMovement: (movement) ->
    @push movement
    movement.list = this

class exportObj.Movement
  constructor: (args) ->
    @start_center_x
    @before = args.before
    @during = args.during
    @after = args.after

  draw: (args) ->

