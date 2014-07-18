// Generated by CoffeeScript 1.6.3
(function() {
  var exportObj;

  exportObj = typeof exports !== "undefined" && exports !== null ? exports : this;

  exportObj.ManeuversUI = (function() {
    function ManeuversUI(args) {
      var _this = this;
      this.stage = args.stage;
      this.panel = $(args.panel);
      this.ships = [];
      this.selected_ship = null;
      this.colorpicker = $(args.colorpicker).ColorPicker({
        flat: true,
        color: '000000',
        onChange: function(hsv, hex, rgb) {
          return _this.selectedColor = hex;
        }
      });
      this.headinginput = $(this.panel.find('.heading'));
      this.headinginput.change(function(e) {
        if (_this.headinginput.val() < 0) {
          _this.headinginput.val(0);
        }
        if (_this.headinginput.val() > 359) {
          _this.headinginput.val(359);
        }
        if (_this.headinginput.val() !== _this.headingslider.slider('value')) {
          _this.headingslider.slider('value', parseInt(_this.headinginput.val()));
          if ((_this.selected_ship != null) && _this.selected_ship.layer.rotation() !== _this.headingslider.slider('value')) {
            return $(exportObj).trigger('xwm:shipRotated', _this.headingslider.slider('value'));
          }
        }
      });
      this.headingslider = this.panel.find('.heading-slider').slider({
        min: 0,
        max: 359,
        change: function(e, ui) {
          if (parseInt(_this.headinginput.val()) !== _this.headingslider.slider('value')) {
            _this.headinginput.val(_this.headingslider.slider('value'));
            return $(exportObj).trigger('xwm:shipRotated', _this.headingslider.slider('value'));
          }
        },
        slide: function(e, ui) {
          if (_this.headinginput.val() !== ui.value) {
            _this.headinginput.val(ui.value);
            return $(exportObj).trigger('xwm:shipRotated', _this.headingslider.slider('value'));
          }
        }
      });
      this.shipnameinput = $(this.panel.find('.shipname'));
      this.islargecheckbox = $(this.panel.find('.isLarge'));
      this.shiplist = $(this.panel.find('.shiplist'));
      this.addshipbtn = $(this.panel.find('.addship'));
      this.addshipbtn.click(function(e) {
        var btn, li, ship;
        e.preventDefault();
        ship = new Ship({
          stage: stage,
          name: _this.shipnameinput.val(),
          size: _this.islargecheckbox.prop('checked') ? 'large' : 'small',
          x: _this.stage.width() / 2,
          y: _this.stage.height() / 2,
          heading_deg: 0
        });
        ship.setDrawOptions({
          kinetic_draw_args: {
            stroke: _this.selectedColor
          }
        });
        ship.draw();
        _this.ships.push(ship);
        li = $(document.createElement('li'));
        li.addClass('shipbutton');
        btn = $(document.createElement('BUTTON'));
        btn.data('ship', ship);
        ship.button = btn;
        btn.text(ship.name !== "" ? ship.name : "Unnamed Ship");
        btn.addClass('btn btn-block');
        (function(ship) {
          return btn.click(function(e) {
            e.preventDefault();
            return $(exportObj).trigger('xwm:shipSelected', ship);
          });
        })(ship);
        li.append(btn);
        _this.shiplist.append(li);
        return $(exportObj).trigger('xwm:shipSelected', ship);
      });
      $(exportObj).on('xwm:drawOptionsChanged', function(e, options) {
        var ship, _i, _len, _ref, _results;
        _ref = _this.ships;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          ship = _ref[_i];
          ship.setDrawOptions(options);
          _results.push(ship.draw());
        }
        return _results;
      }).on('xwm:shipSelected', function(e, ship) {
        if (_this.selected_ship !== ship) {
          if (_this.selected_ship != null) {
            _this.selected_ship.setDrawOptions({
              kinetic_draw_args: {
                fill: ''
              }
            });
            _this.selected_ship.draw();
            _this.selected_ship.button.removeClass('btn-primary');
          }
          _this.selected_ship = ship;
          if (_this.selected_ship != null) {
            _this.selected_ship.setDrawOptions({
              kinetic_draw_args: {
                fill: '#ddd'
              }
            });
            _this.selected_ship.moveToTop();
            _this.selected_ship.draw();
            _this.selected_ship.button.addClass('btn-primary');
            return _this.headingslider.slider('value', _this.selected_ship.layer.rotation());
          }
        }
      }).on('xwm:shipRotated', function(e, heading_deg) {
        if ((_this.selected_ship != null) && _this.selected_ship.layer.rotation !== _this.headingslider.slider('value')) {
          _this.selected_ship.layer.rotation(_this.headingslider.slider('value'));
          return _this.selected_ship.draw();
        }
      }).on('xwm:movementClicked', function(e, args) {
        if (_this.selected_ship == null) {
          return;
        }
        switch (args.direction) {
          case 'stop':
            '';
            break;
          case 'straight':
            _this.selected_ship.addTurn().addMovement(new exportObj.movements.Straight({
              speed: args.speed
            }));
            break;
          case 'bankleft':
            _this.selected_ship.addTurn().addMovement(new exportObj.movements.Bank({
              speed: args.speed,
              direction: 'left'
            }));
            break;
          case 'bankright':
            _this.selected_ship.addTurn().addMovement(new exportObj.movements.Bank({
              speed: args.speed,
              direction: 'right'
            }));
            break;
          case 'turnleft':
            _this.selected_ship.addTurn().addMovement(new exportObj.movements.Turn({
              speed: args.speed,
              direction: 'left'
            }));
            break;
          case 'turnright':
            _this.selected_ship.addTurn().addMovement(new exportObj.movements.Turn({
              speed: args.speed,
              direction: 'right'
            }));
            break;
          case 'koiogran':
            _this.selected_ship.addTurn().addMovement(new exportObj.movements.Koiogran({
              speed: args.speed
            }));
            break;
          case 'barrelroll-left':
            _this.selected_ship.addTurn().addMovement(new exportObj.movements.Straight({
              speed: args.speed
            }));
            break;
          case 'barrelroll-right':
            _this.selected_ship.addTurn().addMovement(new exportObj.movements.Straight({
              speed: args.speed
            }));
            break;
          case 'barrelroll-leftforward':
            _this.selected_ship.addTurn().addMovement(new exportObj.movements.Straight({
              speed: args.speed
            }));
            break;
          case 'barrelroll-leftbackward':
            _this.selected_ship.addTurn().addMovement(new exportObj.movements.Straight({
              speed: args.speed
            }));
            break;
          case 'decloak-left':
            _this.selected_ship.addTurn().addMovement(new exportObj.movements.Straight({
              speed: args.speed
            }));
            break;
          case 'decloak-right':
            _this.selected_ship.addTurn().addMovement(new exportObj.movements.Straight({
              speed: args.speed
            }));
            break;
          case 'decloak-leftforward':
            _this.selected_ship.addTurn().addMovement(new exportObj.movements.Straight({
              speed: args.speed
            }));
            break;
          case 'decloak-leftbackward':
            _this.selected_ship.addTurn().addMovement(new exportObj.movements.Straight({
              speed: args.speed
            }));
            break;
          default:
            throw new Error("Bad direction " + args.direction);
        }
        return _this.selected_ship.draw();
      });
    }

    return ManeuversUI;

  })();

  exportObj.ManeuverGrid = (function() {
    function ManeuverGrid(args) {
      this.container = $(args.container);
      this.makeManeuverGrid();
      this.setupHandlers();
    }

    ManeuverGrid.prototype.makeManeuverIcon = function(template, color) {
      var linePath, outlineColor, svg, transform, trianglePath;
      if (color == null) {
        color = 'black';
      }
      if (template === 'stop') {
        svg = "<rect x=\"50\" y=\"50\" width=\"100\" height=\"100\" style=\"fill:" + color + "\" />";
      } else {
        outlineColor = "black";
        transform = "";
        switch (template) {
          case 'turnleft':
            linePath = "M160,180 L160,70 80,70";
            trianglePath = "M80,100 V40 L30,70 Z";
            break;
          case 'bankleft':
            linePath = "M150,180 S150,120 80,60";
            trianglePath = "M80,100 V40 L30,70 Z";
            transform = "transform='translate(-5 -15) rotate(45 70 90)' ";
            break;
          case 'straight':
            linePath = "M100,180 L100,100 100,80";
            trianglePath = "M70,80 H130 L100,30 Z";
            break;
          case 'bankright':
            linePath = "M50,180 S50,120 120,60";
            trianglePath = "M120,100 V40 L170,70 Z";
            transform = "transform='translate(5 -15) rotate(-45 130 90)' ";
            break;
          case 'turnright':
            linePath = "M40,180 L40,70 120,70";
            trianglePath = "M120,100 V40 L170,70 Z";
            break;
          case 'kturn':
            linePath = "M50,180 L50,100 C50,10 140,10 140,100 L140,120";
            trianglePath = "M170,120 H110 L140,180 Z";
        }
        svg = $.trim("<path d='" + trianglePath + "' fill='" + color + "' stroke-width='5' stroke='" + outlineColor + "' " + transform + "/>\n<path stroke-width='25' fill='none' stroke='" + outlineColor + "' d='" + linePath + "' />\n<path stroke-width='15' fill='none' stroke='" + color + "' d='" + linePath + "' />");
      }
      return "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"30px\" height=\"30px\" viewBox=\"0 0 200 200\">" + svg + "</svg>";
    };

    ManeuverGrid.prototype.makeManeuverGrid = function() {
      var speed, table, _i;
      table = '<table class="maneuvergrid">';
      for (speed = _i = 5; _i >= 0; speed = --_i) {
        table += "<tr>";
        table += speed > 0 && speed < 4 ? $.trim("<td data-speed=\"" + speed + "\" data-direction=\"turnleft\">" + (this.makeManeuverIcon('turnleft')) + "</td>\n<td data-speed=\"" + speed + "\" data-direction=\"bankleft\">" + (this.makeManeuverIcon('bankleft')) + "</td>") : "<td>&nbsp;</td><td>&nbsp;</td>";
        table += speed > 0 ? $.trim("<td data-speed=\"" + speed + "\" data-direction=\"straight\">" + (this.makeManeuverIcon('straight')) + "</td>") : $.trim("<td data-direction=\"stop\">" + (this.makeManeuverIcon('stop')) + "</td>");
        table += speed > 0 && speed < 4 ? $.trim("<td data-speed=\"" + speed + "\" data-direction=\"bankright\">" + (this.makeManeuverIcon('bankright')) + "</td>\n<td data-speed=\"" + speed + "\" data-direction=\"turnright\">" + (this.makeManeuverIcon('turnright')) + "</td>") : "<td>&nbsp;</td><td>&nbsp;</td>";
        table += speed > 0 ? $.trim("<td data-speed=\"" + speed + "\" data-direction=\"koiogran\">" + (this.makeManeuverIcon('kturn')) + "</td>") : "<td>&nbsp;</td>";
      }
      table += $.trim("<tr>\n  <td data-direction=\"decloak-leftforward\">DC LF</td>\n  <td data-direction=\"barrelroll-leftforward\">BR LF</td>\n  <td>&nbsp;</td>\n  <td data-direction=\"barrelroll-rightforward\">BR RF</td>\n  <td data-direction=\"decloak-rightforward\">DC RF</td>\n  <td>&nbsp;</td>\n</tr>\n\n<tr>\n  <td data-direction=\"decloak-left\">DC left</td>\n  <td data-direction=\"barrelroll-left\">BR left</td>\n  <td>&nbsp;</td>\n  <td data-direction=\"barrelroll-right\">BR right</td>\n  <td data-direction=\"decloak-right\">DC right</td>\n  <td>&nbsp;</td>\n</tr>\n\n<tr>\n  <td data-speed=\"2\" data-direction=\"decloak-leftbackward\">DC LB</td>\n  <td data-speed=\"1\" data-direction=\"barrelroll-leftbackward\">BR LB</td>\n  <td>&nbsp;</td>\n  <td data-speed=\"1\" data-direction=\"barrelroll-rightbackward\">BR RB</td>\n  <td data-speed=\"2\" data-direction=\"decloak-rightbackward\">DC RB</td>\n  <td>&nbsp;</td>\n</tr>");
      table += "</table>";
      return this.container.append(table);
    };

    ManeuverGrid.prototype.setupHandlers = function() {
      return this.container.find('td').click(function(e) {
        e.preventDefault();
        return $(exportObj).trigger('xwm:movementClicked', {
          direction: $(e.delegateTarget).data('direction'),
          speed: $(e.delegateTarget).data('speed')
        });
      });
    };

    return ManeuverGrid;

  })();

}).call(this);

/*
//@ sourceMappingURL=ui.map
*/
