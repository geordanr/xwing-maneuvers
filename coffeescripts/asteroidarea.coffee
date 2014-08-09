exportObj = exports ? this

exportObj.drawAsteroidAreaOn = (stage) ->
  asteroidlayer = new Kinetic.Layer
    name: 'asteroidarea'

  asteroidlayer.add new Kinetic.Rect
    x: exportObj.RANGE2
    y: exportObj.RANGE2
    width: stage.width() - 2 * exportObj.RANGE2
    height: stage.height() - 2 * exportObj.RANGE2
    fillRed: 1
    fillGreen: 1
    fillBlue: 1
    fillAlpha: 0.1

  stage.add asteroidlayer
