exportObj = exports ? this

exportObj.drawOutlineOn = (stage) ->
  outlinelayer = new Kinetic.Layer
    name: 'outline'

  outlinelayer.add new Kinetic.Rect
    width: stage.width()
    height: stage.height()
    stroke: 'black'
    strokeWidth: 2

  stage.add outlinelayer
