exportObj = exports ? this

exportObj.demo = (stage) ->
  ship = new exportObj.Ship
    size: 'small'
    name: 'Test Ship'
    center_x: 200
    center_y: 300
    heading_deg: 45
    color: 'blue'

  ship.addMovement new exportObj.Movement
    before: null
    during: new exportObj.movements.Straight
      speed: 3
    after: null

  ship.addMovement new exportObj.Movement
    before: new exportObj.movements.Decloak
      direction: 'leftrear'
      start_front_distance: 5
      end_front_distance: 15
    during: new exportObj.movements.Turn
      direction: 'right'
      speed: 1
    after: new exportObj.movements.BarrelRoll
      direction: 'left'

  ship.addMovement new exportObj.Movement
    before: null
    during: new exportObj.movements.Straight
      speed: 5
    after: new exportObj.movements.Bank
      direction: 'left'
      speed: 1

  ship.addMovement new exportObj.Movement
    before: new exportObj.movements.Decloak
      direction: 'straightleft'
    during: new exportObj.movements.Bank
      direction: 'left'
    after: null

  ship.addMovement new exportObj.Movement
    before: new exportObj.movements.BarrelRoll
      direction: 'left'
      start_front_distance: 7
      end_front_distance: 2
    during: new exportObj.movements.Koiogran
      speed: 3
    after: null

  ship.drawMoves
    first: 1
    last: 3
