// Generated by CoffeeScript 1.6.3
(function() {
  var Turn, exportObj;

  exportObj = typeof exports !== "undefined" && exports !== null ? exports : this;

  exportObj.Ship = (function() {
    function Ship(args) {
      var turn,
        _this = this;
      this.stage = args.stage;
      this.name = args.name;
      this.size = args.size;
      this.start_position = new exportObj.Position({
        center_x: args.x,
        center_y: args.y,
        heading_deg: args.heading_deg
      });
      this.draw_options = {};
      turn = new Turn({
        ship: this,
        start_position: this.start_position
      });
      turn.execute();
      this.turns = [turn];
      this.layer = new Kinetic.Layer({
        draggable: true,
        x: this.start_position.x,
        y: this.start_position.y,
        offset: this.start_position
      });
      this.layer.on('mouseenter', function(e) {
        return document.body.style.cursor = 'move';
      }).on('mouseleave', function(e) {
        return document.body.style.cursor = 'default';
      }).on('click', function(e) {
        return $(exportObj).trigger('xwm:shipSelected', _this);
      });
      this.stage.add(this.layer);
    }

    Ship.prototype.addTurn = function(args) {
      var turn;
      turn = new Turn({
        ship: this,
        start_position: this.turns[this.turns.length - 1].final_position
      });
      turn.execute();
      return this.turns.push(turn);
    };

    Ship.prototype.setDrawOptions = function(args) {
      var _ref, _ref1, _ref2;
      this.draw_options.turns = (_ref = args.turns) != null ? _ref : null;
      this.draw_options.kinetic_draw_args = (_ref1 = args.kinetic_draw_args) != null ? _ref1 : null;
      return this.draw_options.final_positions_only = Boolean((_ref2 = args.final_positions_only) != null ? _ref2 : false);
    };

    Ship.prototype.draw = function() {
      var turn_idx, _i, _j, _len, _ref, _ref1, _ref2, _results, _results1;
      this.layer.clear();
      _ref2 = (_ref = this.draw_options.turns) != null ? _ref : (function() {
        _results1 = [];
        for (var _j = 0, _ref1 = this.turns.length; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; 0 <= _ref1 ? _j++ : _j--){ _results1.push(_j); }
        return _results1;
      }).apply(this);
      _results = [];
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        turn_idx = _ref2[_i];
        if (turn_idx < this.turns.length) {
          if (this.draw_options.final_positions_only) {
            _results.push(this.turns[turn_idx].drawFinalPositionOnly(this.layer, this.draw_options.kinetic_draw_args));
          } else {
            _results.push(this.turns[turn_idx].drawMovements(this.layer, this.draw_options.kinetic_draw_args));
          }
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    return Ship;

  })();

  Turn = (function() {
    function Turn(args) {
      this.ship = args.ship;
      this.base_at_start = new exportObj.Base({
        size: this.ship.size,
        position: args.start_position
      });
      this.movements = [];
      this.bases = [];
      this.templates = [];
      this.final_position = null;
    }

    Turn.prototype.execute = function() {
      var cur_base, movement, new_base, _i, _len, _ref;
      this.bases = [];
      this.templates = [];
      cur_base = this.base_at_start;
      _ref = this.movements;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        movement = _ref[_i];
        if (movement != null) {
          this.templates.push(movement.getTemplateForBase(cur_base));
          new_base = cur_base.newBaseFromMovement(movement);
          this.bases.push(new_base);
          cur_base = new_base;
        }
      }
      if (this.bases.length > 0) {
        return this.final_position = this.bases[this.bases.length - 1].position;
      } else {
        this.bases = [this.base_at_start];
        return this.final_position = this.base_at_start.position;
      }
    };

    Turn.prototype.drawMovements = function(layer, args) {
      var base, template, _i, _j, _len, _len1, _ref, _ref1, _results;
      if (args == null) {
        args = {};
      }
      _ref = this.bases;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        base = _ref[_i];
        base.draw(layer, args);
      }
      _ref1 = this.templates;
      _results = [];
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        template = _ref1[_j];
        _results.push(template.draw(layer, args));
      }
      return _results;
    };

    Turn.prototype.drawFinalPositionOnly = function(layer, args) {
      if (args == null) {
        args = {};
      }
      return this.bases[this.bases.length - 1].draw(layer, args);
    };

    Turn.prototype.addMovement = function(movement) {
      return this.movements.push(movement);
    };

    return Turn;

  })();

}).call(this);

/*
//@ sourceMappingURL=ship.map
*/
