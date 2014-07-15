exportObj = exports ? this

class exportObj.ManeuversUI
  constructor: (args) ->
    @stage = args.stage
    @panel = $ args.panel

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
      btn.addClass 'btn'
      do (ship) ->
        btn.click (e) ->
          $(exportObj).trigger 'xwm:shipSelected', ship
      li.append btn
      @shiplist.append li

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
          @selected_ship.draw()
          @selected_ship.button.addClass 'btn-primary'
          @headingslider.slider 'value', @selected_ship.layer.rotation()
    .on 'xwm:shipRotated', (e, heading_deg) =>
      if @selected_ship? and @selected_ship.layer.rotation != @headingslider.slider('value')
        @selected_ship.layer.rotation @headingslider.slider('value')
        @selected_ship.draw()
