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

    @headinginput = $ @panel.find('.heading')
    @headinginput.change (e) =>
      @headinginput.val(0) if @headinginput.val() < 0
      @headinginput.val(359) if @headinginput.val() > 359
      if @headinginput.val() != @headingslider.slider('value')
        @headingslider.slider('value', parseInt @headinginput.val())
        if @selected_ship? and @selected_ship.layer.rotation() != @headingslider.slider('value')
          $(exportObj).trigger 'xwm:shipRotated', @headingslider.slider('value')
    @headingslider = @panel.find('.heading-slider').slider
      min: 0
      max: 359
      change: (e, ui) =>
        if parseInt(@headinginput.val()) != @headingslider.slider('value')
          @headinginput.val(@headingslider.slider 'value')
          $(exportObj).trigger 'xwm:shipRotated', @headingslider.slider('value')
      slide: (e, ui) =>
        if @headinginput.val() != ui.value
          @headinginput.val(ui.value)
          $(exportObj).trigger 'xwm:shipRotated', @headingslider.slider('value')

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

      @ships.push ship
      @shiplist_element.append ship.list_element

      $(exportObj).trigger 'xwm:shipSelected', ship

    @panel.find('.lock-template').click (e) ->
      # finalize barrel roll position, but still need to get final base position
      e.preventDefault()
      $(exportObj).trigger 'xwm:finalizeBarrelRollTemplate'

    @panel.find('.lock-base').click (e) ->
      e.preventDefault()
      $(exportObj).trigger 'xwm:finalizeBarrelRoll'

    @panel.find('.delete-ship').click (e) =>
      e.preventDefault()
      if @selected_ship?
        @selected_ship.destroy()
        @selected_ship = null

    # events

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
          @selected_ship.button.removeClass 'btn-primary'

        @selected_ship = ship

        if @selected_ship?
          @selected_ship.setDrawOptions
            kinetic_draw_args:
              fill: '#ddd'
          @selected_ship.moveToTop()
          @selected_ship.draw()
          @selected_ship.select_ship_button.addClass 'btn-primary'
          @headingslider.slider 'value', @selected_ship.layer.rotation()
          @panel.find('.turnlist').text ''
          @panel.find('.turnlist').append @selected_ship.turnlist_element
    .on 'xwm:shipRotated', (e, heading_deg) =>
      if @selected_ship? and @selected_ship.layer.rotation != @headingslider.slider('value')
        @selected_ship.layer.rotation @headingslider.slider('value')
        @selected_ship.draw()
    .on 'xwm:movementClicked', (e, args) =>
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

    .on 'xwm:barrelRollTemplateOffsetChanged', (e, offset) =>
      @barrelroll_start_offset = offset
    .on 'xwm:barrelRollEndBaseOffsetChanged', (e, offset) =>
      @barrelroll_end_offset = offset
    .on 'xwm:finalizeBarrelRollTemplate', (e) =>
      @barrelroll_template_layer.draggable false
      @barrelroll_movement.start_distance_from_front = @barrelroll_start_offset
      barrelroll_end_base = @barrelroll_start_base.newBaseFromMovement @barrelroll_movement
      barrelroll_end_base.draw @barrelroll_base_layer
      @barrelroll_base_layer.dragBoundFunc @makeBarrelRollBaseDragBoundFunc(0)
    .on 'xwm:finalizeBarrelRoll', (e) =>
      @barrelroll_movement.end_distance_from_front = @barrelroll_end_offset
      @selected_ship.addTurn().addMovement @barrelroll_movement
      @selected_ship.draw()
      @reset_barrelroll_data()

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

  makeBarrelRollTemplateDragBoundFunc: (base, direction, distance_from_front) ->
    (pos) ->
      pos.y = Math.min pos.y, base.width - exportObj.TEMPLATE_WIDTH
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

class exportObj.ManeuverGrid
  constructor: (args) ->
    @container = $ args.container

    @makeManeuverGrid()
    @setupHandlers()

  # Stolen and modified from hpanderson's SVG maneuvers for the squad builder
  @makeManeuverIcon: (template, args={}) ->
    color = args.color ? 'black'
    rotate = args.rotate ? null

    if template == 'stop'
      svg = """<rect x="50" y="50" width="100" height="100" style="fill:#{color}" />"""
    else
      outlineColor = "black"

      transform = ""
      switch template
        when 'turnleft'
          # turn left
          linePath = "M160,180 L160,70 80,70"
          trianglePath = "M80,100 V40 L30,70 Z"

        when 'bankleft'
          # bank left
          linePath = "M150,180 S150,120 80,60"
          trianglePath = "M80,100 V40 L30,70 Z"
          transform = "transform='translate(-5 -15) rotate(45 70 90)' "

        when 'straight'
          # straight
          linePath = "M100,180 L100,100 100,80"
          trianglePath = "M70,80 H130 L100,30 Z"

        when 'bankright'
          # bank right
          linePath = "M50,180 S50,120 120,60"
          trianglePath = "M120,100 V40 L170,70 Z"
          transform = "transform='translate(5 -15) rotate(-45 130 90)' "

        when 'turnright'
          # turn right
          linePath = "M40,180 L40,70 120,70"
          trianglePath = "M120,100 V40 L170,70 Z"

        when 'kturn', 'koiogran', 'uturn'
          # k-turn/u-turn
          linePath = "M50,180 L50,100 C50,10 140,10 140,100 L140,120"
          trianglePath = "M170,120 H110 L140,180 Z"

        else
          throw new Error("Invalid movement icon #{template}")

      svg = $.trim """
        <path d='#{trianglePath}' fill='#{color}' stroke-width='5' stroke='#{outlineColor}' #{transform}/>
        <path stroke-width='25' fill='none' stroke='#{outlineColor}' d='#{linePath}' />
        <path stroke-width='15' fill='none' stroke='#{color}' d='#{linePath}' />
      """

    if rotate?
      svg = $.trim """<g transform="rotate(#{parseInt rotate} 100 100)">#{svg}</g>"""

    """<svg xmlns="http://www.w3.org/2000/svg" width="30px" height="30px" viewBox="0 0 200 200">#{svg}</svg>"""

  makeManeuverGrid: ->
    # TODO - customize per ship
    table = '<table class="maneuvergrid">'
    for speed in [5..0]
      table += """<tr class="speed-#{speed}">"""

      table += if speed > 0 and speed < 4
        $.trim """
          <td data-speed="#{speed}" data-direction="turnleft">#{exportObj.ManeuverGrid.makeManeuverIcon 'turnleft'}</td>
          <td data-speed="#{speed}" data-direction="bankleft">#{exportObj.ManeuverGrid.makeManeuverIcon 'bankleft'}</td>
        """
      else
        "<td>&nbsp;</td><td>&nbsp;</td>"

      table += if speed > 0
        $.trim """<td data-speed="#{speed}" data-direction="straight">#{exportObj.ManeuverGrid.makeManeuverIcon 'straight'}</td>"""
      else
        $.trim """<td data-direction="stop">#{exportObj.ManeuverGrid.makeManeuverIcon 'stop'}</td>"""

      table += if speed > 0 and speed < 4
        $.trim """
          <td data-speed="#{speed}" data-direction="bankright">#{exportObj.ManeuverGrid.makeManeuverIcon 'bankright'}</td>
          <td data-speed="#{speed}" data-direction="turnright">#{exportObj.ManeuverGrid.makeManeuverIcon 'turnright'}</td>
        """
      else
        "<td>&nbsp;</td><td>&nbsp;</td>"

      table += if speed > 0
        $.trim """<td data-speed="#{speed}" data-direction="koiogran">#{exportObj.ManeuverGrid.makeManeuverIcon 'kturn'}</td>"""
      else
        "<td>&nbsp;</td>"

    table += $.trim """

      <tr class="nonmaneuver">
        <td>&nbsp;</td>
        <td data-speed="2" data-direction="bankleft">DC #{exportObj.ManeuverGrid.makeManeuverIcon 'bankleft'}</td>
        <td>&nbsp;</td>
        <td data-speed="2" data-direction="bankright">DC #{exportObj.ManeuverGrid.makeManeuverIcon 'bankright'}</td>
        <td>&nbsp;</td>
      </tr>

      <tr class="nonmaneuver">
        <td data-speed="1" data-direction="turnleft">DD #{exportObj.ManeuverGrid.makeManeuverIcon 'turnleft'}</td>
        <td data-speed="1" data-direction="bankleft">B #{exportObj.ManeuverGrid.makeManeuverIcon 'bankleft'}</td>
        <td data-speed="1" data-direction="straight">B #{exportObj.ManeuverGrid.makeManeuverIcon 'straight'}</td>
        <td data-speed="1" data-direction="bankright">B #{exportObj.ManeuverGrid.makeManeuverIcon 'bankright'}</td>
        <td data-speed="1" data-direction="turnright">DD #{exportObj.ManeuverGrid.makeManeuverIcon 'turnright'}</td>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
      </tr>

      <tr class="nonmaneuver">
        <td data-direction="decloak-leftforward">DC #{exportObj.ManeuverGrid.makeManeuverIcon 'bankright', {rotate: -90}}</td>
        <td data-direction="barrelroll-leftforward">BR #{exportObj.ManeuverGrid.makeManeuverIcon 'bankright', {rotate: -90}}</td>
        <td>&nbsp;</td>
        <td data-direction="barrelroll-rightforward">BR #{exportObj.ManeuverGrid.makeManeuverIcon 'bankleft', {rotate: 90}}</td>
        <td data-direction="decloak-rightforward">DC #{exportObj.ManeuverGrid.makeManeuverIcon 'bankleft', {rotate: 90}}</td>
        <td>&nbsp;</td>
      </tr>

      <tr class="nonmaneuver">
        <td data-direction="decloak-left">DC #{exportObj.ManeuverGrid.makeManeuverIcon 'straight', {rotate: -90}}</td>
        <td data-direction="barrelroll-left">BR #{exportObj.ManeuverGrid.makeManeuverIcon 'straight', {rotate: -90}}</td>
        <td>&nbsp;</td>
        <td data-direction="barrelroll-right">BR #{exportObj.ManeuverGrid.makeManeuverIcon 'straight', {rotate: 90}}</td>
        <td data-direction="decloak-right">DC #{exportObj.ManeuverGrid.makeManeuverIcon 'straight', {rotate: 90}}</td>
        <td>&nbsp;</td>
      </tr>

      <tr class="nonmaneuver">
        <td data-speed="2" data-direction="decloak-leftbackward">DC #{exportObj.ManeuverGrid.makeManeuverIcon 'bankleft', {rotate: -90}}</td>
        <td data-speed="1" data-direction="barrelroll-leftbackward">BR #{exportObj.ManeuverGrid.makeManeuverIcon 'bankleft', {rotate: -90}}</td>
        <td>&nbsp;</td>
        <td data-speed="1" data-direction="barrelroll-rightbackward">BR #{exportObj.ManeuverGrid.makeManeuverIcon 'bankright', {rotate: 90}}</td>
        <td data-speed="2" data-direction="decloak-rightbackward">DC #{exportObj.ManeuverGrid.makeManeuverIcon 'bankright', {rotate: 90}}</td>
        <td>&nbsp;</td>
      </tr>
    """

    table += "</table>"

    @container.append table

  setupHandlers: ->
    @container.find('td').click (e) ->
      e.preventDefault()
      $(exportObj).trigger 'xwm:movementClicked',
        direction: $(e.delegateTarget).data 'direction'
        speed: $(e.delegateTarget).data 'speed'
