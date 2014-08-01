exportObj = exports ? this

class exportObj.Position
  constructor: (args) ->
    @center_x = args.center_x
    @center_y = args.center_y
    @heading_deg = args.heading_deg

    # convenience
    @x = @center_x
    @y = @center_y

  clone: ->
    $.extend {}, this, true
