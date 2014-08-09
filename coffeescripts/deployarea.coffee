exportObj = exports ? this

exportObj.drawDeployAreasOn = (stage) ->
  deploylayer = new Kinetic.Layer
    name: 'deployareas'

  deploylayer.add new Kinetic.Rect
    name: 'northdeploy'
    x: 0
    y: 0
    width: stage.width()
    height: exportObj.RANGE1
    fillGreen: 255
    fillAlpha: 0.1

  deploylayer.add new Kinetic.Rect
    name: 'southdeploy'
    x: 0
    y: stage.height() - exportObj.RANGE1
    width: stage.width()
    height: exportObj.RANGE1
    fillGreen: 255
    fillAlpha: 0.1

  stage.add deploylayer
