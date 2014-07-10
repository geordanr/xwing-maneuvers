exportObj = exports ? this

exportObj.demo = (stage) ->
  layer = new Kinetic.Layer()

  ship = new Ship
    stage: stage
    name: 'test'
    size: 'small'

  bigship = new Ship
    stage: stage
    name: 'big'
    size: 'large'

  instances = []

  instances.push new ShipInstance
    ship: ship
    x: 200
    y: 500
    heading_deg: 45

  window.bank = new Template
    type: 'bank'
    distance: 2
    direction: 'right'
  instances[instances.length - 1].placeTemplate bank
  instances.push bank.move instances[instances.length - 1]

  window.turn = new Template
    type: 'turn'
    distance: 3
    direction: 'left'
  instances[instances.length - 1].placeTemplate turn
  instances.push turn.move instances[instances.length - 1]

  window.straight = new Template
    type: 'koiogran'
    distance: 4
  instances[instances.length - 1].placeTemplate straight
  instances.push straight.move instances[instances.length - 1]

  window.bank3 = new Template
    type: 'bank'
    distance: 3
    direction: 'right'
  instances[instances.length - 1].placeTemplate bank3
  instances.push bank3.move instances[instances.length - 1]

  window.rollleft = new Template
    type: 'barrelroll'
    distance: 1
    direction: 'left'
  #instances[instances.length - 1].placeTemplate rollleft
  #instances.push rollleft.move instances[instances.length - 1]

  layer.add bank.shape
  layer.add bank3.shape
  layer.add turn.shape
  layer.add straight.shape

  for inst in instances
    layer.add inst.group

  stage.add layer
