exportObj = exports ? this

exportObj.movements = {}

class Movement
  constructor: (args) ->
    @speed = args.speed
    @direction = args.direction

  getBaseTransform: (base) ->
    throw new Error('Base class; implement me!')

class exportObj.movements.Straight extends Movement
  # Movement when a straight template is placed on the front nubs
  constructor: (args) ->
    super args

  getBaseTransform: (base) ->
    base.group.getAbsoluteTransform().copy().translate base.width / 2, -@speed * exportObj.SMALL_BASE_WIDTH - (base.width / 2)
