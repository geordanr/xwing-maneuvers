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
        @selectedColor = "##{hex}"

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
    @maneuvers_element = $ @panel.find('.maneuvers')
    @turnlist_element = $ @panel.find('.turnlist')

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

    @panel.find('.show-when-ship-selected').hide()
    @panel.find('.show-during-barrel-roll').hide()
    @maneuvers_element.hide()

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

    @panel.find('.toggle-deploy').change (e) =>
      e.preventDefault()
      @stage.find('.deployareas').visible $(e.target).prop('checked')

    @panel.find('.toggle-asteroid-area').change (e) =>
      e.preventDefault()
      @stage.find('.asteroidarea').visible $(e.target).prop('checked')

    @panel.find('.toggle-grid').change (e) =>
      e.preventDefault()
      @stage.find('.grid').visible $(e.target).prop('checked')

    @panel.find('.clone-ship').click (e) =>
      $(exportObj).trigger 'xwm:cloneShip', @selected_ship

    @panel.find('.select-none').click (e) ->
      $(exportObj).trigger 'xwm:shipSelected', null

    @panel.find('.add-turn').click (e) =>
      if @selected_ship?
        newturn = @selected_ship.addTurn()
        $(exportObj).trigger 'xwm:turnSelected', newturn

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
        @panel.find('.show-when-ship-selected').toggle @selected_ship?
    .on 'xwm:shipRotated', (e, heading_deg) =>
      if @selected_ship? and @selected_ship.layer.rotation() != heading_deg
        @selected_ship.layer.rotation heading_deg
        @selected_ship.draw()
        if heading_deg != parseInt(@headinginput.val())
          @headinginput.val heading_deg
          @headingslider.slider 'value', heading_deg
    .on 'xwm:movementClicked', (e, args) =>
      @turnlist_element.show()
      @maneuvers_element.hide()
      if args.direction.indexOf('barrelroll') != -1 or args.direction.indexOf('decloak-left') != -1 or args.direction.indexOf('decloak-right') != -1
        @panel.find('.lock-template').show()
        @panel.find('.show-during-barrel-roll').show()
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
      {transform, _heading_deg} = @barrelroll_movement.getBaseTransformAndHeading @barrelroll_start_base
      do (transform) =>
        @barrelroll_base_layer.dragBoundFunc (pos) =>
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
    .on 'xwm:finalizeBarrelRoll', (e) =>
      @panel.find('.lock-base').hide()
      @panel.find('.hide-during-barrel-roll').show()
      @panel.find('.show-during-barrel-roll').hide()
      @barrelroll_movement.end_distance_from_front = @barrelroll_end_offset
      $(exportObj).trigger 'xwm:executeBarrelRoll', @barrelroll_movement
    .on 'xwm:cloneShip', (e, ship) =>
      @addShip ship.clone()
    .on 'xwm:resetBarrelRollData', (e, cb) =>
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
      cb @barrelroll_template_layer
    .on 'xwm:initiateBarrelRoll', (e, start_base, movement) =>
      @barrelroll_start_base = start_base
      @barrelroll_movement = movement
      template = @barrelroll_movement.getTemplateForBase @barrelroll_start_base
      template.draw @barrelroll_template_layer,
        kinetic_draw_args:
          fill: '#666'
    .on 'xwm:showMovementSelections', (e, args) =>
      @turnlist_element.hide()
      @maneuvers_element.find('.movement').show()
      @maneuvers_element.find('.nonmovement').hide()
      @maneuvers_element.show()
    .on 'xwm:showBarrelRollSelections', (e, args) =>
      @turnlist_element.hide()
      @maneuvers_element.find('.movement').hide()
      @maneuvers_element.find('.nonmovement, .nonmovement td').hide()
      @maneuvers_element.find('tr.nonmovement.barrelroll, td.barrelroll').show()
      @maneuvers_element.show()
    .on 'xwm:showDecloakSelections', (e, args) =>
      @turnlist_element.hide()
      @maneuvers_element.find('.movement').hide()
      @maneuvers_element.find('.nonmovement, .nonmovement td').hide()
      @maneuvers_element.find('tr.nonmovement.decloak, td.decloak').show()
      @maneuvers_element.show()
    .on 'xwm:showBoostSelections', (e, args) =>
      @turnlist_element.hide()
      @maneuvers_element.find('.movement').hide()
      @maneuvers_element.find('.nonmovement, .nonmovement td').hide()
      @maneuvers_element.find('tr.nonmovement.boost, td.boost').show()
      @maneuvers_element.show()
    .on 'xwm:showDaredevilSelections', (e, args) =>
      @turnlist_element.hide()
      @maneuvers_element.find('.movement').hide()
      @maneuvers_element.find('.nonmovement, .nonmovement td').hide()
      @maneuvers_element.find('tr.nonmovement.daredevil, td.daredevil').show()
      @maneuvers_element.show()
    .on 'xwm:destroyShip', (e, ship) =>
      idx = @ships.indexOf ship
      if idx != -1
        @ships.splice idx, 1
      $(exportObj).trigger 'xwm:shipSelected', null

  addShip: (ship) ->
    @ships.push ship
    @shiplist_element.append ship.shiplist_element
    @turnlist_element.append ship.turnlist_element

    $(exportObj).trigger 'xwm:shipSelected', ship
