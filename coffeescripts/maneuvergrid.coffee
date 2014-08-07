exportObj = exports ? this

class exportObj.ManeuverGrid
  constructor: (args) ->
    @container = $ args.container

    @makeManeuverGrid()
    @setupHandlers()

  # Stolen and modified from hpanderson's SVG maneuvers for the squad builder
  @makeManeuverIcon: (template, args={}) ->
    color = args.color ? 'black'
    rotate = args.rotate ? null

    if template == 'stop'
      svg = """<rect x="50" y="50" width="100" height="100" style="fill:#{color}" />"""
    else
      outlineColor = "black"

      transform = ""
      switch template
        when 'turnleft'
          # turn left
          linePath = "M160,180 L160,70 80,70"
          trianglePath = "M80,100 V40 L30,70 Z"

        when 'bankleft'
          # bank left
          linePath = "M150,180 S150,120 80,60"
          trianglePath = "M80,100 V40 L30,70 Z"
          transform = "transform='translate(-5 -15) rotate(45 70 90)' "

        when 'straight'
          # straight
          linePath = "M100,180 L100,100 100,80"
          trianglePath = "M70,80 H130 L100,30 Z"

        when 'bankright'
          # bank right
          linePath = "M50,180 S50,120 120,60"
          trianglePath = "M120,100 V40 L170,70 Z"
          transform = "transform='translate(5 -15) rotate(-45 130 90)' "

        when 'turnright'
          # turn right
          linePath = "M40,180 L40,70 120,70"
          trianglePath = "M120,100 V40 L170,70 Z"

        when 'kturn', 'koiogran', 'uturn'
          # k-turn/u-turn
          linePath = "M50,180 L50,100 C50,10 140,10 140,100 L140,120"
          trianglePath = "M170,120 H110 L140,180 Z"

        else
          throw new Error("Invalid movement icon #{template}")

      svg = $.trim """
        <path d='#{trianglePath}' fill='#{color}' stroke-width='5' stroke='#{outlineColor}' #{transform}/>
        <path stroke-width='25' fill='none' stroke='#{outlineColor}' d='#{linePath}' />
        <path stroke-width='15' fill='none' stroke='#{color}' d='#{linePath}' />
      """

    if rotate?
      svg = $.trim """<g transform="rotate(#{parseInt rotate} 100 100)">#{svg}</g>"""

    """<svg xmlns="http://www.w3.org/2000/svg" width="30px" height="30px" viewBox="0 0 200 200">#{svg}</svg>"""

  makeManeuverGrid: ->
    # TODO - customize per ship
    table = '<table class="maneuvergrid">'
    for speed in [5..0]
      table += """<tr class="movement speed-#{speed}">"""

      table += if speed > 0 and speed < 4
        $.trim """
          <td data-speed="#{speed}" data-direction="turnleft">#{exportObj.ManeuverGrid.makeManeuverIcon 'turnleft'}</td>
          <td data-speed="#{speed}" data-direction="bankleft">#{exportObj.ManeuverGrid.makeManeuverIcon 'bankleft'}</td>
        """
      else
        "<td>&nbsp;</td><td>&nbsp;</td>"

      table += if speed > 0
        $.trim """<td data-speed="#{speed}" data-direction="straight">#{exportObj.ManeuverGrid.makeManeuverIcon 'straight'}</td>"""
      else
        $.trim """<td data-direction="stop">#{exportObj.ManeuverGrid.makeManeuverIcon 'stop'}</td>"""

      table += if speed > 0 and speed < 4
        $.trim """
          <td data-speed="#{speed}" data-direction="bankright">#{exportObj.ManeuverGrid.makeManeuverIcon 'bankright'}</td>
          <td data-speed="#{speed}" data-direction="turnright">#{exportObj.ManeuverGrid.makeManeuverIcon 'turnright'}</td>
        """
      else
        "<td>&nbsp;</td><td>&nbsp;</td>"

      table += if speed > 0
        $.trim """<td data-speed="#{speed}" data-direction="koiogran">#{exportObj.ManeuverGrid.makeManeuverIcon 'kturn'}</td>"""
      else
        "<td>&nbsp;</td>"

    table += $.trim """

      <tr class="nonmovement decloak">
        <td>&nbsp;</td>
        <td class="decloak" data-speed="2" data-direction="decloak-forward-left">#{exportObj.ManeuverGrid.makeManeuverIcon 'bankleft'}</td>
        <td>&nbsp;</td>
        <td class="decloak" data-speed="2" data-direction="decloak-forward-right">#{exportObj.ManeuverGrid.makeManeuverIcon 'bankright'}</td>
        <td>&nbsp;</td>
      </tr>

      <tr class="nonmovement daredevil boost">
        <td class="daredevil" data-speed="1" data-direction="daredevil-left">DD #{exportObj.ManeuverGrid.makeManeuverIcon 'turnleft'}</td>
        <td class="boost" data-speed="1" data-direction="boost-left">#{exportObj.ManeuverGrid.makeManeuverIcon 'bankleft'}</td>
        <td class="boost" data-speed="1" data-direction="boost">#{exportObj.ManeuverGrid.makeManeuverIcon 'straight'}</td>
        <td class="boost" data-speed="1" data-direction="boost-right">#{exportObj.ManeuverGrid.makeManeuverIcon 'bankright'}</td>
        <td class="daredevil" data-speed="1" data-direction="daredevil-right">DD #{exportObj.ManeuverGrid.makeManeuverIcon 'turnright'}</td>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
      </tr>

      <tr class="nonmovement decloak barrelroll">
        <td class="decloak" data-direction="decloak-leftforward">#{exportObj.ManeuverGrid.makeManeuverIcon 'bankright', {rotate: -90}}</td>
        <td class="barrelroll" data-direction="barrelroll-leftforward">#{exportObj.ManeuverGrid.makeManeuverIcon 'bankright', {rotate: -90}}</td>
        <td>&nbsp;</td>
        <td class="barrelroll" data-direction="barrelroll-rightforward">#{exportObj.ManeuverGrid.makeManeuverIcon 'bankleft', {rotate: 90}}</td>
        <td class="decloak" data-direction="decloak-rightforward">#{exportObj.ManeuverGrid.makeManeuverIcon 'bankleft', {rotate: 90}}</td>
        <td>&nbsp;</td>
      </tr>

      <tr class="nonmovement decloak barrelroll">
        <td class="decloak" data-direction="decloak-left">#{exportObj.ManeuverGrid.makeManeuverIcon 'straight', {rotate: -90}}</td>
        <td class="barrelroll" data-direction="barrelroll-left">#{exportObj.ManeuverGrid.makeManeuverIcon 'straight', {rotate: -90}}</td>
        <td>&nbsp;</td>
        <td class="barrelroll" data-direction="barrelroll-right">#{exportObj.ManeuverGrid.makeManeuverIcon 'straight', {rotate: 90}}</td>
        <td class="decloak" data-direction="decloak-right">#{exportObj.ManeuverGrid.makeManeuverIcon 'straight', {rotate: 90}}</td>
        <td>&nbsp;</td>
      </tr>

      <tr class="nonmovement decloak barrelroll">
        <td class="decloak" data-speed="2" data-direction="decloak-leftbackward">#{exportObj.ManeuverGrid.makeManeuverIcon 'bankleft', {rotate: -90}}</td>
        <td class="barrelroll" data-speed="1" data-direction="barrelroll-leftbackward">#{exportObj.ManeuverGrid.makeManeuverIcon 'bankleft', {rotate: -90}}</td>
        <td>&nbsp;</td>
        <td class="barrelroll" data-speed="1" data-direction="barrelroll-rightbackward">#{exportObj.ManeuverGrid.makeManeuverIcon 'bankright', {rotate: 90}}</td>
        <td class="decloak" data-speed="2" data-direction="decloak-rightbackward">#{exportObj.ManeuverGrid.makeManeuverIcon 'bankright', {rotate: 90}}</td>
        <td>&nbsp;</td>
      </tr>
    """

    table += "</table>"

    @container.append table

  setupHandlers: ->
    @container.find('td').click (e) ->
      e.preventDefault()
      $(exportObj).trigger 'xwm:movementClicked',
        direction: $(e.delegateTarget).data 'direction'
        speed: $(e.delegateTarget).data 'speed'
