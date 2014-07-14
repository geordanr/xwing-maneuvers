exportObj = exports ? this

exportObj.demo = (stage) ->
  layer = new Kinetic.Layer()
  stage.add layer

  b1 = new Base
    size: 'small'
    position: new Position
      center_x: 100
      center_y: 200
      heading_deg: 45
  b1.draw layer,
    stroke: 'red'

  args =
    speed: 2
    direction: 'leftforward'
    base: b1
    where: 'left'
    distance_from_front: 10
    start_distance_from_front: 10
    end_distance_from_front: 0

  t = new templates.Bank args
  t.draw layer,
    stroke: 'purple'

  b2 = b1.newBaseFromMovement new movements.BarrelRoll args
  b2.draw layer,
    stroke: 'orange'
