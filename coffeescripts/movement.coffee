exportObj = exports ? this

exportObj.movements = {}

class Movement
  constructor: (args) ->
    @speed = args.speed
    @direction = args.direction
    @element = $.parseHTML @toHTML()

  destroy: ->
    # not much to do
    ''

  getBaseTransformAndHeading: (base) ->
    throw new Error('Base class; implement me!')

  getTemplateForBase: (base) ->
    throw new Error('Base class; implement me!')

  toHTML: ->
    throw new Error('Base class; implement me!')

class exportObj.movements.Straight extends Movement
  # Movement when a straight template is placed on the front nubs
  constructor: (args) ->
    super args

  getBaseTransformAndHeading: (base) ->
    transform: base.getFrontNubTransform().translate 0, -@speed * exportObj.SMALL_BASE_WIDTH - (base.width / 2)
    heading_deg: base.position.heading_deg

  getTemplateForBase: (base) ->
    new exportObj.templates.Straight
      speed: @speed
      direction: @direction
      base: base
      where: 'front_nubs'

  toHTML: ->
    """<span class="movement">#{exportObj.ManeuverGrid.makeManeuverIcon 'straight'}&nbsp;#{@speed}</span>"""

class exportObj.movements.Koiogran extends Movement
  # K-turn from the front nubs
  constructor: (args) ->
    super args

  getBaseTransformAndHeading: (base) ->
    transform: base.getFrontNubTransform().translate 0, -@speed * exportObj.SMALL_BASE_WIDTH - (base.width / 2)
    heading_deg: (base.position.heading_deg + 180) % 360

  getTemplateForBase: (base) ->
    new exportObj.templates.Straight
      speed: @speed
      direction: @direction
      base: base
      where: 'front_nubs'

  toHTML: ->
    """<span class="movement">#{exportObj.ManeuverGrid.makeManeuverIcon 'koiogran'}&nbsp;#{@speed}</span>"""

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

  getTemplateForBase: (base) ->
    new exportObj.templates.Bank
      speed: @speed
      direction: @direction
      base: base
      where: 'front_nubs'

  toHTML: ->
    """<span class="movement">#{exportObj.ManeuverGrid.makeManeuverIcon "bank#{@direction}"}&nbsp;#{@speed}</span>"""

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

  getTemplateForBase: (base) ->
    new exportObj.templates.Turn
      speed: @speed
      direction: @direction
      base: base
      where: 'front_nubs'

  toHTML: ->
    """<span class="movement">#{exportObj.ManeuverGrid.makeManeuverIcon "turn#{@direction}"}&nbsp;#{@speed}</span>"""

class exportObj.movements.BarrelRoll extends Movement
  # Template aligned on the sides
  # Takes additional arguments start_distance_from_front, end_distance_from_front
  constructor: (args) ->
    super args
    @speed ?= 1

    throw new Error('Missing argument start_distance_from_front') unless args.start_distance_from_front?
    @start_distance_from_front = args.start_distance_from_front

    throw new Error('Missing argument end_distance_from_front') unless args.end_distance_from_front?
    @end_distance_from_front = args.end_distance_from_front

  getBaseTransformAndHeading: (base) ->
    x_offset = (@speed * exportObj.SMALL_BASE_WIDTH) + (base.width / 2)
    y_offset = ((base.width - exportObj.TEMPLATE_WIDTH) / 2) - @end_distance_from_front
    switch @direction
      when 'left'
        rotation = 0
        transform = base.getBarrelRollTransform(@direction, @start_distance_from_front)
          .translate -x_offset, y_offset

      when 'right'
        rotation = 0
        transform = base.getBarrelRollTransform(@direction, @start_distance_from_front)
          .translate x_offset, y_offset

      when 'leftforward'
        d = exportObj.BANK_INSIDE_RADII[@speed] + ((exportObj.TEMPLATE_WIDTH) / 2)
        rotation = 45
        transform = base.getBarrelRollTransform(@direction, @start_distance_from_front)
          .translate(0, -d)
          .rotate(Math.PI / 4)
          .translate(-base.width / 2, d + y_offset)

      when 'leftbackward'
        d = exportObj.BANK_INSIDE_RADII[@speed] + ((exportObj.TEMPLATE_WIDTH) / 2)
        rotation = 315
        transform = base.getBarrelRollTransform(@direction, @start_distance_from_front)
          .translate(0, d)
          .rotate(-Math.PI / 4)
          .translate(-base.width / 2, -d + y_offset)

      when 'rightforward'
        d = exportObj.BANK_INSIDE_RADII[@speed] + ((exportObj.TEMPLATE_WIDTH) / 2)
        rotation = 315
        transform = base.getBarrelRollTransform(@direction, @start_distance_from_front)
          .translate(0, -d)
          .rotate(-Math.PI / 4)
          .translate(base.width / 2, d + y_offset)

      when 'rightbackward'
        d = exportObj.BANK_INSIDE_RADII[@speed] + ((exportObj.TEMPLATE_WIDTH) / 2)
        rotation = 45
        transform = base.getBarrelRollTransform(@direction, @start_distance_from_front)
          .translate(0, d)
          .rotate(Math.PI / 4)
          .translate(base.width / 2, -d + y_offset)

      else
        throw new Error("Invalid direction #{@direction}")

    {
      transform: transform
      heading_deg: (base.getRotation() + rotation) % 360
    }

  getTemplateForBase: (base) ->
    switch @direction
      when 'left', 'right'
        new exportObj.templates.Straight
          speed: @speed
          base: base
          where: @direction
          distance_from_front: @start_distance_from_front

      when 'leftforward', 'rightbackward', 'leftbackward', 'rightforward'
        new exportObj.templates.Bank
          speed: @speed
          base: base
          where: @direction
          direction: @direction
          distance_from_front: @start_distance_from_front

      else
        throw new Error("Invalid direction #{@direction}")

  toHTML: ->
    switch @direction
      when 'left'
        """<span class="movement">#{exportObj.ManeuverGrid.makeManeuverIcon "straight", {rotate: -90}}&nbsp;#{@speed}</span>"""
      when 'right'
        """<span class="movement">#{exportObj.ManeuverGrid.makeManeuverIcon "straight", {rotate: 90}}&nbsp;#{@speed}</span>"""
      when 'leftforward'
        """<span class="movement">#{exportObj.ManeuverGrid.makeManeuverIcon "bankright", {rotate: -90}}&nbsp;#{@speed}</span>"""
      when 'leftbackward'
        """<span class="movement">#{exportObj.ManeuverGrid.makeManeuverIcon "bankleft", {rotate: -90}}&nbsp;#{@speed}</span>"""
      when 'rightforward'
        """<span class="movement">#{exportObj.ManeuverGrid.makeManeuverIcon "bankleft", {rotate: 90}}&nbsp;#{@speed}</span>"""
      when 'rightbackward'
        """<span class="movement">#{exportObj.ManeuverGrid.makeManeuverIcon "bankright", {rotate: -90}}&nbsp;#{@speed}</span>"""
      else
        throw new Error("Invalid direction #{@direction}")

class exportObj.movements.Decloak extends exportObj.movements.BarrelRoll
  constructor: (args) ->
    super args
    @speed = 2
