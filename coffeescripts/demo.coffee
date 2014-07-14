exportObj = exports ? this

exportObj.demo = (stage) ->
  layer = new Kinetic.Layer()

  ship = new Ship
    stage: stage
    name: 'Phantom'
    size: 'small'
    x: 100
    y: 200
    heading_deg: 112

  ship.addTurn
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

  ship.addTurn
    during: new movements.Turn
      speed: 2
      direction: 'left'

  ship.drawTurns
    stroke: 'blue'
