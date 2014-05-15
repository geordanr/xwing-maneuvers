// Generated by CoffeeScript 1.6.3
(function() {
  var exportObj;

  exportObj = typeof exports !== "undefined" && exports !== null ? exports : this;

  exportObj.NORTH = 0;

  exportObj.EAST = Math.PI / 2;

  exportObj.SOUTH = Math.PI;

  exportObj.WEST = -Math.PI / 2;

  exportObj.Template = (function() {
    function Template(args) {
      this.type = args.type;
      this.distance = args.distance;
      this.direction = args.direction;
    }

    Template.prototype.transformShip = function(ship) {
      ship.ctx.translate(0, -ship.width / 2);
      switch (this.type) {
        case 'straight':
          ship.ctx.translate(0, -this.distance * SMALL_BASE_WIDTH);
          break;
        case 'bank':
          switch (this.direction) {
            case 'left':
              ship.ctx.translate(-(exportObj.BANK_INSIDE_RADII[this.distance] + (exportObj.TEMPLATE_WIDTH / 2)), 0);
              ship.ctx.rotate(-Math.PI / 4);
              ship.ctx.translate(exportObj.BANK_INSIDE_RADII[this.distance] + (exportObj.TEMPLATE_WIDTH / 2), 0);
              break;
            case 'right':
              ship.ctx.translate(exportObj.BANK_INSIDE_RADII[this.distance] + (exportObj.TEMPLATE_WIDTH / 2), 0);
              ship.ctx.rotate(Math.PI / 4);
              ship.ctx.translate(-(exportObj.BANK_INSIDE_RADII[this.distance] + (exportObj.TEMPLATE_WIDTH / 2)), 0);
              break;
            default:
              throw new Error("Invalid direction " + this.direction);
          }
          break;
        case 'turn':
          switch (this.direction) {
            case 'left':
              ship.ctx.translate(-(exportObj.TURN_INSIDE_RADII[this.distance] + (exportObj.TEMPLATE_WIDTH / 2)), 0);
              ship.ctx.rotate(-Math.PI / 2);
              ship.ctx.translate(exportObj.TURN_INSIDE_RADII[this.distance] + (exportObj.TEMPLATE_WIDTH / 2), 0);
              break;
            case 'right':
              ship.ctx.translate(exportObj.TURN_INSIDE_RADII[this.distance] + (exportObj.TEMPLATE_WIDTH / 2), 0);
              ship.ctx.rotate(Math.PI / 2);
              ship.ctx.translate(-(exportObj.TURN_INSIDE_RADII[this.distance] + (exportObj.TEMPLATE_WIDTH / 2)), 0);
              break;
            default:
              throw new Error("Invalid direction " + this.direction);
          }
          break;
        case 'koiogran':
          '';
          break;
        default:
          throw new Error("Invalid template type " + this.type);
      }
      return ship.ctx.translate(0, -ship.width / 2);
    };

    return Template;

  })();

  exportObj.STRAIGHT1 = new exportObj.Template({
    type: 'straight',
    distance: 1
  });

  exportObj.STRAIGHT2 = new exportObj.Template({
    type: 'straight',
    distance: 2
  });

  exportObj.STRAIGHT3 = new exportObj.Template({
    type: 'straight',
    distance: 3
  });

  exportObj.STRAIGHT4 = new exportObj.Template({
    type: 'straight',
    distance: 4
  });

  exportObj.BANKLEFT1 = new exportObj.Template({
    type: 'bank',
    direction: 'left',
    distance: 1
  });

  exportObj.BANKLEFT2 = new exportObj.Template({
    type: 'bank',
    direction: 'left',
    distance: 2
  });

  exportObj.BANKLEFT3 = new exportObj.Template({
    type: 'bank',
    direction: 'left',
    distance: 3
  });

  exportObj.BANKRIGHT1 = new exportObj.Template({
    type: 'bank',
    direction: 'right',
    distance: 1
  });

  exportObj.BANKRIGHT2 = new exportObj.Template({
    type: 'bank',
    direction: 'right',
    distance: 2
  });

  exportObj.BANKRIGHT3 = new exportObj.Template({
    type: 'bank',
    direction: 'right',
    distance: 3
  });

  exportObj.TURNLEFT1 = new exportObj.Template({
    type: 'turn',
    direction: 'left',
    distance: 1
  });

  exportObj.TURNLEFT2 = new exportObj.Template({
    type: 'turn',
    direction: 'left',
    distance: 2
  });

  exportObj.TURNLEFT3 = new exportObj.Template({
    type: 'turn',
    direction: 'left',
    distance: 3
  });

  exportObj.TURNRIGHT1 = new exportObj.Template({
    type: 'turn',
    direction: 'right',
    distance: 1
  });

  exportObj.TURNRIGHT2 = new exportObj.Template({
    type: 'turn',
    direction: 'right',
    distance: 2
  });

  exportObj.TURNRIGHT3 = new exportObj.Template({
    type: 'turn',
    direction: 'right',
    distance: 3
  });

  exportObj.Movement = (function() {
    function Movement(args) {
      this.before = args.before;
      this.template = args.template;
      this.after = args.after;
    }

    return Movement;

  })();

  exportObj.Ship = (function() {
    function Ship(args) {
      var _ref, _ref1, _ref2;
      this.name = args.name;
      this.size = args.size;
      this.ctx = args.ctx;
      this.center_x = (_ref = args.center_x) != null ? _ref : 0;
      this.center_y = (_ref1 = args.center_y) != null ? _ref1 : 0;
      this.heading_radians = (_ref2 = args.heading_radians) != null ? _ref2 : exportObj.NORTH;
      this.width = (function() {
        switch (this.size) {
          case 'small':
            return exportObj.SMALL_BASE_WIDTH;
          case 'large':
            return exportObj.LARGE_BASE_WIDTH;
          default:
            throw new Error("Invalid size " + this.size);
        }
      }).call(this);
      this.move_history = [];
    }

    Ship.prototype.addMove = function(movement) {
      return this.move_history.push(movement);
    };

    Ship.prototype.drawMovements = function() {
      var e, movement, _i, _len, _ref, _results;
      this.ctx.save();
      exportObj.transformToCenterAndHeading(this.ctx, this.width, this.center_x, this.center_y, this.heading_radians);
      this.draw();
      try {
        _ref = this.move_history;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          movement = _ref[_i];
          this.placeTemplate(movement.template);
          movement.template.transformShip(this);
          _results.push(this.draw());
        }
        return _results;
      } catch (_error) {
        e = _error;
        throw e;
      } finally {
        this.ctx.restore();
      }
    };

    Ship.prototype.draw = function() {
      switch (this.size) {
        case 'small':
          return exportObj.drawSmallBase(this.ctx);
        case 'large':
          return exportObj.drawLargeBase(this.ctx);
        default:
          throw new Error("Invalid size " + this.size);
      }
    };

    Ship.prototype.placeTemplate = function(template) {
      var e;
      this.ctx.save();
      try {
        exportObj.translateToNubsFromCenter(this.ctx, this.width);
        switch (template.type) {
          case 'straight':
          case 'koiogran':
            return exportObj.drawStraight(this.ctx, template.distance);
          case 'bank':
            return exportObj.drawBank(this.ctx, template.distance, template.direction);
          case 'turn':
            return exportObj.drawTurn(this.ctx, template.distance, template.direction);
          default:
            throw new Error("Invalid template type " + template.type);
        }
      } catch (_error) {
        e = _error;
        throw e;
      } finally {
        this.ctx.restore();
      }
    };

    return Ship;

  })();

}).call(this);

/*
//@ sourceMappingURL=ship.map
*/
