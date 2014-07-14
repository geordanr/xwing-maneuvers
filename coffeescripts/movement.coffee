exportObj = exports ? this

exportObj.movements = {}

class Movement
  constructor: (args) ->
    @speed = args.speed
    @direction = args.direction

  getBaseTransformAndHeading: (base) ->
    throw new Error('Base class; implement me!')

class exportObj.movements.Straight extends Movement
  # Movement when a straight template is placed on the front nubs
  constructor: (args) ->
    super args

  getBaseTransformAndHeading: (base) ->
    transform: base.getFrontNubTransform().translate 0, -@speed * exportObj.SMALL_BASE_WIDTH - (base.width / 2)
    heading_deg: base.position.heading_deg

class exportObj.movements.Koiogran extends Movement
  # K-turn from the front nubs
  constructor: (args) ->
    super args

  getBaseTransformAndHeading: (base) ->
    transform: base.getFrontNubTransform().translate 0, -@speed * exportObj.SMALL_BASE_WIDTH - (base.width / 2)
    heading_deg: (base.position.heading_deg + 180) % 360

class exportObj.movements.Bank extends Movement
  # Bank from the front nubs
  constructor: (args) ->
    super args

  getBaseTransformAndHeading: (base) ->
    switch @direction
      when 'left'
        d = exportObj.BANK_INSIDE_RADII[@speed] + (exportObj.TEMPLATE_WIDTH / 2)
        rotation = 315
        transform = base.getFrontNubTransform()
          .translate(-d, 0)
          .rotate(-Math.PI / 4)
          .translate(d, -base.width / 2)
      when 'right'
        d = exportObj.BANK_INSIDE_RADII[@speed] + ((exportObj.TEMPLATE_WIDTH) / 2)
        rotation = 45
        transform = base.getFrontNubTransform()
          .translate(d, 0)
          .rotate(Math.PI / 4)
          .translate(-d, -base.width / 2)
      else
        throw new Error("Invalid direction #{@direction}")

    {
      transform: transform
      heading_deg: (base.position.heading_deg + rotation) % 360
    }

class exportObj.movements.Turn extends Movement
  # Turn from the front nubs
  constructor: (args) ->
    super args

  getBaseTransformAndHeading: (base) ->
    switch @direction
      when 'left'
        d = exportObj.TURN_INSIDE_RADII[@speed] + (exportObj.TEMPLATE_WIDTH / 2)
        rotation = 270
        transform = base.getFrontNubTransform()
          .translate(-d, 0)
          .rotate(-Math.PI / 2)
          .translate(d, -base.width / 2)
      when 'right'
        d = exportObj.TURN_INSIDE_RADII[@speed] + ((exportObj.TEMPLATE_WIDTH) / 2)
        rotation = 90
        transform = base.getFrontNubTransform()
          .translate(d, 0)
          .rotate(Math.PI / 2)
          .translate(-d, -base.width / 2)
      else
        throw new Error("Invalid direction #{@direction}")

    {
      transform: transform
      heading_deg: (base.position.heading_deg + rotation) % 360
    }

class exportObj.movements.BarrelRoll extends Movement
  # Template aligned on the sides
  # Takes additional arguments start_distance_from_front, end_distance_from_front
  constructor: (args) ->
    super args

    throw new Error('Missing argument start_distance_from_front') unless args.start_distance_from_front?
    @start_distance_from_front = args.start_distance_from_front

    throw new Error('Missing argument end_distance_from_front') unless args.end_distance_from_front?
    @end_distance_from_front = args.end_distance_from_front

  getBaseTransformAndHeading: (base) ->
    x_offset = base.width + (@speed * exportObj.SMALL_BASE_WIDTH)
    switch @direction
      when 'left'
        rotation = 0
        transform = base.getBarrelRollTransform(@direction, @start_distance_from_front)
          .translate -(@speed * exportObj.SMALL_BASE_WIDTH) - (base.width / 2), 0
        console.log transform
      when 'right'
        t.translate x_offset, -@end_speed_from_front + @start_speed_from_front
      when 'leftforward'
        #t.strokeStyle = 'red'
        #ship.draw()
        t.translate -ship.width / 2, @start_speed_from_front - (ship.width / 2) - exportObj.BANK_INSIDE_RADII[@speed]
        #t.strokeStyle = 'green'
        #ship.draw()
        t.rotate Math.PI / 4
        #t.strokeStyle = 'blue'
        #ship.draw()
        t.translate -ship.width / 2, -@end_speed_from_front + (ship.width / 2) + exportObj.BANK_INSIDE_RADII[@speed]
        #t.strokeStyle = 'orange'
      when 'leftback'
        t.translate -ship.width / 2, @start_speed_from_front - (ship.width / 2) + exportObj.TEMPLATE_WIDTH + exportObj.BANK_INSIDE_RADII[@speed]
        t.rotate -Math.PI / 4
        t.translate -ship.width / 2, -exportObj.BANK_INSIDE_RADII[@speed] - exportObj.TEMPLATE_WIDTH + (ship.width / 2) - @end_speed_from_front
      when 'rightforward'
        #t.strokeStyle = 'red'
        #ship.draw()
        t.translate ship.width / 2, @start_speed_from_front - (ship.width / 2) - exportObj.BANK_INSIDE_RADII[@speed]
        #t.strokeStyle = 'green'
        #ship.draw()
        t.rotate -Math.PI / 4
        #t.strokeStyle = 'blue'
        #ship.draw()
        t.translate ship.width / 2, -@end_speed_from_front + (ship.width / 2) + exportObj.BANK_INSIDE_RADII[@speed]
        #t.strokeStyle = 'orange'
      when 'rightback'
        t.translate ship.width / 2, @start_speed_from_front - (ship.width / 2) + exportObj.TEMPLATE_WIDTH + exportObj.BANK_INSIDE_RADII[@speed]
        t.rotate Math.PI / 4
        t.translate ship.width / 2, -exportObj.BANK_INSIDE_RADII[@speed] - exportObj.TEMPLATE_WIDTH + (ship.width / 2) - @end_speed_from_front
      else
        throw new Error("Invalid direction #{@direction}")

    {
      transform: transform
      heading_deg: (base.position.heading_deg + rotation) % 360
    }
