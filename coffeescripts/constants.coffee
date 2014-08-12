exportObj = exports ? this

# All measurements here are in mm

exportObj.SMALL_BASE_WIDTH = 40
exportObj.LARGE_BASE_WIDTH = 80

exportObj.TEMPLATE_WIDTH = exportObj.SMALL_BASE_WIDTH / 2

exportObj.BANK_INSIDE_RADII = [
  ''
  75
  122
  173
]

exportObj.TURN_INSIDE_RADII = [
  ''
  27
  52
  79
]

exportObj.RANGE1 = 2.5 * exportObj.SMALL_BASE_WIDTH
exportObj.RANGE2 = 2 * exportObj.RANGE1
exportObj.RANGE3 = 3 * exportObj.RANGE1

exportObj.PRIMARY_FIRING_ARC_DEG = 79
