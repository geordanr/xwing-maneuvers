// Generated by CoffeeScript 1.6.3
(function() {
  var Deprecated, Template, exportObj,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  exportObj = typeof exports !== "undefined" && exports !== null ? exports : this;

  exportObj.templates = {};

  Template = (function() {
    function Template(args) {
      var origin, origin_rotation_deg;
      this.speed = args.speed;
      this.direction = args.direction;
      this.base = args.base;
      this.where = args.where;
      this.shape = this.makeShape();
      switch (this.where) {
        case 'front_nubs':
          origin = this.base.getFrontNubTransform().point({
            x: 0,
            y: 0
          });
          origin_rotation_deg = this.base.getRotation();
          break;
        case 'rear_nubs':
          origin = this.base.getRearNubTransform().point({
            x: 0,
            y: 0
          });
          origin_rotation_deg = (this.base.getRotation() + 180) % 360;
          break;
        case 'left':
          origin = this.base.getBarrelRollTransform('left', args.distance_from_front).point({
            x: 0,
            y: 0
          });
          origin_rotation_deg = (this.base.getRotation() + 270) % 360;
          break;
        case 'right':
          origin = this.base.getBarrelRollTransform('right', args.distance_from_front).point({
            x: 0,
            y: 0
          });
          origin_rotation_deg = (this.base.getRotation() + 90) % 360;
      }
      this.shape.x(origin.x);
      this.shape.y(origin.y);
      this.shape.rotation(origin_rotation_deg);
    }

    Template.prototype.draw = function(layer, args) {
      var _ref, _ref1;
      layer.add(this.shape);
      this.shape.stroke((_ref = args.stroke) != null ? _ref : 'black');
      this.shape.strokeWidth((_ref1 = args.strokeWidth) != null ? _ref1 : 1);
      return this.shape.draw();
    };

    Template.prototype.makeShape = function() {
      throw new Error('Base class; implement me!');
    };

    return Template;

  })();

  exportObj.templates.Straight = (function(_super) {
    __extends(Straight, _super);

    function Straight(args) {
      Straight.__super__.constructor.call(this, args);
    }

    Straight.prototype.makeShape = function() {
      return new Kinetic.Rect({
        offsetX: exportObj.TEMPLATE_WIDTH / 2,
        offsetY: 0,
        width: exportObj.TEMPLATE_WIDTH,
        height: -exportObj.SMALL_BASE_WIDTH * this.speed
      });
    };

    return Straight;

  })(Template);

  exportObj.templates.Koiogran = (function(_super) {
    __extends(Koiogran, _super);

    function Koiogran(args) {
      Koiogran.__super__.constructor.call(this, args);
    }

    return Koiogran;

  })(exportObj.templates.Straight);

  exportObj.templates.Bank = (function(_super) {
    __extends(Bank, _super);

    function Bank(args) {
      Bank.__super__.constructor.call(this, args);
    }

    Bank.prototype.makeShape = function() {
      var dir, dist;
      dir = this.direction;
      dist = this.speed;
      return (function(dir, dist) {
        return new Kinetic.Shape({
          drawFunc: function(ctx) {
            var angle, radius;
            radius = exportObj.BANK_INSIDE_RADII[dist];
            ctx.beginPath();
            switch (dir) {
              case 'left':
                angle = -Math.PI / 4.0;
                ctx.arc(-radius - (exportObj.TEMPLATE_WIDTH / 2), 0, radius, angle, 0);
                ctx.lineTo(exportObj.TEMPLATE_WIDTH / 2, 0);
                ctx.arc(-radius - (exportObj.TEMPLATE_WIDTH / 2), 0, radius + exportObj.TEMPLATE_WIDTH, 0, angle, true);
                break;
              case 'right':
                angle = -3 * Math.PI / 4.0;
                ctx.arc(radius + (exportObj.TEMPLATE_WIDTH / 2), 0, radius, angle, Math.PI, true);
                ctx.lineTo(-exportObj.TEMPLATE_WIDTH / 2, 0);
                ctx.arc(radius + (exportObj.TEMPLATE_WIDTH / 2), 0, radius + exportObj.TEMPLATE_WIDTH, Math.PI, angle);
                break;
              default:
                throw new Error("Invalid direction " + dir);
            }
            ctx.closePath();
            return ctx.strokeShape(this);
          }
        });
      })(dir, dist);
    };

    return Bank;

  })(Template);

  exportObj.templates.Turn = (function(_super) {
    __extends(Turn, _super);

    function Turn(args) {
      Turn.__super__.constructor.call(this, args);
    }

    Turn.prototype.makeShape = function() {
      var dir, dist;
      dir = this.direction;
      dist = this.speed;
      return (function(dir, dist) {
        return new Kinetic.Shape({
          drawFunc: function(ctx) {
            var angle, radius;
            angle = -Math.PI / 2;
            radius = exportObj.TURN_INSIDE_RADII[dist];
            ctx.beginPath();
            switch (dir) {
              case 'left':
                ctx.arc(-radius - (exportObj.TEMPLATE_WIDTH / 2), 0, radius, angle, 0);
                ctx.lineTo(exportObj.TEMPLATE_WIDTH / 2, 0);
                ctx.arc(-radius - (exportObj.TEMPLATE_WIDTH / 2), 0, radius + exportObj.TEMPLATE_WIDTH, 0, angle, true);
                break;
              case 'right':
                ctx.arc(radius + (exportObj.TEMPLATE_WIDTH / 2), 0, radius + exportObj.TEMPLATE_WIDTH, angle, Math.PI, true);
                ctx.lineTo(exportObj.TEMPLATE_WIDTH / 2, 0);
                ctx.arc(radius + (exportObj.TEMPLATE_WIDTH / 2), 0, radius, Math.PI, angle);
                break;
              default:
                throw new Error("Invalid direction " + dir);
            }
            ctx.closePath();
            return ctx.strokeShape(this);
          }
        });
      })(dir, dist);
    };

    return Turn;

  })(Template);

  Deprecated = (function() {
    function Deprecated() {}

    Deprecated.prototype.deprecated_move = function(shipinst) {
      var d, end_center, new_center, rotation, start_center, x_offset;
      rotation = 0;
      start_center = {
        x: shipinst.group.getOffsetX(),
        y: shipinst.group.getOffsetY()
      };
      end_center = (function() {
        switch (this.type) {
          case 'straight':
            return new Kinetic.Transform().translate(0, -this.speed * exportObj.SMALL_BASE_WIDTH - shipinst.width).point(start_center);
          case 'bank':
            switch (this.direction) {
              case 'left':
                d = exportObj.BANK_INSIDE_RADII[this.speed] - ((shipinst.width - exportObj.TEMPLATE_WIDTH) / 2);
                rotation = -45;
                end_center = new Kinetic.Transform().translate(d, -shipinst.width).point(start_center);
                end_center = new Kinetic.Transform().rotate(-Math.PI / 4).point(end_center);
                return end_center = new Kinetic.Transform().translate(-d, 0).point(end_center);
              case 'right':
                d = exportObj.BANK_INSIDE_RADII[this.speed] + ((shipinst.width + exportObj.TEMPLATE_WIDTH) / 2);
                rotation = 45;
                end_center = new Kinetic.Transform().translate(-d, -shipinst.width).point(start_center);
                end_center = new Kinetic.Transform().rotate(Math.PI / 4).point(end_center);
                return end_center = new Kinetic.Transform().translate(d, 0).point(end_center);
              default:
                throw new Error("Invalid direction " + this.direction);
            }
            break;
          case 'turn':
            switch (this.direction) {
              case 'left':
                d = exportObj.TURN_INSIDE_RADII[this.speed] - ((shipinst.width - exportObj.TEMPLATE_WIDTH) / 2);
                rotation = -90;
                end_center = new Kinetic.Transform().translate(d, -shipinst.width).point(start_center);
                end_center = new Kinetic.Transform().rotate(-Math.PI / 2).point(end_center);
                return end_center = new Kinetic.Transform().translate(-d, 0).point(end_center);
              case 'right':
                d = exportObj.TURN_INSIDE_RADII[this.speed] + ((shipinst.width + exportObj.TEMPLATE_WIDTH) / 2);
                rotation = 90;
                end_center = new Kinetic.Transform().translate(-d, -shipinst.width).point(start_center);
                end_center = new Kinetic.Transform().rotate(Math.PI / 2).point(end_center);
                return end_center = new Kinetic.Transform().translate(d, 0).point(end_center);
              default:
                throw new Error("Invalid direction " + this.direction);
            }
            break;
          case 'koiogran':
            rotation = 180;
            end_center = new Kinetic.Transform().translate(-shipinst.group.getOffsetX(), -shipinst.group.getOffsetY()).point(start_center);
            end_center = new Kinetic.Transform().rotate(Math.PI).point(end_center);
            return end_center = new Kinetic.Transform().translate(shipinst.group.getOffsetX(), -shipinst.group.getOffsetY() - (this.speed * exportObj.SMALL_BASE_WIDTH)).point(end_center);
          case 'barrelroll':
            x_offset = ship.width + (this.speed * exportObj.SMALL_BASE_WIDTH);
            switch (this.direction) {
              case 'left':
                return t.translate(-x_offset, -this.end_speed_from_front + this.start_speed_from_front);
              case 'right':
                return t.translate(x_offset, -this.end_speed_from_front + this.start_speed_from_front);
              case 'leftforward':
                t.translate(-ship.width / 2, this.start_speed_from_front - (ship.width / 2) - exportObj.BANK_INSIDE_RADII[this.speed]);
                t.rotate(Math.PI / 4);
                return t.translate(-ship.width / 2, -this.end_speed_from_front + (ship.width / 2) + exportObj.BANK_INSIDE_RADII[this.speed]);
              case 'leftback':
                t.translate(-ship.width / 2, this.start_speed_from_front - (ship.width / 2) + exportObj.TEMPLATE_WIDTH + exportObj.BANK_INSIDE_RADII[this.speed]);
                t.rotate(-Math.PI / 4);
                return t.translate(-ship.width / 2, -exportObj.BANK_INSIDE_RADII[this.speed] - exportObj.TEMPLATE_WIDTH + (ship.width / 2) - this.end_speed_from_front);
              case 'rightforward':
                t.translate(ship.width / 2, this.start_speed_from_front - (ship.width / 2) - exportObj.BANK_INSIDE_RADII[this.speed]);
                t.rotate(-Math.PI / 4);
                return t.translate(ship.width / 2, -this.end_speed_from_front + (ship.width / 2) + exportObj.BANK_INSIDE_RADII[this.speed]);
              case 'rightback':
                t.translate(ship.width / 2, this.start_speed_from_front - (ship.width / 2) + exportObj.TEMPLATE_WIDTH + exportObj.BANK_INSIDE_RADII[this.speed]);
                t.rotate(Math.PI / 4);
                return t.translate(ship.width / 2, -exportObj.BANK_INSIDE_RADII[this.speed] - exportObj.TEMPLATE_WIDTH + (ship.width / 2) - this.end_speed_from_front);
              default:
                throw new Error("Invalid direction " + this.direction);
            }
            break;
          default:
            throw new Error("Invalid template type " + this.type);
        }
      }).call(this);
      if (this.type === 'koiogran') {
        rotation = 180;
      }
      new_center = shipinst.group.getTransform().point(end_center);
      return new ShipInstance({
        ship: shipinst.ship,
        x: new_center.x,
        y: new_center.y,
        heading_deg: shipinst.group.getRotation() + rotation
      });
    };

    return Deprecated;

  })();

}).call(this);

/*
//@ sourceMappingURL=template.map
*/
