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
      this.shiplist_element = $(this.panel.find('.shiplist'));
      this.addshipbtn = $(this.panel.find('.addship'));
      this.addshipbtn.click(function(e) {
        var ship;
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
        _this.shiplist_element.append(ship.shiplist_element);
        _this.panel.find('.turnlist').append(ship.turnlist_element);
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
      this.panel.find('.delete-ship').click(function(e) {
        e.preventDefault();
        if (_this.selected_ship != null) {
          _this.selected_ship.destroy();
          return _this.selected_ship = null;
        }
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
            _this.selected_ship.deselect();
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
            _this.selected_ship.select();
            return _this.headingslider.slider('value', _this.selected_ship.layer.rotation());
          }
        }
      }).on('xwm:shipRotated', function(e, heading_deg) {
        if ((_this.selected_ship != null) && _this.selected_ship.layer.rotation !== _this.headingslider.slider('value')) {
          _this.selected_ship.layer.rotation(_this.headingslider.slider('value'));
          return _this.selected_ship.draw();
        }
      }).on('xwm:movementClicked', function(e, args) {
        return _this.addMovementToSelectedShipTurn(args);
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

    ManeuversUI.prototype.addMovementToSelectedShipTurn = function(args) {
      var template, tmp_bases;
      if (this.selected_ship == null) {
        return;
      }
      this.reset_barrelroll_data();
      tmp_bases = this.selected_ship.turns[this.selected_ship.turns.length - 1].bases;
      this.barrelroll_start_base = tmp_bases[tmp_bases.length - 1];
      switch (args.direction) {
        case 'stop':
          '';
          break;
        case 'straight':
          this.selected_ship.addTurn().addMovement(new exportObj.movements.Straight({
            speed: args.speed
          }));
          break;
        case 'bankleft':
          this.selected_ship.addTurn().addMovement(new exportObj.movements.Bank({
            speed: args.speed,
            direction: 'left'
          }));
          break;
        case 'bankright':
          this.selected_ship.addTurn().addMovement(new exportObj.movements.Bank({
            speed: args.speed,
            direction: 'right'
          }));
          break;
        case 'turnleft':
          this.selected_ship.addTurn().addMovement(new exportObj.movements.Turn({
            speed: args.speed,
            direction: 'left'
          }));
          break;
        case 'turnright':
          this.selected_ship.addTurn().addMovement(new exportObj.movements.Turn({
            speed: args.speed,
            direction: 'right'
          }));
          break;
        case 'koiogran':
          this.selected_ship.addTurn().addMovement(new exportObj.movements.Koiogran({
            speed: args.speed
          }));
          break;
        case 'barrelroll-left':
          this.barrelroll_template_layer.dragBoundFunc(this.makeBarrelRollTemplateDragBoundFunc(this.barrelroll_start_base, 'left', 0));
          this.barrelroll_movement = new exportObj.movements.BarrelRoll({
            base: this.barrelroll_start_base,
            where: 'left',
            direction: 'left',
            start_distance_from_front: 0,
            end_distance_from_front: 0
          });
          break;
        case 'barrelroll-leftforward':
          this.barrelroll_template_layer.dragBoundFunc(this.makeBarrelRollTemplateDragBoundFunc(this.barrelroll_start_base, 'left', 0));
          this.barrelroll_movement = new exportObj.movements.BarrelRoll({
            base: this.barrelroll_start_base,
            where: 'left',
            direction: 'leftforward',
            start_distance_from_front: 0,
            end_distance_from_front: 0
          });
          break;
        case 'barrelroll-leftbackward':
          this.barrelroll_template_layer.dragBoundFunc(this.makeBarrelRollTemplateDragBoundFunc(this.barrelroll_start_base, 'left', 0));
          this.barrelroll_movement = new exportObj.movements.BarrelRoll({
            base: this.barrelroll_start_base,
            where: 'left',
            direction: 'leftbackward',
            start_distance_from_front: 0,
            end_distance_from_front: 0
          });
          break;
        case 'barrelroll-right':
          this.barrelroll_template_layer.dragBoundFunc(this.makeBarrelRollTemplateDragBoundFunc(this.barrelroll_start_base, 'right', 0));
          this.barrelroll_movement = new exportObj.movements.BarrelRoll({
            base: this.barrelroll_start_base,
            where: 'right',
            direction: 'right',
            start_distance_from_front: 0,
            end_distance_from_front: 0
          });
          break;
        case 'barrelroll-rightforward':
          this.barrelroll_template_layer.dragBoundFunc(this.makeBarrelRollTemplateDragBoundFunc(this.barrelroll_start_base, 'right', 0));
          this.barrelroll_movement = new exportObj.movements.BarrelRoll({
            base: this.barrelroll_start_base,
            where: 'right',
            direction: 'rightforward',
            start_distance_from_front: 0,
            end_distance_from_front: 0
          });
          break;
        case 'barrelroll-rightbackward':
          this.barrelroll_template_layer.dragBoundFunc(this.makeBarrelRollTemplateDragBoundFunc(this.barrelroll_start_base, 'right', 0));
          this.barrelroll_movement = new exportObj.movements.BarrelRoll({
            base: this.barrelroll_start_base,
            where: 'right',
            direction: 'rightbackward',
            start_distance_from_front: 0,
            end_distance_from_front: 0
          });
          break;
        case 'decloak-left':
          this.barrelroll_template_layer.dragBoundFunc(this.makeBarrelRollTemplateDragBoundFunc(this.barrelroll_start_base, 'left', 0));
          this.barrelroll_movement = new exportObj.movements.Decloak({
            base: this.barrelroll_start_base,
            where: 'left',
            direction: 'left',
            start_distance_from_front: 0,
            end_distance_from_front: 0
          });
          break;
        case 'decloak-leftforward':
          this.barrelroll_template_layer.dragBoundFunc(this.makeBarrelRollTemplateDragBoundFunc(this.barrelroll_start_base, 'left', 0));
          this.barrelroll_movement = new exportObj.movements.Decloak({
            base: this.barrelroll_start_base,
            where: 'left',
            direction: 'leftforward',
            start_distance_from_front: 0,
            end_distance_from_front: 0
          });
          break;
        case 'decloak-leftbackward':
          this.barrelroll_template_layer.dragBoundFunc(this.makeBarrelRollTemplateDragBoundFunc(this.barrelroll_start_base, 'left', 0));
          this.barrelroll_movement = new exportObj.movements.Decloak({
            base: this.barrelroll_start_base,
            where: 'left',
            direction: 'leftbackward',
            start_distance_from_front: 0,
            end_distance_from_front: 0
          });
          break;
        case 'decloak-right':
          this.barrelroll_template_layer.dragBoundFunc(this.makeBarrelRollTemplateDragBoundFunc(this.barrelroll_start_base, 'right', 0));
          this.barrelroll_movement = new exportObj.movements.Decloak({
            base: this.barrelroll_start_base,
            where: 'right',
            direction: 'right',
            start_distance_from_front: 0,
            end_distance_from_front: 0
          });
          break;
        case 'decloak-rightforward':
          this.barrelroll_template_layer.dragBoundFunc(this.makeBarrelRollTemplateDragBoundFunc(this.barrelroll_start_base, 'right', 0));
          this.barrelroll_movement = new exportObj.movements.Decloak({
            base: this.barrelroll_start_base,
            where: 'right',
            direction: 'rightforward',
            start_distance_from_front: 0,
            end_distance_from_front: 0
          });
          break;
        case 'decloak-rightbackward':
          this.barrelroll_template_layer.dragBoundFunc(this.makeBarrelRollTemplateDragBoundFunc(this.barrelroll_start_base, 'right', 0));
          this.barrelroll_movement = new exportObj.movements.Decloak({
            base: this.barrelroll_start_base,
            where: 'right',
            direction: 'rightbackward',
            start_distance_from_front: 0,
            end_distance_from_front: 0
          });
          break;
        default:
          throw new Error("Bad direction " + args.direction);
      }
      if (this.barrelroll_movement != null) {
        template = this.barrelroll_movement.getTemplateForBase(this.barrelroll_start_base);
        template.draw(this.barrelroll_template_layer, {
          kinetic_draw_args: {
            fill: '#666'
          }
        });
      }
      return this.selected_ship.draw();
    };

    return ManeuversUI;

  })();

}).call(this);

/*
//@ sourceMappingURL=ui.map
*/
