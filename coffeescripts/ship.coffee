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
    @draw_options = args.draw_options

    @name = "Unnamed Ship" if @name == ""

    @selected_turn = null
    @isSelected = false

    @shiplist_element = $ document.createElement('A')
    @shiplist_element.addClass 'list-group-item'
    @shiplist_element.data 'ship', this
    @shiplist_element.text @name
    @shiplist_element.click (e) =>
      e.preventDefault()
      $(exportObj).trigger 'xwm:shipSelected', this
    @shiplist_element.append $.trim """
      <button type="button" class="close remove-turn"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
    """
    @shiplist_element.find('.close').click (e) =>
      e.preventDefault()
      $(exportObj).trigger 'xwm:destroyShip', this

    @turnlist_element = $ document.createElement('DIV')
    @turnlist_element.addClass 'list-group'
    @turnlist_element.sortable
      axis: 'y'
      handle: '.sort-handle'
      update: (e, ui) =>
        @turns = [@turns[0]].concat($(elem).data('turn_obj') for elem in @turnlist_element.find('.turn-element'))
        @executeTurnsAndDraw()
    @turnlist_element.hide()

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
      @isSelected = ship is this
      @turnlist_element.toggle @isSelected
    .on 'xwm:destroyShip', (e, ship) =>
      if ship is this
        @destroy()
    .on 'xwm:showFinalManeuverOnly', (e, toggle) =>
      @draw_options.show_final_maneuver_only = toggle
      @draw()
    .on 'xwm:showMovementTemplates', (e, toggle) =>
      @draw_options.show_movement_templates = toggle
      @draw()
    .on 'xwm:showLastTurnOnly', (e, toggle) =>
      @draw_options.show_last_turn_only = toggle
      @draw()

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
    @draw()
    turn

  setDrawOptions: (args) ->
    # Default draws all turns; otherwise, takes a list of ints
    # (can be a CoffeeScript range [0..10])
    @draw_options.turns = args.turns ? null

    # e.g. {stroke: 'blue', strokeWidth: 3}
    @draw_options.kinetic_draw_args = $.extend(@draw_options.kinetic_draw_args, args.kinetic_draw_args ? {})

    # If set, draws only the final position for each turn
    @draw_options.final_positions_only = Boolean(args.final_positions_only ? false)

  draw: ->
    @layer.clear()
    if @draw_options.show_last_turn_only
      for turn, turn_idx in @turns
        if turn_idx < @turns.length - 1
          turn.hide()
        else
          turn.show()
        turn.draw @layer, @draw_options
    else
      for turn_idx in @draw_options.turns ? [0...@turns.length]
        if turn_idx < @turns.length
          @turns[turn_idx].show()
          @turns[turn_idx].draw @layer, @draw_options

  moveToTop: ->
    @layer.moveToTop()

  selectTurn: (turn) ->
    if turn != @selected_turn
      @selected_turn.deselect() if @selected_turn?

      @selected_turn = turn
      @selected_turn.select() if @selected_turn?

  executeTurnsAndDraw: ->
    # Re-executes all the turns.  Call this after the turn list has been modified.
    start_position = @turns[0].final_position
    for turn, i in @turns
      turn.setStartPosition start_position
      turn.execute()
      start_position = turn.final_position
    @draw()
    this

  clone: ->
    start_position = @turns[0].final_position
    newship = new exportObj.Ship
      stage: @stage
      name: "Copy of #{@name}"
      size: @size
      x: start_position.center_x
      y: start_position.center_y
      heading_deg: start_position.heading_deg
      draw_options: $.extend {}, @draw_options, true

    for turn, i in @turns
      if i > 0
        newturn = newship.addTurn()
        for movement in turn.movements
          newturn.addMovement movement.clone()

    newship

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

    @isSelected = false
    @isVisible = true
    @final_position = null
    @list_element = $ document.createElement('A')
    @list_element.addClass 'list-group-item turn-element'
    @list_element.append $.trim """
      <span class="glyphicon glyphicon-align-justify sort-handle"></span>
      <span class="executed-movements"></span>
      <button class="btn btn-default add-decloak">Decloak</button>
      <button class="btn btn-default add-movement">Movement</button>
      <button class="btn btn-default add-boost">Boost</button>
      <button class="btn btn-default add-barrel-roll">Barrel Roll</button>
      <button class="btn btn-default add-daredevil">Daredevil</button>
      <button type="button" class="close remove-turn"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
    """
    @list_element.click (e) =>
      e.preventDefault()
      $(exportObj).trigger 'xwm:turnSelected', this
    @list_element.find('.remove-turn').click (e) =>
      e.preventDefault()
      $(exportObj).trigger 'xwm:removeTurn', this
    @list_element.data 'turn_obj', this

    @list_element.find('.add-movement').click (e) ->
      $(exportObj).trigger 'xwm:showMovementSelections'
    @list_element.find('.add-barrel-roll').click (e) ->
      $(exportObj).trigger 'xwm:showBarrelRollSelections'
    @list_element.find('.add-decloak').click (e) ->
      $(exportObj).trigger 'xwm:showDecloakSelections'
    @list_element.find('.add-boost').click (e) ->
      $(exportObj).trigger 'xwm:showBoostSelections'
    @list_element.find('.add-daredevil').click (e) ->
      $(exportObj).trigger 'xwm:showDaredevilSelections'

    $(exportObj).on 'xwm:turnSelected', (e, turn) =>
      @isSelected = turn is this
      @list_element.toggleClass 'active', @isSelected
    .on 'xwm:removeTurn', (e, turn) =>
      turn.destroy()
      @ship.executeTurnsAndDraw()
    .on 'xwm:executeBarrelRoll', (e, movement) =>
      if @ship.isSelected and @isSelected
        @addMovement movement
        $(exportObj).trigger 'xwm:resetBarrelRollData', $.noop
        @ship.executeTurnsAndDraw()
    .on 'xwm:movementClicked', (e, args) =>
      if @ship.isSelected and @isSelected
        $(exportObj).trigger 'xwm:resetBarrelRollData', (barrelroll_template_layer) =>
          start_base = @bases[@bases.length - 1]

          switch args.direction
            when 'stop'
              # do nothing? should mark it somehow
              ''
            when 'straight'
              @addMovement new exportObj.movements.Straight {speed: args.speed}
              @ship.executeTurnsAndDraw()
            when 'bankleft'
              @addMovement new exportObj.movements.Bank
                speed: args.speed
                direction: 'left'
              @ship.executeTurnsAndDraw()
            when 'bankright'
              @addMovement new exportObj.movements.Bank
                speed: args.speed
                direction: 'right'
              @ship.executeTurnsAndDraw()
            when 'turnleft'
              @addMovement new exportObj.movements.Turn
                speed: args.speed
                direction: 'left'
              @ship.executeTurnsAndDraw()
            when 'turnright'
              @addMovement new exportObj.movements.Turn
                speed: args.speed
                direction: 'right'
              @ship.executeTurnsAndDraw()
            when 'koiogran'
              @addMovement new exportObj.movements.Koiogran {speed: args.speed}
              @ship.executeTurnsAndDraw()
            when 'decloak-forward-left'
              @addMovement new exportObj.movements.DecloakForwardLeft()
              @ship.executeTurnsAndDraw()
            when 'decloak-forward-right'
              @addMovement new exportObj.movements.DecloakForwardRight()
              @ship.executeTurnsAndDraw()
            when 'daredevil-left'
              @addMovement new exportObj.movements.DaredevilLeft()
              @ship.executeTurnsAndDraw()
            when 'daredevil-right'
              @addMovement new exportObj.movements.DaredevilRight()
              @ship.executeTurnsAndDraw()
            when 'boost'
              @addMovement new exportObj.movements.Boost()
              @ship.executeTurnsAndDraw()
            when 'boost-left'
              @addMovement new exportObj.movements.BoostLeft()
              @ship.executeTurnsAndDraw()
            when 'boost-right'
              @addMovement new exportObj.movements.BoostRight()
              @ship.executeTurnsAndDraw()
            when 'barrelroll-left'
              if @ship.size == 'large'
                barrelroll_template_layer.dragBoundFunc @makeBarrelRollTemplateDragBoundFunc(start_base, 'left', 0, true)
                $(exportObj).trigger 'xwm:initiateBarrelRoll', [start_base, new exportObj.movements.LargeBarrelRoll
                  base: start_base
                  where: 'left'
                  direction: 'left'
                  start_distance_from_front: 0
                  end_distance_from_front: 0
                ]
              else
                barrelroll_template_layer.dragBoundFunc @makeBarrelRollTemplateDragBoundFunc(start_base, 'left', 0)
                $(exportObj).trigger 'xwm:initiateBarrelRoll', [start_base, new exportObj.movements.BarrelRoll
                  base: start_base
                  where: 'left'
                  direction: 'left'
                  start_distance_from_front: 0
                  end_distance_from_front: 0
                ]

            when 'barrelroll-leftforward'
              barrelroll_template_layer.dragBoundFunc @makeBarrelRollTemplateDragBoundFunc(start_base, 'left', 0)
              $(exportObj).trigger 'xwm:initiateBarrelRoll', [start_base, new exportObj.movements.BarrelRoll
                base: start_base
                where: 'left'
                direction: 'leftforward'
                start_distance_from_front: 0
                end_distance_from_front: 0
              ]

            when 'barrelroll-leftbackward'
              barrelroll_template_layer.dragBoundFunc @makeBarrelRollTemplateDragBoundFunc(start_base, 'left', 0)
              $(exportObj).trigger 'xwm:initiateBarrelRoll', [start_base, new exportObj.movements.BarrelRoll
                base: start_base
                where: 'left'
                direction: 'leftbackward'
                start_distance_from_front: 0
                end_distance_from_front: 0
              ]

            when 'barrelroll-right'
              if @ship.size == 'large'
                barrelroll_template_layer.dragBoundFunc @makeBarrelRollTemplateDragBoundFunc(start_base, 'right', 0, true)
                $(exportObj).trigger 'xwm:initiateBarrelRoll', [start_base, new exportObj.movements.LargeBarrelRoll
                  base: start_base
                  where: 'right'
                  direction: 'right'
                  start_distance_from_front: 0
                  end_distance_from_front: 0
                ]
              else
                barrelroll_template_layer.dragBoundFunc @makeBarrelRollTemplateDragBoundFunc(start_base, 'right', 0)
                $(exportObj).trigger 'xwm:initiateBarrelRoll', [start_base, new exportObj.movements.BarrelRoll
                  base: start_base
                  where: 'right'
                  direction: 'right'
                  start_distance_from_front: 0
                  end_distance_from_front: 0
                ]

            when 'barrelroll-rightforward'
              barrelroll_template_layer.dragBoundFunc @makeBarrelRollTemplateDragBoundFunc(start_base, 'right', 0)
              $(exportObj).trigger 'xwm:initiateBarrelRoll', [start_base, new exportObj.movements.BarrelRoll
                base: start_base
                where: 'right'
                direction: 'rightforward'
                start_distance_from_front: 0
                end_distance_from_front: 0
              ]

            when 'barrelroll-rightbackward'
              barrelroll_template_layer.dragBoundFunc @makeBarrelRollTemplateDragBoundFunc(start_base, 'right', 0)
              $(exportObj).trigger 'xwm:initiateBarrelRoll', [start_base, new exportObj.movements.BarrelRoll
                base: start_base
                where: 'right'
                direction: 'rightbackward'
                start_distance_from_front: 0
                end_distance_from_front: 0
              ]

            when 'decloak-left'
              barrelroll_template_layer.dragBoundFunc @makeBarrelRollTemplateDragBoundFunc(start_base, 'left', 0)
              $(exportObj).trigger 'xwm:initiateBarrelRoll', [start_base, new exportObj.movements.Decloak
                base: start_base
                where: 'left'
                direction: 'left'
                start_distance_from_front: 0
                end_distance_from_front: 0
              ]

            when 'decloak-leftforward'
              barrelroll_template_layer.dragBoundFunc @makeBarrelRollTemplateDragBoundFunc(start_base, 'left', 0)
              $(exportObj).trigger 'xwm:initiateBarrelRoll', [start_base, new exportObj.movements.Decloak
                base: start_base
                where: 'left'
                direction: 'leftforward'
                start_distance_from_front: 0
                end_distance_from_front: 0
              ]

            when 'decloak-leftbackward'
              barrelroll_template_layer.dragBoundFunc @makeBarrelRollTemplateDragBoundFunc(start_base, 'left', 0)
              $(exportObj).trigger 'xwm:initiateBarrelRoll', [start_base, new exportObj.movements.Decloak
                base: start_base
                where: 'left'
                direction: 'leftbackward'
                start_distance_from_front: 0
                end_distance_from_front: 0
              ]

            when 'decloak-right'
              barrelroll_template_layer.dragBoundFunc @makeBarrelRollTemplateDragBoundFunc(start_base, 'right', 0)
              $(exportObj).trigger 'xwm:initiateBarrelRoll', [start_base, new exportObj.movements.Decloak
                base: start_base
                where: 'right'
                direction: 'right'
                start_distance_from_front: 0
                end_distance_from_front: 0
              ]

            when 'decloak-rightforward'
              barrelroll_template_layer.dragBoundFunc @makeBarrelRollTemplateDragBoundFunc(start_base, 'right', 0)
              $(exportObj).trigger 'xwm:initiateBarrelRoll', [start_base, new exportObj.movements.Decloak
                base: start_base
                where: 'right'
                direction: 'rightforward'
                start_distance_from_front: 0
                end_distance_from_front: 0
              ]

            when 'decloak-rightbackward'
              barrelroll_template_layer.dragBoundFunc @makeBarrelRollTemplateDragBoundFunc(start_base, 'right', 0)
              $(exportObj).trigger 'xwm:initiateBarrelRoll', [start_base, new exportObj.movements.Decloak
                base: start_base
                where: 'right'
                direction: 'rightbackward'
                start_distance_from_front: 0
                end_distance_from_front: 0
              ]

            else
              throw new Error("Bad direction #{args.direction}")


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

  draw: (layer, options) ->
    if @isVisible
      if options.show_movement_templates
        for template in @templates
          template.show()
      else
        for template in @templates
          template.hide()

      if options.show_final_maneuver_only
        if options.show_movement_templates
          # If we're not showing templates at all, no need to worry.
          # Otherwise, we need to hide all but the last template.
          for template, i in @templates
            if i < @templates.length - 1
              template.hide()

        for base, i in @bases
          if i == @bases.length - 1
            base.show()
          else
            base.hide()
      else
        for base in @bases
          base.show()
    else
      for template in @templates
        template.hide()
      for base in @bases
        base.hide()

    for template in @templates
      template.draw layer, options.kinetic_draw_args
    for base in @bases
      base.draw layer, options.kinetic_draw_args
    this
    
  show: ->
    @isVisible = true
    this

  hide: ->
    @isVisible = false
    this

  addMovement: (movement) ->
    @movements.push movement
    @list_element.find('.executed-movements').append movement.element
    if movement instanceof exportObj.movements.Decloak or movement instanceof exportObj.movements.DecloakForwardLeft or movement instanceof exportObj.movements.DecloakForwardRight
      # decloak always has to go before movement
      @list_element.find('.add-decloak').hide()
    else if movement instanceof exportObj.movements.Boost or movement instanceof exportObj.movements.BoostLeft or movement instanceof exportObj.movements.BoostRight
      @list_element.find('.add-boost').hide()
    else if movement instanceof exportObj.movements.DaredevilLeft or movement instanceof exportObj.movements.DaredevilRight
      @list_element.find('.add-daredevil').hide()
    else if movement instanceof exportObj.movements.BarrelRoll
      @list_element.find('.add-barrel-roll').hide()
    else
      @list_element.find('.add-movement').hide()
      # once you move, you can't decloak
      @list_element.find('.add-decloak').hide()
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

  makeBarrelRollTemplateDragBoundFunc: (base, direction, distance_from_front, isLarge=false) ->
    (pos) ->
      pos.y = Math.min pos.y, base.width - (if isLarge then exportObj.SMALL_BASE_WIDTH else exportObj.TEMPLATE_WIDTH)
      pos.y = Math.max pos.y, 0
      $(exportObj).trigger 'xwm:barrelRollTemplateOffsetChanged', pos.y
      transform = base.getBarrelRollTransform direction, distance_from_front
      drag_pos = transform.point pos
      new_pos = transform.point
        x: pos.x
        y: 0
      {
        x: drag_pos.x - new_pos.x
        y: drag_pos.y - new_pos.y
      }
