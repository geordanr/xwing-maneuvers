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

    @selected_turn = null

    @shiplist_element = $ document.createElement('A')
    @shiplist_element.addClass 'list-group-item'
    @shiplist_element.data 'ship', this
    @shiplist_element.text @name
    @shiplist_element.click (e) =>
      e.preventDefault()
      $(exportObj).trigger 'xwm:shipSelected', this

    @turnlist_element = $ document.createElement('DIV')
    @turnlist_element.addClass 'list-group'
    @turnlist_element.hide()

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

    $(exportObj).on 'xwm:shipSelected', (e, ship) =>
      @turnlist_element.toggle(ship == this)

  select: ->
    @shiplist_element.addClass 'active'

  deselect: ->
    @shiplist_element.removeClass 'active'

  destroy: ->
    @shiplist_element.remove() if @shiplist_element?
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

  selectTurn: (turn) ->
    if turn != @selected_turn
      @selected_turn.deselect() if @selected_turn?

      @selected_turn = turn
      @selected_turn.select() if @selected_turn?

  executeTurns: ->
    # Re-executes all the turns.  Call this after the turn list has been modified.
    start_position = @turns[0].final_position
    for turn, i in @turns
      turn.setStartPosition start_position
      turn.execute()
      start_position = turn.final_position

class Turn
  # Represents an in-game turn.
  #
  # A turn can have an arbitrary number of movements.  In reality, a turn should only have
  # one actual movement, as well as opportunities for decloaking before movement, as well as
  # other movements (granted by Advanced Sensors or other pilot abilities) before and after
  # the actual movement.  These are not modeled or enforced here.
  constructor: (args) ->
    @ship = args.ship
    @setStartPosition args.start_position

    @movements = []
    @bases = []
    @templates = []

    @final_position = null
    @list_element = $ document.createElement('A')
    @list_element.addClass 'list-group-item'
    @list_element.append $.trim """
      <button type="button" class="close remove-turn"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
    """
    @list_element.click (e) =>
      e.preventDefault()
      $(exportObj).trigger 'xwm:turnSelected', this
    @list_element.find('.remove-turn').click (e) =>
      e.preventDefault()
      $(exportObj).trigger 'xwm:removeTurn', this

    $(exportObj).on 'xwm:turnSelected', (e, turn) =>
      @list_element.toggleClass('active', turn == this)
    .on 'xwm:removeTurn', (e, turn) =>
      turn.destroy()
      @ship.executeTurns()
      @ship.draw()

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
      @ship.turns.splice idx, 1

  execute: ->
    # Creates bases and templates, but does not draw them.
    for base in @bases
      base.destroy()
    @bases = []
    for template in @templates
      template.destroy()
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
    @list_element.append movement.element
    @execute()

  removeMovement: (movement) ->
    idx = @movements.indexOf movement
    if idx != -1
      movement = @movements.splice idx, 1
      movement.element.remove()
      execute()

  select: ->
    @list_element.addClass 'active'

  deselect: ->
    @list_element.removeClass 'active'

  setStartPosition: (position) ->
    @base_at_start = new exportObj.Base
      size: @ship.size
      position: position
