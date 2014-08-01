exportObj = exports ? this

class exportObj.ManeuversUI
  constructor: (args) ->
    @stage = args.stage
    @panel = $ args.panel

    # for temporarily rendering barrel rolls to drag around
    @barrelroll_template_layer = new Kinetic.Layer
      name: 'barrelroll_template'
      draggable: true
    @stage.add @barrelroll_template_layer
    # for temporarily rendering where the barrel rolling base ends up
    @barrelroll_base_layer = new Kinetic.Layer
      name: 'barrelroll_base'
      draggable: true
    @stage.add @barrelroll_base_layer
    # stores barrel roll info that is being decided
    @barrelroll_movement = null
    @barrelroll_start_base = null

    @ships = []
    @selected_ship = null

    @colorpicker = $(args.colorpicker).ColorPicker
      flat: true
      color: '000000'
      onChange: (hsv, hex, rgb) =>
        @selectedColor = hex

    # The input element shall be the source of truth.
    @headinginput = $ @panel.find('.heading')
    @headinginput.change (e) =>
      @headinginput.val(0) if @headinginput.val() < 0
      @headinginput.val(359) if @headinginput.val() > 359
      if @headinginput.val() != @headingslider.slider('value')
        @headingslider.slider('value', parseInt @headinginput.val())
        $(exportObj).trigger 'xwm:shipRotated', parseInt @headinginput.val()
    @headingslider = @panel.find('.heading-slider').slider
      min: 0
      max: 359
      change: (e, ui) =>
        if parseInt(@headinginput.val()) != @headingslider.slider('value')
          @headinginput.val(@headingslider.slider 'value')
          @headinginput.change()
      slide: (e, ui) =>
        if parseInt(@headinginput.val()) != ui.value
          @headinginput.val(ui.value)
          @headinginput.change()

    @shipnameinput = $ @panel.find('.shipname')
    @islargecheckbox = $ @panel.find('.isLarge')
    @shiplist_element = $ @panel.find('.shiplist')

    @addshipbtn = $ @panel.find('.addship')
    @addshipbtn.click (e) =>
      e.preventDefault()
      ship = new Ship
        stage: stage
        name: @shipnameinput.val()
        size: if @islargecheckbox.prop('checked') then 'large' else 'small'
        x: @stage.width() / 2
        y: @stage.height() / 2
        heading_deg: 0

      ship.setDrawOptions
        kinetic_draw_args:
          stroke: @selectedColor
      ship.draw()

      @addShip ship

    # events

    @panel.find('.lock-template').hide()
    @panel.find('.lock-template').click (e) ->
      # finalize barrel roll position, but still need to get final base position
      e.preventDefault()
      $(exportObj).trigger 'xwm:finalizeBarrelRollTemplate'

    @panel.find('.lock-base').hide()
    @panel.find('.lock-base').click (e) ->
      e.preventDefault()
      $(exportObj).trigger 'xwm:finalizeBarrelRoll'

    @panel.find('.delete-ship').click (e) =>
      e.preventDefault()
      if @selected_ship?
        @selected_ship.destroy()
        @selected_ship = null

    @panel.find('.toggle-deploy').change (e) =>
      e.preventDefault()
      @stage.find('.deployareas').visible $(e.target).prop('checked')

    @panel.find('.toggle-asteroid-area').change (e) =>
      e.preventDefault()
      @stage.find('.asteroidarea').visible $(e.target).prop('checked')

    @panel.find('.toggle-grid').change (e) =>
      e.preventDefault()
      @stage.find('.grid').visible $(e.target).prop('checked')

    @panel.find('.clone-ship').hide()
    @panel.find('.clone-ship').click (e) =>
      $(exportObj).trigger 'xwm:cloneShip', @selected_ship

    @panel.find('.select-none').hide()
    @panel.find('.select-none').click (e) ->
      $(exportObj).trigger 'xwm:shipSelected', null

    $(exportObj).on 'xwm:drawOptionsChanged', (e, options) =>
      for ship in @ships
        ship.setDrawOptions options
        ship.draw()
    .on 'xwm:shipSelected', (e, ship) =>
      if @selected_ship != ship
        if @selected_ship?
          @selected_ship.setDrawOptions
            kinetic_draw_args:
              fill: ''
          @selected_ship.draw()
          @selected_ship.deselect()

        @selected_ship = ship

        if @selected_ship?
          @selected_ship.setDrawOptions
            kinetic_draw_args:
              fill: '#ddd'
          @selected_ship.moveToTop()
          @selected_ship.draw()
          @selected_ship.select()
          @headingslider.slider 'value', @selected_ship.layer.rotation()
        @panel.find('.clone-ship').toggle @selected_ship?
        @panel.find('.select-none').toggle @selected_ship?
    .on 'xwm:shipRotated', (e, heading_deg) =>
      if @selected_ship? and @selected_ship.layer.rotation() != heading_deg
        @selected_ship.layer.rotation heading_deg
        @selected_ship.draw()
        if heading_deg != parseInt(@headinginput.val())
          @headinginput.val heading_deg
          @headingslider.slider 'value', heading_deg
    .on 'xwm:movementClicked', (e, args) =>
      @addMovementToSelectedShipTurn args
      if args.direction.indexOf('barrelroll') != -1 or args.direction.indexOf('decloak-left') != -1 or args.direction.indexOf('decloak-right') != -1
        @panel.find('.lock-template').show()
        @panel.find('.hide-during-barrel-roll').hide()
    .on 'xwm:barrelRollTemplateOffsetChanged', (e, offset) =>
      @barrelroll_start_offset = offset
    .on 'xwm:barrelRollEndBaseOffsetChanged', (e, offset) =>
      @barrelroll_end_offset = offset
    .on 'xwm:finalizeBarrelRollTemplate', (e) =>
      @panel.find('.lock-template').hide()
      @panel.find('.lock-base').show()
      @barrelroll_template_layer.draggable false
      @barrelroll_movement.start_distance_from_front = @barrelroll_start_offset
      barrelroll_end_base = @barrelroll_start_base.newBaseFromMovement @barrelroll_movement
      barrelroll_end_base.draw @barrelroll_base_layer
      @barrelroll_base_layer.dragBoundFunc @makeBarrelRollBaseDragBoundFunc(0)
    .on 'xwm:finalizeBarrelRoll', (e) =>
      @panel.find('.lock-base').hide()
      @panel.find('.hide-during-barrel-roll').show()
      @barrelroll_movement.end_distance_from_front = @barrelroll_end_offset
      @selected_ship.addTurn().addMovement @barrelroll_movement
      @selected_ship.draw()
      @reset_barrelroll_data()
    .on 'xwm:cloneShip', (e, ship) =>
      @addShip ship.clone()

  reset_barrelroll_data: ->
    for layer in [@barrelroll_base_layer, @barrelroll_template_layer]
      layer.draggable true
      layer.x 0
      layer.y 0
      layer.clear()
      layer.destroyChildren()
      layer.moveToTop()
    @barrelroll_movement = null
    @barrelroll_start_base = null
    @barrelroll_start_offset = null
    @barrelroll_end_offset = null

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

  makeBarrelRollBaseDragBoundFunc: (distance_from_front) ->
    {transform, heading_deg} = @barrelroll_movement.getBaseTransformAndHeading @barrelroll_start_base
    do (transform) =>
      (pos) =>
        pos.y = Math.min pos.y, 0
        pos.y = Math.max pos.y, -(@barrelroll_start_base.width - exportObj.TEMPLATE_WIDTH)
        $(exportObj).trigger 'xwm:barrelRollEndBaseOffsetChanged', Math.abs(pos.y)
        drag_pos = transform.point pos
        new_pos = transform.point
          x: pos.x
          y: 0
        {
          x: drag_pos.x - new_pos.x
          y: drag_pos.y - new_pos.y
        }

  addMovementToSelectedShipTurn: (args) ->
    return unless @selected_ship?

    @reset_barrelroll_data()
    # TODO: figure out what base we are modifying
    # for now, use final position
    tmp_bases = @selected_ship.turns[@selected_ship.turns.length-1].bases
    @barrelroll_start_base = tmp_bases[tmp_bases.length-1]

    switch args.direction
      when 'stop'
        # do nothing? should mark it somehow
        ''
      when 'straight'
        @selected_ship.addTurn().addMovement new exportObj.movements.Straight {speed: args.speed}
      when 'bankleft'
        @selected_ship.addTurn().addMovement new exportObj.movements.Bank
          speed: args.speed
          direction: 'left'
      when 'bankright'
        @selected_ship.addTurn().addMovement new exportObj.movements.Bank
          speed: args.speed
          direction: 'right'
      when 'turnleft'
        @selected_ship.addTurn().addMovement new exportObj.movements.Turn
          speed: args.speed
          direction: 'left'
      when 'turnright'
        @selected_ship.addTurn().addMovement new exportObj.movements.Turn
          speed: args.speed
          direction: 'right'
      when 'koiogran'
        @selected_ship.addTurn().addMovement new exportObj.movements.Koiogran {speed: args.speed}
      when 'barrelroll-left'
        if @selected_ship.size == 'large'
          @barrelroll_template_layer.dragBoundFunc @makeBarrelRollTemplateDragBoundFunc(@barrelroll_start_base, 'left', 0, true)
          @barrelroll_movement = new exportObj.movements.LargeBarrelRoll
            base: @barrelroll_start_base
            where: 'left'
            direction: 'left'
            start_distance_from_front: 0
            end_distance_from_front: 0
        else
          @barrelroll_template_layer.dragBoundFunc @makeBarrelRollTemplateDragBoundFunc(@barrelroll_start_base, 'left', 0)
          @barrelroll_movement = new exportObj.movements.BarrelRoll
            base: @barrelroll_start_base
            where: 'left'
            direction: 'left'
            start_distance_from_front: 0
            end_distance_from_front: 0

      when 'barrelroll-leftforward'
        @barrelroll_template_layer.dragBoundFunc @makeBarrelRollTemplateDragBoundFunc(@barrelroll_start_base, 'left', 0)
        @barrelroll_movement = new exportObj.movements.BarrelRoll
          base: @barrelroll_start_base
          where: 'left'
          direction: 'leftforward'
          start_distance_from_front: 0
          end_distance_from_front: 0

      when 'barrelroll-leftbackward'
        @barrelroll_template_layer.dragBoundFunc @makeBarrelRollTemplateDragBoundFunc(@barrelroll_start_base, 'left', 0)
        @barrelroll_movement = new exportObj.movements.BarrelRoll
          base: @barrelroll_start_base
          where: 'left'
          direction: 'leftbackward'
          start_distance_from_front: 0
          end_distance_from_front: 0

      when 'barrelroll-right'
        if @selected_ship.size == 'large'
          @barrelroll_template_layer.dragBoundFunc @makeBarrelRollTemplateDragBoundFunc(@barrelroll_start_base, 'right', 0, true)
          @barrelroll_movement = new exportObj.movements.LargeBarrelRoll
            base: @barrelroll_start_base
            where: 'right'
            direction: 'right'
            start_distance_from_front: 0
            end_distance_from_front: 0
        else
          @barrelroll_template_layer.dragBoundFunc @makeBarrelRollTemplateDragBoundFunc(@barrelroll_start_base, 'right', 0)
          @barrelroll_movement = new exportObj.movements.BarrelRoll
            base: @barrelroll_start_base
            where: 'right'
            direction: 'right'
            start_distance_from_front: 0
            end_distance_from_front: 0

      when 'barrelroll-rightforward'
        @barrelroll_template_layer.dragBoundFunc @makeBarrelRollTemplateDragBoundFunc(@barrelroll_start_base, 'right', 0)
        @barrelroll_movement = new exportObj.movements.BarrelRoll
          base: @barrelroll_start_base
          where: 'right'
          direction: 'rightforward'
          start_distance_from_front: 0
          end_distance_from_front: 0

      when 'barrelroll-rightbackward'
        @barrelroll_template_layer.dragBoundFunc @makeBarrelRollTemplateDragBoundFunc(@barrelroll_start_base, 'right', 0)
        @barrelroll_movement = new exportObj.movements.BarrelRoll
          base: @barrelroll_start_base
          where: 'right'
          direction: 'rightbackward'
          start_distance_from_front: 0
          end_distance_from_front: 0

      when 'decloak-left'
        @barrelroll_template_layer.dragBoundFunc @makeBarrelRollTemplateDragBoundFunc(@barrelroll_start_base, 'left', 0)
        @barrelroll_movement = new exportObj.movements.Decloak
          base: @barrelroll_start_base
          where: 'left'
          direction: 'left'
          start_distance_from_front: 0
          end_distance_from_front: 0

      when 'decloak-leftforward'
        @barrelroll_template_layer.dragBoundFunc @makeBarrelRollTemplateDragBoundFunc(@barrelroll_start_base, 'left', 0)
        @barrelroll_movement = new exportObj.movements.Decloak
          base: @barrelroll_start_base
          where: 'left'
          direction: 'leftforward'
          start_distance_from_front: 0
          end_distance_from_front: 0

      when 'decloak-leftbackward'
        @barrelroll_template_layer.dragBoundFunc @makeBarrelRollTemplateDragBoundFunc(@barrelroll_start_base, 'left', 0)
        @barrelroll_movement = new exportObj.movements.Decloak
          base: @barrelroll_start_base
          where: 'left'
          direction: 'leftbackward'
          start_distance_from_front: 0
          end_distance_from_front: 0

      when 'decloak-right'
        @barrelroll_template_layer.dragBoundFunc @makeBarrelRollTemplateDragBoundFunc(@barrelroll_start_base, 'right', 0)
        @barrelroll_movement = new exportObj.movements.Decloak
          base: @barrelroll_start_base
          where: 'right'
          direction: 'right'
          start_distance_from_front: 0
          end_distance_from_front: 0

      when 'decloak-rightforward'
        @barrelroll_template_layer.dragBoundFunc @makeBarrelRollTemplateDragBoundFunc(@barrelroll_start_base, 'right', 0)
        @barrelroll_movement = new exportObj.movements.Decloak
          base: @barrelroll_start_base
          where: 'right'
          direction: 'rightforward'
          start_distance_from_front: 0
          end_distance_from_front: 0

      when 'decloak-rightbackward'
        @barrelroll_template_layer.dragBoundFunc @makeBarrelRollTemplateDragBoundFunc(@barrelroll_start_base, 'right', 0)
        @barrelroll_movement = new exportObj.movements.Decloak
          base: @barrelroll_start_base
          where: 'right'
          direction: 'rightbackward'
          start_distance_from_front: 0
          end_distance_from_front: 0

      else
        throw new Error("Bad direction #{args.direction}")

    if @barrelroll_movement?
      template = @barrelroll_movement.getTemplateForBase @barrelroll_start_base

      template.draw @barrelroll_template_layer,
        kinetic_draw_args:
          fill: '#666'

    @selected_ship.draw()

  addShip: (ship) ->
    @ships.push ship
    @shiplist_element.append ship.shiplist_element
    @panel.find('.turnlist').append ship.turnlist_element

    $(exportObj).trigger 'xwm:shipSelected', ship
