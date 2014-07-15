exportObj = exports ? this

class exportObj.ManeuversUI
  constructor: (args) ->
    @stage = args.stage
    @panel = $ args.panel

    @ships = []

    @colorpicker = $(args.colorpicker).ColorPicker
      flat: true
      color: '000000'
      onChange: (hsv, hex, rgb) =>
        @selectedColor = hex

    @shipnameinput = $ @panel.find('.shipname')
    @islargecheckbox = $ @panel.find('.isLarge')
    @shiplistselect = $ @panel.find('.shiplist')

    @addshipbtn = $ @panel.find('.addship')
    @addshipbtn.click (e) =>
      ship = new Ship
        stage: stage
        name: @shipnameinput.val()
        size: if @islargecheckbox.prop('checked') then 'large' else 'small'
        x: @stage.width() / 2
        y: @stage.height() / 2
        heading_deg: 0

      ship.drawAllTurnMovements {stroke: @selectedColor}

      @ships.push ship
      opt = $ document.createElement('OPTION')
      opt.data 'ship', ship
      opt.text(if ship.name != "" then ship.name else "Unnamed Ship")
      @shiplistselect.append opt
