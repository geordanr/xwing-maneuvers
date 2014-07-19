exportObj = exports ? this

class exportObj.Ship
  constructor: (args) ->
    @stage = args.stage
    @name = $.trim(args.name ? "")
    @size = args.size
    @start_position = new exportObj.Position
      center_x: args.x
      center_y: args.y
      heading_deg: args.heading_deg

    @name = "Unnamed Ship" if @name == ""

    @list_element = $ document.createElement('li')
    @list_element.addClass 'shipbutton'
    @select_ship_button = $ document.createElement('BUTTON')
    @select_ship_button.data 'ship', this
    @select_ship_button.text @name
    @select_ship_button.addClass 'btn btn-block'
    @select_ship_button.click (e) =>
      e.preventDefault()
      $(exportObj).trigger 'xwm:shipSelected', this
    @list_element.append @select_ship_button

    @turnlist_element = $ document.createElement('ol')

    @draw_options = {}

    # Turn 0
    turn = new Turn
      ship: this
      start_position: @start_position
    turn.execute()
    @turns = [turn]

    @layer = new Kinetic.Layer
      name: "ship"
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

  destroy: ->
    @list_element.remove() if @list_element?
    @turnlist_element.remove() if @turnlist_element?
    @layer.destroyChildren() # dunno if destroy() does this, so just in case
    @layer.destroy()

  addTurn: (args) ->
    turn = new Turn
      ship: this
      start_position: @turns[@turns.length - 1].final_position
    turn.execute()
    @turns.push turn
    @turnlist_element.append turn.list_element
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

    @list_element = $ document.createElement('LI')

  destroy: ->
    @base_at_start = null
    for base in @bases
      base.destroy()
    for template in @templates
      template.destroy()
    for movement in @movements
      movement.destroy()
    @list_element.remove() if @list_element?
    idx = @ship.turns.indexOf this
    if idx != -1
      @ship.turns.splice idx, 0

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
    @updateListElement()
    @execute()

  removeMovement: (movement) ->
    idx = @movements.indexOf movement
    if idx != -1
      @movements.splice idx, 0
      @updateListElement()
      execute()

  updateListElement: ->
    @list_element.text ''
    for movement in @movements
      @list_element.append movement.toHTML()
