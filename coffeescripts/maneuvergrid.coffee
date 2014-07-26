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
      table += """<tr class="speed-#{speed}">"""

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

      <tr class="nonmaneuver">
        <td>&nbsp;</td>
        <td data-speed="2" data-direction="bankleft">DC #{exportObj.ManeuverGrid.makeManeuverIcon 'bankleft'}</td>
        <td>&nbsp;</td>
        <td data-speed="2" data-direction="bankright">DC #{exportObj.ManeuverGrid.makeManeuverIcon 'bankright'}</td>
        <td>&nbsp;</td>
      </tr>

      <tr class="nonmaneuver">
        <td data-speed="1" data-direction="turnleft">DD #{exportObj.ManeuverGrid.makeManeuverIcon 'turnleft'}</td>
        <td data-speed="1" data-direction="bankleft">B #{exportObj.ManeuverGrid.makeManeuverIcon 'bankleft'}</td>
        <td data-speed="1" data-direction="straight">B #{exportObj.ManeuverGrid.makeManeuverIcon 'straight'}</td>
        <td data-speed="1" data-direction="bankright">B #{exportObj.ManeuverGrid.makeManeuverIcon 'bankright'}</td>
        <td data-speed="1" data-direction="turnright">DD #{exportObj.ManeuverGrid.makeManeuverIcon 'turnright'}</td>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
      </tr>

      <tr class="nonmaneuver">
        <td data-direction="decloak-leftforward">DC #{exportObj.ManeuverGrid.makeManeuverIcon 'bankright', {rotate: -90}}</td>
        <td data-direction="barrelroll-leftforward">BR #{exportObj.ManeuverGrid.makeManeuverIcon 'bankright', {rotate: -90}}</td>
        <td>&nbsp;</td>
        <td data-direction="barrelroll-rightforward">BR #{exportObj.ManeuverGrid.makeManeuverIcon 'bankleft', {rotate: 90}}</td>
        <td data-direction="decloak-rightforward">DC #{exportObj.ManeuverGrid.makeManeuverIcon 'bankleft', {rotate: 90}}</td>
        <td>&nbsp;</td>
      </tr>

      <tr class="nonmaneuver">
        <td data-direction="decloak-left">DC #{exportObj.ManeuverGrid.makeManeuverIcon 'straight', {rotate: -90}}</td>
        <td data-direction="barrelroll-left">BR #{exportObj.ManeuverGrid.makeManeuverIcon 'straight', {rotate: -90}}</td>
        <td>&nbsp;</td>
        <td data-direction="barrelroll-right">BR #{exportObj.ManeuverGrid.makeManeuverIcon 'straight', {rotate: 90}}</td>
        <td data-direction="decloak-right">DC #{exportObj.ManeuverGrid.makeManeuverIcon 'straight', {rotate: 90}}</td>
        <td>&nbsp;</td>
      </tr>

      <tr class="nonmaneuver">
        <td data-speed="2" data-direction="decloak-leftbackward">DC #{exportObj.ManeuverGrid.makeManeuverIcon 'bankleft', {rotate: -90}}</td>
        <td data-speed="1" data-direction="barrelroll-leftbackward">BR #{exportObj.ManeuverGrid.makeManeuverIcon 'bankleft', {rotate: -90}}</td>
        <td>&nbsp;</td>
        <td data-speed="1" data-direction="barrelroll-rightbackward">BR #{exportObj.ManeuverGrid.makeManeuverIcon 'bankright', {rotate: 90}}</td>
        <td data-speed="2" data-direction="decloak-rightbackward">DC #{exportObj.ManeuverGrid.makeManeuverIcon 'bankright', {rotate: 90}}</td>
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
