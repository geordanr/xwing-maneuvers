// Generated by CoffeeScript 1.6.3
(function() {
  var exportObj;

  exportObj = typeof exports !== "undefined" && exports !== null ? exports : this;

  exportObj.ManeuversUI = (function() {
    function ManeuversUI(args) {
      var _this = this;
      this.stage = args.stage;
      this.panel = $(args.panel);
      this.barrelroll_template_layer = new Kinetic.Layer({
        name: 'barrelroll_template',
        draggable: true
      });
      this.stage.add(this.barrelroll_template_layer);
      this.barrelroll_base_layer = new Kinetic.Layer({
        name: 'barrelroll_base',
        draggable: true
      });
      this.stage.add(this.barrelroll_base_layer);
      this.barrelroll_movement = null;
      this.barrelroll_start_base = null;
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
      this.panel.find('.lock-template').click(function(e) {
        e.preventDefault();
        return $(exportObj).trigger('xwm:finalizeBarrelRollTemplate');
      });
      this.panel.find('.lock-base').click(function(e) {
        e.preventDefault();
        return $(exportObj).trigger('xwm:finalizeBarrelRoll');
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
        var template, tmp_bases;
        if (_this.selected_ship == null) {
          return;
        }
        _this.reset_barrelroll_data();
        tmp_bases = _this.selected_ship.turns[_this.selected_ship.turns.length - 1].bases;
        _this.barrelroll_start_base = tmp_bases[tmp_bases.length - 1];
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
            _this.barrelroll_template_layer.dragBoundFunc(_this.makeBarrelRollTemplateDragBoundFunc(_this.barrelroll_start_base, 'left', 0));
            _this.barrelroll_movement = new exportObj.movements.BarrelRoll({
              base: _this.barrelroll_start_base,
              where: 'left',
              direction: 'left',
              start_distance_from_front: 0,
              end_distance_from_front: 0
            });
            break;
          case 'barrelroll-leftforward':
            _this.barrelroll_template_layer.dragBoundFunc(_this.makeBarrelRollTemplateDragBoundFunc(_this.barrelroll_start_base, 'left', 0));
            _this.barrelroll_movement = new exportObj.movements.BarrelRoll({
              base: _this.barrelroll_start_base,
              where: 'left',
              direction: 'leftforward',
              start_distance_from_front: 0,
              end_distance_from_front: 0
            });
            break;
          case 'barrelroll-leftbackward':
            _this.barrelroll_template_layer.dragBoundFunc(_this.makeBarrelRollTemplateDragBoundFunc(_this.barrelroll_start_base, 'left', 0));
            _this.barrelroll_movement = new exportObj.movements.BarrelRoll({
              base: _this.barrelroll_start_base,
              where: 'left',
              direction: 'leftbackward',
              start_distance_from_front: 0,
              end_distance_from_front: 0
            });
            break;
          case 'barrelroll-right':
            _this.barrelroll_template_layer.dragBoundFunc(_this.makeBarrelRollTemplateDragBoundFunc(_this.barrelroll_start_base, 'right', 0));
            _this.barrelroll_movement = new exportObj.movements.BarrelRoll({
              base: _this.barrelroll_start_base,
              where: 'right',
              direction: 'right',
              start_distance_from_front: 0,
              end_distance_from_front: 0
            });
            break;
          case 'barrelroll-rightforward':
            _this.barrelroll_template_layer.dragBoundFunc(_this.makeBarrelRollTemplateDragBoundFunc(_this.barrelroll_start_base, 'right', 0));
            _this.barrelroll_movement = new exportObj.movements.BarrelRoll({
              base: _this.barrelroll_start_base,
              where: 'right',
              direction: 'rightforward',
              start_distance_from_front: 0,
              end_distance_from_front: 0
            });
            break;
          case 'barrelroll-rightbackward':
            _this.barrelroll_template_layer.dragBoundFunc(_this.makeBarrelRollTemplateDragBoundFunc(_this.barrelroll_start_base, 'right', 0));
            _this.barrelroll_movement = new exportObj.movements.BarrelRoll({
              base: _this.barrelroll_start_base,
              where: 'right',
              direction: 'rightbackward',
              start_distance_from_front: 0,
              end_distance_from_front: 0
            });
            break;
          case 'decloak-left':
            _this.barrelroll_template_layer.dragBoundFunc(_this.makeBarrelRollTemplateDragBoundFunc(_this.barrelroll_start_base, 'left', 0));
            _this.barrelroll_movement = new exportObj.movements.Decloak({
              base: _this.barrelroll_start_base,
              where: 'left',
              direction: 'left',
              start_distance_from_front: 0,
              end_distance_from_front: 0
            });
            break;
          case 'decloak-leftforward':
            _this.barrelroll_template_layer.dragBoundFunc(_this.makeBarrelRollTemplateDragBoundFunc(_this.barrelroll_start_base, 'left', 0));
            _this.barrelroll_movement = new exportObj.movements.Decloak({
              base: _this.barrelroll_start_base,
              where: 'left',
              direction: 'leftforward',
              start_distance_from_front: 0,
              end_distance_from_front: 0
            });
            break;
          case 'decloak-leftbackward':
            _this.barrelroll_template_layer.dragBoundFunc(_this.makeBarrelRollTemplateDragBoundFunc(_this.barrelroll_start_base, 'left', 0));
            _this.barrelroll_movement = new exportObj.movements.Decloak({
              base: _this.barrelroll_start_base,
              where: 'left',
              direction: 'leftbackward',
              start_distance_from_front: 0,
              end_distance_from_front: 0
            });
            break;
          case 'decloak-right':
            _this.barrelroll_template_layer.dragBoundFunc(_this.makeBarrelRollTemplateDragBoundFunc(_this.barrelroll_start_base, 'right', 0));
            _this.barrelroll_movement = new exportObj.movements.Decloak({
              base: _this.barrelroll_start_base,
              where: 'right',
              direction: 'right',
              start_distance_from_front: 0,
              end_distance_from_front: 0
            });
            break;
          case 'decloak-rightforward':
            _this.barrelroll_template_layer.dragBoundFunc(_this.makeBarrelRollTemplateDragBoundFunc(_this.barrelroll_start_base, 'right', 0));
            _this.barrelroll_movement = new exportObj.movements.Decloak({
              base: _this.barrelroll_start_base,
              where: 'right',
              direction: 'rightforward',
              start_distance_from_front: 0,
              end_distance_from_front: 0
            });
            break;
          case 'decloak-rightbackward':
            _this.barrelroll_template_layer.dragBoundFunc(_this.makeBarrelRollTemplateDragBoundFunc(_this.barrelroll_start_base, 'right', 0));
            _this.barrelroll_movement = new exportObj.movements.Decloak({
              base: _this.barrelroll_start_base,
              where: 'right',
              direction: 'rightbackward',
              start_distance_from_front: 0,
              end_distance_from_front: 0
            });
            break;
          default:
            throw new Error("Bad direction " + args.direction);
        }
        if (_this.barrelroll_movement != null) {
          template = _this.barrelroll_movement.getTemplateForBase(_this.barrelroll_start_base);
          template.draw(_this.barrelroll_template_layer, {
            kinetic_draw_args: {
              fill: '#666'
            }
          });
        }
        return _this.selected_ship.draw();
      }).on('xwm:barrelRollTemplateOffsetChanged', function(e, offset) {
        return _this.barrelroll_start_offset = offset;
      }).on('xwm:barrelRollEndBaseOffsetChanged', function(e, offset) {
        return _this.barrelroll_end_offset = offset;
      }).on('xwm:finalizeBarrelRollTemplate', function(e) {
        var barrelroll_end_base;
        _this.barrelroll_template_layer.draggable(false);
        _this.barrelroll_movement.start_distance_from_front = _this.barrelroll_start_offset;
        barrelroll_end_base = _this.barrelroll_start_base.newBaseFromMovement(_this.barrelroll_movement);
        barrelroll_end_base.draw(_this.barrelroll_base_layer);
        return _this.barrelroll_base_layer.dragBoundFunc(_this.makeBarrelRollBaseDragBoundFunc(0));
      }).on('xwm:finalizeBarrelRoll', function(e) {
        _this.barrelroll_movement.end_distance_from_front = _this.barrelroll_end_offset;
        _this.selected_ship.addTurn().addMovement(_this.barrelroll_movement);
        _this.selected_ship.draw();
        return _this.reset_barrelroll_data();
      });
    }

    ManeuversUI.prototype.reset_barrelroll_data = function() {
      var layer, _i, _len, _ref;
      _ref = [this.barrelroll_base_layer, this.barrelroll_template_layer];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        layer = _ref[_i];
        layer.draggable(true);
        layer.x(0);
        layer.y(0);
        layer.clear();
        layer.destroyChildren();
        layer.moveToTop();
      }
      this.barrelroll_movement = null;
      this.barrelroll_start_base = null;
      this.barrelroll_start_offset = null;
      return this.barrelroll_end_offset = null;
    };

    ManeuversUI.prototype.makeBarrelRollTemplateDragBoundFunc = function(base, direction, distance_from_front) {
      return function(pos) {
        var drag_pos, new_pos, transform;
        pos.y = Math.min(pos.y, base.width - exportObj.TEMPLATE_WIDTH);
        pos.y = Math.max(pos.y, 0);
        $(exportObj).trigger('xwm:barrelRollTemplateOffsetChanged', pos.y);
        transform = base.getBarrelRollTransform(direction, distance_from_front);
        drag_pos = transform.point(pos);
        new_pos = transform.point({
          x: pos.x,
          y: 0
        });
        return {
          x: drag_pos.x - new_pos.x,
          y: drag_pos.y - new_pos.y
        };
      };
    };

    ManeuversUI.prototype.makeBarrelRollBaseDragBoundFunc = function(distance_from_front) {
      var heading_deg, transform, _ref,
        _this = this;
      _ref = this.barrelroll_movement.getBaseTransformAndHeading(this.barrelroll_start_base), transform = _ref.transform, heading_deg = _ref.heading_deg;
      return (function(transform) {
        return function(pos) {
          var drag_pos, new_pos;
          pos.y = Math.min(pos.y, 0);
          pos.y = Math.max(pos.y, -(_this.barrelroll_start_base.width - exportObj.TEMPLATE_WIDTH));
          $(exportObj).trigger('xwm:barrelRollEndBaseOffsetChanged', Math.abs(pos.y));
          drag_pos = transform.point(pos);
          new_pos = transform.point({
            x: pos.x,
            y: 0
          });
          return {
            x: drag_pos.x - new_pos.x,
            y: drag_pos.y - new_pos.y
          };
        };
      })(transform);
    };

    return ManeuversUI;

  })();

  exportObj.ManeuverGrid = (function() {
    function ManeuverGrid(args) {
      this.container = $(args.container);
      this.makeManeuverGrid();
      this.setupHandlers();
    }

    ManeuverGrid.prototype.makeManeuverIcon = function(template, args) {
      var color, linePath, outlineColor, rotate, svg, transform, trianglePath, _ref, _ref1;
      if (args == null) {
        args = {};
      }
      color = (_ref = args.color) != null ? _ref : 'black';
      rotate = (_ref1 = args.rotate) != null ? _ref1 : null;
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
      if (rotate != null) {
        svg = $.trim("<g transform=\"rotate(" + (parseInt(rotate)) + " 100 100)\">" + svg + "</g>");
      }
      return "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"30px\" height=\"30px\" viewBox=\"0 0 200 200\">" + svg + "</svg>";
    };

    ManeuverGrid.prototype.makeManeuverGrid = function() {
      var speed, table, _i;
      table = '<table class="maneuvergrid">';
      for (speed = _i = 5; _i >= 0; speed = --_i) {
        table += "<tr class=\"speed-" + speed + "\">";
        table += speed > 0 && speed < 4 ? $.trim("<td data-speed=\"" + speed + "\" data-direction=\"turnleft\">" + (this.makeManeuverIcon('turnleft')) + "</td>\n<td data-speed=\"" + speed + "\" data-direction=\"bankleft\">" + (this.makeManeuverIcon('bankleft')) + "</td>") : "<td>&nbsp;</td><td>&nbsp;</td>";
        table += speed > 0 ? $.trim("<td data-speed=\"" + speed + "\" data-direction=\"straight\">" + (this.makeManeuverIcon('straight')) + "</td>") : $.trim("<td data-direction=\"stop\">" + (this.makeManeuverIcon('stop')) + "</td>");
        table += speed > 0 && speed < 4 ? $.trim("<td data-speed=\"" + speed + "\" data-direction=\"bankright\">" + (this.makeManeuverIcon('bankright')) + "</td>\n<td data-speed=\"" + speed + "\" data-direction=\"turnright\">" + (this.makeManeuverIcon('turnright')) + "</td>") : "<td>&nbsp;</td><td>&nbsp;</td>";
        table += speed > 0 ? $.trim("<td data-speed=\"" + speed + "\" data-direction=\"koiogran\">" + (this.makeManeuverIcon('kturn')) + "</td>") : "<td>&nbsp;</td>";
      }
      table += $.trim("<tr class=\"nonmaneuver\">\n  <td>&nbsp;</td>\n  <td data-speed=\"2\" data-direction=\"bankleft\">DC " + (this.makeManeuverIcon('bankleft')) + "</td>\n  <td>&nbsp;</td>\n  <td data-speed=\"2\" data-direction=\"bankright\">DC " + (this.makeManeuverIcon('bankright')) + "</td>\n  <td>&nbsp;</td>\n</tr>\n\n<tr class=\"nonmaneuver\">\n  <td data-speed=\"1\" data-direction=\"turnleft\">DD " + (this.makeManeuverIcon('turnleft')) + "</td>\n  <td data-speed=\"1\" data-direction=\"bankleft\">B " + (this.makeManeuverIcon('bankleft')) + "</td>\n  <td data-speed=\"1\" data-direction=\"straight\">B " + (this.makeManeuverIcon('straight')) + "</td>\n  <td data-speed=\"1\" data-direction=\"bankright\">B " + (this.makeManeuverIcon('bankright')) + "</td>\n  <td data-speed=\"1\" data-direction=\"turnright\">DD " + (this.makeManeuverIcon('turnright')) + "</td>\n  <td>&nbsp;</td>\n  <td>&nbsp;</td>\n</tr>\n\n<tr class=\"nonmaneuver\">\n  <td data-direction=\"decloak-leftforward\">DC " + (this.makeManeuverIcon('bankright', {
        rotate: -90
      })) + "</td>\n  <td data-direction=\"barrelroll-leftforward\">BR " + (this.makeManeuverIcon('bankright', {
        rotate: -90
      })) + "</td>\n  <td>&nbsp;</td>\n  <td data-direction=\"barrelroll-rightforward\">BR " + (this.makeManeuverIcon('bankleft', {
        rotate: 90
      })) + "</td>\n  <td data-direction=\"decloak-rightforward\">DC " + (this.makeManeuverIcon('bankleft', {
        rotate: 90
      })) + "</td>\n  <td>&nbsp;</td>\n</tr>\n\n<tr class=\"nonmaneuver\">\n  <td data-direction=\"decloak-left\">DC " + (this.makeManeuverIcon('straight', {
        rotate: -90
      })) + "</td>\n  <td data-direction=\"barrelroll-left\">BR " + (this.makeManeuverIcon('straight', {
        rotate: -90
      })) + "</td>\n  <td>&nbsp;</td>\n  <td data-direction=\"barrelroll-right\">BR " + (this.makeManeuverIcon('straight', {
        rotate: 90
      })) + "</td>\n  <td data-direction=\"decloak-right\">DC " + (this.makeManeuverIcon('straight', {
        rotate: 90
      })) + "</td>\n  <td>&nbsp;</td>\n</tr>\n\n<tr class=\"nonmaneuver\">\n  <td data-speed=\"2\" data-direction=\"decloak-leftbackward\">DC " + (this.makeManeuverIcon('bankleft', {
        rotate: -90
      })) + "</td>\n  <td data-speed=\"1\" data-direction=\"barrelroll-leftbackward\">BR " + (this.makeManeuverIcon('bankleft', {
        rotate: -90
      })) + "</td>\n  <td>&nbsp;</td>\n  <td data-speed=\"1\" data-direction=\"barrelroll-rightbackward\">BR " + (this.makeManeuverIcon('bankright', {
        rotate: 90
      })) + "</td>\n  <td data-speed=\"2\" data-direction=\"decloak-rightbackward\">DC " + (this.makeManeuverIcon('bankright', {
        rotate: 90
      })) + "</td>\n  <td>&nbsp;</td>\n</tr>");
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
