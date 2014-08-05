// Generated by CoffeeScript 1.6.3
(function() {
  var Turn, exportObj;

  exportObj = typeof exports !== "undefined" && exports !== null ? exports : this;

  exportObj.Ship = (function() {
    function Ship(args) {
      var turn, _ref,
        _this = this;
      this.stage = args.stage;
      this.name = $.trim((_ref = args.name) != null ? _ref : "");
      this.size = args.size;
      this.start_position = new exportObj.Position({
        center_x: args.x,
        center_y: args.y,
        heading_deg: args.heading_deg
      });
      if (this.name === "") {
        this.name = "Unnamed Ship";
      }
      this.selected_turn = null;
      this.shiplist_element = $(document.createElement('A'));
      this.shiplist_element.addClass('list-group-item');
      this.shiplist_element.data('ship', this);
      this.shiplist_element.text(this.name);
      this.shiplist_element.click(function(e) {
        e.preventDefault();
        return $(exportObj).trigger('xwm:shipSelected', _this);
      });
      this.shiplist_element.append($.trim("<button type=\"button\" class=\"close remove-turn\"><span aria-hidden=\"true\">&times;</span><span class=\"sr-only\">Close</span></button>"));
      this.shiplist_element.find('.close').click(function(e) {
        e.preventDefault();
        return _this.destroy();
      });
      this.turnlist_element = $(document.createElement('DIV'));
      this.turnlist_element.addClass('list-group');
      this.turnlist_element.sortable({
        update: function(e, ui) {
          var elem;
          _this.turns = [_this.turns[0]].concat((function() {
            var _i, _len, _ref1, _results;
            _ref1 = this.turnlist_element.find('.turn-element');
            _results = [];
            for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
              elem = _ref1[_i];
              _results.push($(elem).data('turn_obj'));
            }
            return _results;
          }).call(_this));
          _this.executeTurns();
          return _this.draw();
        }
      });
      this.turnlist_element.hide();
      this.draw_options = {};
      turn = new Turn({
        ship: this,
        start_position: this.start_position
      });
      turn.execute();
      this.turns = [turn];
      this.layer = new Kinetic.Layer({
        name: "ship",
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
      $(exportObj).on('xwm:shipSelected', function(e, ship) {
        return _this.turnlist_element.toggle(ship === _this);
      });
    }

    Ship.prototype.select = function() {
      return this.shiplist_element.addClass('active');
    };

    Ship.prototype.deselect = function() {
      return this.shiplist_element.removeClass('active');
    };

    Ship.prototype.destroy = function() {
      if (this.shiplist_element != null) {
        this.shiplist_element.remove();
      }
      this.layer.destroyChildren();
      return this.layer.destroy();
    };

    Ship.prototype.addTurn = function(args) {
      var turn;
      turn = new Turn({
        ship: this,
        start_position: this.turns[this.turns.length - 1].final_position
      });
      turn.execute();
      this.turns.push(turn);
      this.turnlist_element.append(turn.list_element);
      return turn;
    };

    Ship.prototype.setDrawOptions = function(args) {
      var _ref, _ref1, _ref2;
      this.draw_options.turns = (_ref = args.turns) != null ? _ref : null;
      this.draw_options.kinetic_draw_args = $.extend(this.draw_options.kinetic_draw_args, (_ref1 = args.kinetic_draw_args) != null ? _ref1 : {});
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

    Ship.prototype.moveToTop = function() {
      return this.layer.moveToTop();
    };

    Ship.prototype.selectTurn = function(turn) {
      if (turn !== this.selected_turn) {
        if (this.selected_turn != null) {
          this.selected_turn.deselect();
        }
        this.selected_turn = turn;
        if (this.selected_turn != null) {
          return this.selected_turn.select();
        }
      }
    };

    Ship.prototype.executeTurns = function() {
      var i, start_position, turn, _i, _len, _ref;
      start_position = this.turns[0].final_position;
      _ref = this.turns;
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        turn = _ref[i];
        turn.setStartPosition(start_position);
        turn.execute();
        start_position = turn.final_position;
      }
      return this;
    };

    Ship.prototype.clone = function() {
      var i, movement, newship, newturn, start_position, turn, _i, _j, _len, _len1, _ref, _ref1;
      start_position = this.turns[0].final_position;
      newship = new exportObj.Ship({
        stage: this.stage,
        name: "Copy of " + this.name,
        size: this.size,
        x: start_position.center_x,
        y: start_position.center_y,
        heading_deg: start_position.heading_deg
      });
      _ref = this.turns;
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        turn = _ref[i];
        if (i > 0) {
          newturn = newship.addTurn();
          _ref1 = turn.movements;
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            movement = _ref1[_j];
            newturn.addMovement(movement.clone());
          }
        }
      }
      return newship;
    };

    return Ship;

  })();

  Turn = (function() {
    function Turn(args) {
      var _this = this;
      this.ship = args.ship;
      this.setStartPosition(args.start_position);
      this.movements = [];
      this.bases = [];
      this.templates = [];
      this.final_position = null;
      this.list_element = $(document.createElement('A'));
      this.list_element.addClass('list-group-item turn-element');
      this.list_element.append($.trim("<button type=\"button\" class=\"close remove-turn\"><span aria-hidden=\"true\">&times;</span><span class=\"sr-only\">Close</span></button>"));
      this.list_element.click(function(e) {
        e.preventDefault();
        return $(exportObj).trigger('xwm:turnSelected', _this);
      });
      this.list_element.find('.remove-turn').click(function(e) {
        e.preventDefault();
        return $(exportObj).trigger('xwm:removeTurn', _this);
      });
      this.list_element.data('turn_obj', this);
      $(exportObj).on('xwm:turnSelected', function(e, turn) {
        return _this.list_element.toggleClass('active', turn === _this);
      }).on('xwm:removeTurn', function(e, turn) {
        turn.destroy();
        _this.ship.executeTurns();
        return _this.ship.draw();
      });
    }

    Turn.prototype.destroy = function() {
      var base, idx, movement, template, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2;
      this.base_at_start = null;
      _ref = this.bases;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        base = _ref[_i];
        base.destroy();
      }
      _ref1 = this.templates;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        template = _ref1[_j];
        template.destroy();
      }
      _ref2 = this.movements;
      for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
        movement = _ref2[_k];
        movement.destroy();
      }
      if (this.list_element != null) {
        this.list_element.remove();
      }
      idx = this.ship.turns.indexOf(this);
      if (idx !== -1) {
        return this.ship.turns.splice(idx, 1);
      }
    };

    Turn.prototype.execute = function() {
      var base, cur_base, movement, new_base, template, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2;
      _ref = this.bases;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        base = _ref[_i];
        base.destroy();
      }
      this.bases = [];
      _ref1 = this.templates;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        template = _ref1[_j];
        template.destroy();
      }
      this.templates = [];
      cur_base = this.base_at_start;
      _ref2 = this.movements;
      for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
        movement = _ref2[_k];
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
      this.movements.push(movement);
      this.list_element.append(movement.element);
      return this.execute();
    };

    Turn.prototype.removeMovement = function(movement) {
      var idx;
      idx = this.movements.indexOf(movement);
      if (idx !== -1) {
        movement = this.movements.splice(idx, 1);
        movement.element.remove();
        return execute();
      }
    };

    Turn.prototype.select = function() {
      return this.list_element.addClass('active');
    };

    Turn.prototype.deselect = function() {
      return this.list_element.removeClass('active');
    };

    Turn.prototype.setStartPosition = function(position) {
      return this.base_at_start = new exportObj.Base({
        size: this.ship.size,
        position: position
      });
    };

    return Turn;

  })();

}).call(this);

/*
//@ sourceMappingURL=ship.map
*/
