exportObj = exports ? this

class exportObj.ManeuversUI
  constructor: (args) ->
    @stage = args.stage
    @panel = $ args.panel

    # for temporarily rendering barrel rolls to drag around
    @barrelroll_layer = new Kinetic.Layer
      name: 'barrelroll'
      draggable: true
    @stage.add @barrelroll_layer

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
    @shiplist = $ @panel.find('.shiplist')

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

      li = $ document.createElement('li')
      li.addClass 'shipbutton'
      btn = $ document.createElement('BUTTON')
      btn.data 'ship', ship
      ship.button = btn
      btn.text(if ship.name != "" then ship.name else "Unnamed Ship")
      btn.addClass 'btn btn-block'
      do (ship) ->
        btn.click (e) ->
          e.preventDefault()
          $(exportObj).trigger 'xwm:shipSelected', ship
      li.append btn
      @shiplist.append li

      $(exportObj).trigger 'xwm:shipSelected', ship

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
          @selected_ship.button.addClass 'btn-primary'
          @headingslider.slider 'value', @selected_ship.layer.rotation()
    .on 'xwm:shipRotated', (e, heading_deg) =>
      if @selected_ship? and @selected_ship.layer.rotation != @headingslider.slider('value')
        @selected_ship.layer.rotation @headingslider.slider('value')
        @selected_ship.draw()
    .on 'xwm:movementClicked', (e, args) =>
      return unless @selected_ship?

      # TODO: figure out what base we are modifying
      # for now, use final position
      tmp_bases = @selected_ship.turns[@selected_ship.turns.length-1].bases
      tmp_base = tmp_bases[tmp_bases.length-1]

      @barrelroll_layer.x 0
      @barrelroll_layer.y 0
      @barrelroll_layer.clear()
      @barrelroll_layer.destroyChildren()
      @barrelroll_layer.moveToTop()

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
          @barrelroll_layer.dragBoundFunc @makeBarrelRollDragBoundFunc(tmp_base, 'left', 0)
          movement = new exportObj.movements.BarrelRoll
            base: tmp_base
            where: 'left'
            direction: 'left'
            start_distance_from_front: 0
            end_distance_from_front: 0
          template = movement.getTemplateForBase(tmp_base)
          template.draw @barrelroll_layer

        when 'barrelroll-leftforward'
          @barrelroll_layer.dragBoundFunc @makeBarrelRollDragBoundFunc(tmp_base, 'left', 0)
          movement = new exportObj.movements.BarrelRoll
            base: tmp_base
            where: 'left'
            direction: 'leftforward'
            start_distance_from_front: 0
            end_distance_from_front: 0
          template = movement.getTemplateForBase(tmp_base)
          template.draw @barrelroll_layer

        when 'barrelroll-leftbackward'
          @barrelroll_layer.dragBoundFunc @makeBarrelRollDragBoundFunc(tmp_base, 'left', 0)
          movement = new exportObj.movements.BarrelRoll
            base: tmp_base
            where: 'left'
            direction: 'leftbackward'
            start_distance_from_front: 0
            end_distance_from_front: 0
          template = movement.getTemplateForBase(tmp_base)
          template.draw @barrelroll_layer

        when 'barrelroll-right'
          @barrelroll_layer.dragBoundFunc @makeBarrelRollDragBoundFunc(tmp_base, 'right', 0)
          movement = new exportObj.movements.BarrelRoll
            base: tmp_base
            where: 'right'
            direction: 'right'
            start_distance_from_front: 0
            end_distance_from_front: 0
          template = movement.getTemplateForBase(tmp_base)
          template.draw @barrelroll_layer

        when 'barrelroll-rightforward'
          @barrelroll_layer.dragBoundFunc @makeBarrelRollDragBoundFunc(tmp_base, 'right', 0)
          movement = new exportObj.movements.BarrelRoll
            base: tmp_base
            where: 'right'
            direction: 'rightforward'
            start_distance_from_front: 0
            end_distance_from_front: 0
          template = movement.getTemplateForBase(tmp_base)
          template.draw @barrelroll_layer

        when 'barrelroll-rightbackward'
          @barrelroll_layer.dragBoundFunc @makeBarrelRollDragBoundFunc(tmp_base, 'right', 0)
          movement = new exportObj.movements.BarrelRoll
            base: tmp_base
            where: 'right'
            direction: 'rightbackward'
            start_distance_from_front: 0
            end_distance_from_front: 0
          template = movement.getTemplateForBase(tmp_base)
          template.draw @barrelroll_layer

        when 'decloak-left'
          @barrelroll_layer.dragBoundFunc @makeBarrelRollDragBoundFunc(tmp_base, 'left', 0)
          movement = new exportObj.movements.Decloak
            base: tmp_base
            where: 'left'
            direction: 'left'
            start_distance_from_front: 0
            end_distance_from_front: 0
          template = movement.getTemplateForBase(tmp_base)
          template.draw @barrelroll_layer

        when 'decloak-leftforward'
          @barrelroll_layer.dragBoundFunc @makeBarrelRollDragBoundFunc(tmp_base, 'left', 0)
          movement = new exportObj.movements.Decloak
            base: tmp_base
            where: 'left'
            direction: 'leftforward'
            start_distance_from_front: 0
            end_distance_from_front: 0
          template = movement.getTemplateForBase(tmp_base)
          template.draw @barrelroll_layer

        when 'decloak-leftbackward'
          @barrelroll_layer.dragBoundFunc @makeBarrelRollDragBoundFunc(tmp_base, 'left', 0)
          movement = new exportObj.movements.Decloak
            base: tmp_base
            where: 'left'
            direction: 'leftbackward'
            start_distance_from_front: 0
            end_distance_from_front: 0
          template = movement.getTemplateForBase(tmp_base)
          template.draw @barrelroll_layer

        when 'decloak-right'
          @barrelroll_layer.dragBoundFunc @makeBarrelRollDragBoundFunc(tmp_base, 'right', 0)
          movement = new exportObj.movements.Decloak
            base: tmp_base
            where: 'right'
            direction: 'right'
            start_distance_from_front: 0
            end_distance_from_front: 0
          template = movement.getTemplateForBase(tmp_base)
          template.draw @barrelroll_layer

        when 'decloak-rightforward'
          @barrelroll_layer.dragBoundFunc @makeBarrelRollDragBoundFunc(tmp_base, 'right', 0)
          movement = new exportObj.movements.Decloak
            base: tmp_base
            where: 'right'
            direction: 'rightforward'
            start_distance_from_front: 0
            end_distance_from_front: 0
          template = movement.getTemplateForBase(tmp_base)
          template.draw @barrelroll_layer

        when 'decloak-rightbackward'
          @barrelroll_layer.dragBoundFunc @makeBarrelRollDragBoundFunc(tmp_base, 'right', 0)
          movement = new exportObj.movements.Decloak
            base: tmp_base
            where: 'right'
            direction: 'rightbackward'
            start_distance_from_front: 0
            end_distance_from_front: 0
          template = movement.getTemplateForBase(tmp_base)
          template.draw @barrelroll_layer

        else
          throw new Error("Bad direction #{args.direction}")

      @selected_ship.draw()

  makeBarrelRollDragBoundFunc: (base, direction, distance_from_front) ->
    (pos) ->
      pos.y = Math.min pos.y, base.width - exportObj.TEMPLATE_WIDTH
      pos.y = Math.max pos.y, 0
      xform = base.getBarrelRollTransform direction, distance_from_front
      drag_pos = xform.point pos
      new_pos = xform.point
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
  makeManeuverIcon: (template, args={}) ->
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

        when 'kturn'
          # k-turn/u-turn
          linePath = "M50,180 L50,100 C50,10 140,10 140,100 L140,120"
          trianglePath = "M170,120 H110 L140,180 Z"

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
          <td data-speed="#{speed}" data-direction="turnleft">#{@makeManeuverIcon 'turnleft'}</td>
          <td data-speed="#{speed}" data-direction="bankleft">#{@makeManeuverIcon 'bankleft'}</td>
        """
      else
        "<td>&nbsp;</td><td>&nbsp;</td>"

      table += if speed > 0
        $.trim """<td data-speed="#{speed}" data-direction="straight">#{@makeManeuverIcon 'straight'}</td>"""
      else
        $.trim """<td data-direction="stop">#{@makeManeuverIcon 'stop'}</td>"""

      table += if speed > 0 and speed < 4
        $.trim """
          <td data-speed="#{speed}" data-direction="bankright">#{@makeManeuverIcon 'bankright'}</td>
          <td data-speed="#{speed}" data-direction="turnright">#{@makeManeuverIcon 'turnright'}</td>
        """
      else
        "<td>&nbsp;</td><td>&nbsp;</td>"

      table += if speed > 0
        $.trim """<td data-speed="#{speed}" data-direction="koiogran">#{@makeManeuverIcon 'kturn'}</td>"""
      else
        "<td>&nbsp;</td>"

    table += $.trim """

      <tr class="nonmaneuver">
        <td>&nbsp;</td>
        <td data-speed="2" data-direction="bankleft">DC #{@makeManeuverIcon 'bankleft'}</td>
        <td>&nbsp;</td>
        <td data-speed="2" data-direction="bankright">DC #{@makeManeuverIcon 'bankright'}</td>
        <td>&nbsp;</td>
      </tr>

      <tr class="nonmaneuver">
        <td data-speed="1" data-direction="turnleft">DD #{@makeManeuverIcon 'turnleft'}</td>
        <td data-speed="1" data-direction="bankleft">B #{@makeManeuverIcon 'bankleft'}</td>
        <td data-speed="1" data-direction="straight">B #{@makeManeuverIcon 'straight'}</td>
        <td data-speed="1" data-direction="bankright">B #{@makeManeuverIcon 'bankright'}</td>
        <td data-speed="1" data-direction="turnright">DD #{@makeManeuverIcon 'turnright'}</td>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
      </tr>

      <tr class="nonmaneuver">
        <td data-direction="decloak-leftforward">DC #{@makeManeuverIcon 'bankright', {rotate: -90}}</td>
        <td data-direction="barrelroll-leftforward">BR #{@makeManeuverIcon 'bankright', {rotate: -90}}</td>
        <td>&nbsp;</td>
        <td data-direction="barrelroll-rightforward">BR #{@makeManeuverIcon 'bankleft', {rotate: 90}}</td>
        <td data-direction="decloak-rightforward">DC #{@makeManeuverIcon 'bankleft', {rotate: 90}}</td>
        <td>&nbsp;</td>
      </tr>

      <tr class="nonmaneuver">
        <td data-direction="decloak-left">DC #{@makeManeuverIcon 'straight', {rotate: -90}}</td>
        <td data-direction="barrelroll-left">BR #{@makeManeuverIcon 'straight', {rotate: -90}}</td>
        <td>&nbsp;</td>
        <td data-direction="barrelroll-right">BR #{@makeManeuverIcon 'straight', {rotate: 90}}</td>
        <td data-direction="decloak-right">DC #{@makeManeuverIcon 'straight', {rotate: 90}}</td>
        <td>&nbsp;</td>
      </tr>

      <tr class="nonmaneuver">
        <td data-speed="2" data-direction="decloak-leftbackward">DC #{@makeManeuverIcon 'bankleft', {rotate: -90}}</td>
        <td data-speed="1" data-direction="barrelroll-leftbackward">BR #{@makeManeuverIcon 'bankleft', {rotate: -90}}</td>
        <td>&nbsp;</td>
        <td data-speed="1" data-direction="barrelroll-rightbackward">BR #{@makeManeuverIcon 'bankright', {rotate: 90}}</td>
        <td data-speed="2" data-direction="decloak-rightbackward">DC #{@makeManeuverIcon 'bankright', {rotate: 90}}</td>
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
