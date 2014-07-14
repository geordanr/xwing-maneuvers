exportObj = exports ? this

exportObj.demo = (stage) ->
  layer = new Kinetic.Layer()

  phantom = new Ship
    stage: stage
    name: 'Phantom'
    size: 'small'
    x: 100
    y: 200
    heading_deg: 112

  falcon = new Ship
    stage: stage
    name: 'Falcon'
    size: 'large'
    x: 750
    y: 600
    heading_deg: 300

  phantom.addTurn
    before: new movements.Decloak
      direction: 'leftforward'
      start_distance_from_front: 7
      end_distance_from_front: 14
    during: new movements.Straight
      speed: 3
    after: new movements.BarrelRoll
      direction: 'right'
      start_distance_from_front: 20
      end_distance_from_front: 0

  falcon.addTurn
    during: new movements.Bank
      direction: 'right'
      speed: 3
    after: new movements.Bank
      direction: 'left'
      speed: 1

  falcon.addTurn
    during: new movements.Bank
      direction: 'left'
      speed: 3
    after: new movements.BarrelRoll
      direction: 'right'
      speed: 1
      start_distance_from_front: 0
      end_distance_from_front: 60

  phantom.addTurn
    during: new movements.Turn
      speed: 2
      direction: 'left'

  falcon.drawTurns
    stroke: 'red'

  phantom.drawTurns
    stroke: 'blue'
