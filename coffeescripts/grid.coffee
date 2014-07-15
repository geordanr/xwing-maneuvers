exportObj = exports ? this

exportObj.drawGridOn = (stage) ->
  gridlayer = new Kinetic.Layer()
  for x in [0..stage.width()] by 25
    strokeWidth = if x % 100 == 0 then 3 else 1
    gridlayer.add new Kinetic.Line
      points: [
        x, 0
        x, stage.height()
      ]
      stroke: 'cyan'
      strokeWidth: strokeWidth
  for y in [0..stage.height()] by 25
    strokeWidth = if y % 100 == 0 then 3 else 1
    gridlayer.add new Kinetic.Line
      points: [
        0, y
        stage.width(), y
      ]
      stroke: 'cyan'
      strokeWidth: strokeWidth
  stage.add gridlayer
