exportObj = exports ? this

exportObj.drawGridOn = (stage) ->
  gridlayer = new Kinetic.Layer
    name: 'grid'
  for x in [0..stage.width()] by exportObj.SMALL_BASE_WIDTH / 2
    strokeWidth = if x % exportObj.LARGE_BASE_WIDTH == 0 then 3 else 1
    gridlayer.add new Kinetic.Line
      points: [
        x, 0
        x, stage.height()
      ]
      strokeAlpha: 0.25
      strokeBlue: 255
      strokeWidth: strokeWidth
  for y in [0..stage.height()] by exportObj.SMALL_BASE_WIDTH / 2
    strokeWidth = if y % exportObj.LARGE_BASE_WIDTH == 0 then 3 else 1
    gridlayer.add new Kinetic.Line
      points: [
        0, y
        stage.width(), y
      ]
      strokeAlpha: 0.25
      strokeBlue: 255
      strokeWidth: strokeWidth
  stage.add gridlayer
