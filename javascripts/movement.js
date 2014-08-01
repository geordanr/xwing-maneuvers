// Generated by CoffeeScript 1.6.3
(function() {
  var Movement, exportObj,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  exportObj = typeof exports !== "undefined" && exports !== null ? exports : this;

  exportObj.movements = {};

  Movement = (function() {
    function Movement(args) {
      this.speed = args.speed;
      this.direction = args.direction;
      this.element = $.parseHTML(this.toHTML());
    }

    Movement.prototype.clone = function() {
      return $.extend({}, this, true);
    };

    Movement.prototype.destroy = function() {
      return '';
    };

    Movement.prototype.getBaseTransformAndHeading = function(base) {
      throw new Error('Base class; implement me!');
    };

    Movement.prototype.getTemplateForBase = function(base) {
      throw new Error('Base class; implement me!');
    };

    Movement.prototype.toHTML = function() {
      throw new Error('Base class; implement me!');
    };

    return Movement;

  })();

  exportObj.movements.Straight = (function(_super) {
    __extends(Straight, _super);

    function Straight(args) {
      Straight.__super__.constructor.call(this, args);
    }

    Straight.prototype.getBaseTransformAndHeading = function(base) {
      return {
        transform: base.getFrontNubTransform().translate(0, -this.speed * exportObj.SMALL_BASE_WIDTH - (base.width / 2)),
        heading_deg: base.position.heading_deg
      };
    };

    Straight.prototype.getTemplateForBase = function(base) {
      return new exportObj.templates.Straight({
        speed: this.speed,
        direction: this.direction,
        base: base,
        where: 'front_nubs'
      });
    };

    Straight.prototype.toHTML = function() {
      return "<span class=\"movement\">" + (exportObj.ManeuverGrid.makeManeuverIcon('straight')) + "&nbsp;" + this.speed + "</span>";
    };

    return Straight;

  })(Movement);

  exportObj.movements.Koiogran = (function(_super) {
    __extends(Koiogran, _super);

    function Koiogran(args) {
      Koiogran.__super__.constructor.call(this, args);
    }

    Koiogran.prototype.getBaseTransformAndHeading = function(base) {
      return {
        transform: base.getFrontNubTransform().translate(0, -this.speed * exportObj.SMALL_BASE_WIDTH - (base.width / 2)),
        heading_deg: (base.position.heading_deg + 180) % 360
      };
    };

    Koiogran.prototype.getTemplateForBase = function(base) {
      return new exportObj.templates.Straight({
        speed: this.speed,
        direction: this.direction,
        base: base,
        where: 'front_nubs'
      });
    };

    Koiogran.prototype.toHTML = function() {
      return "<span class=\"movement\">" + (exportObj.ManeuverGrid.makeManeuverIcon('koiogran')) + "&nbsp;" + this.speed + "</span>";
    };

    return Koiogran;

  })(Movement);

  exportObj.movements.Bank = (function(_super) {
    __extends(Bank, _super);

    function Bank(args) {
      Bank.__super__.constructor.call(this, args);
    }

    Bank.prototype.getBaseTransformAndHeading = function(base) {
      var d, rotation, transform;
      switch (this.direction) {
        case 'left':
          d = exportObj.BANK_INSIDE_RADII[this.speed] + (exportObj.TEMPLATE_WIDTH / 2);
          rotation = 315;
          transform = base.getFrontNubTransform().translate(-d, 0).rotate(-Math.PI / 4).translate(d, -base.width / 2);
          break;
        case 'right':
          d = exportObj.BANK_INSIDE_RADII[this.speed] + (exportObj.TEMPLATE_WIDTH / 2);
          rotation = 45;
          transform = base.getFrontNubTransform().translate(d, 0).rotate(Math.PI / 4).translate(-d, -base.width / 2);
          break;
        default:
          throw new Error("Invalid direction " + this.direction);
      }
      return {
        transform: transform,
        heading_deg: (base.position.heading_deg + rotation) % 360
      };
    };

    Bank.prototype.getTemplateForBase = function(base) {
      return new exportObj.templates.Bank({
        speed: this.speed,
        direction: this.direction,
        base: base,
        where: 'front_nubs'
      });
    };

    Bank.prototype.toHTML = function() {
      return "<span class=\"movement\">" + (exportObj.ManeuverGrid.makeManeuverIcon("bank" + this.direction)) + "&nbsp;" + this.speed + "</span>";
    };

    return Bank;

  })(Movement);

  exportObj.movements.Turn = (function(_super) {
    __extends(Turn, _super);

    function Turn(args) {
      Turn.__super__.constructor.call(this, args);
    }

    Turn.prototype.getBaseTransformAndHeading = function(base) {
      var d, rotation, transform;
      switch (this.direction) {
        case 'left':
          d = exportObj.TURN_INSIDE_RADII[this.speed] + (exportObj.TEMPLATE_WIDTH / 2);
          rotation = 270;
          transform = base.getFrontNubTransform().translate(-d, 0).rotate(-Math.PI / 2).translate(d, -base.width / 2);
          break;
        case 'right':
          d = exportObj.TURN_INSIDE_RADII[this.speed] + (exportObj.TEMPLATE_WIDTH / 2);
          rotation = 90;
          transform = base.getFrontNubTransform().translate(d, 0).rotate(Math.PI / 2).translate(-d, -base.width / 2);
          break;
        default:
          throw new Error("Invalid direction " + this.direction);
      }
      return {
        transform: transform,
        heading_deg: (base.position.heading_deg + rotation) % 360
      };
    };

    Turn.prototype.getTemplateForBase = function(base) {
      return new exportObj.templates.Turn({
        speed: this.speed,
        direction: this.direction,
        base: base,
        where: 'front_nubs'
      });
    };

    Turn.prototype.toHTML = function() {
      return "<span class=\"movement\">" + (exportObj.ManeuverGrid.makeManeuverIcon("turn" + this.direction)) + "&nbsp;" + this.speed + "</span>";
    };

    return Turn;

  })(Movement);

  exportObj.movements.BarrelRoll = (function(_super) {
    __extends(BarrelRoll, _super);

    function BarrelRoll(args) {
      BarrelRoll.__super__.constructor.call(this, args);
      if (this.speed == null) {
        this.speed = 1;
      }
      if (args.start_distance_from_front == null) {
        throw new Error('Missing argument start_distance_from_front');
      }
      this.start_distance_from_front = args.start_distance_from_front;
      if (args.end_distance_from_front == null) {
        throw new Error('Missing argument end_distance_from_front');
      }
      this.end_distance_from_front = args.end_distance_from_front;
    }

    BarrelRoll.prototype.getBaseTransformAndHeading = function(base) {
      var d, rotation, transform, x_offset, y_offset;
      x_offset = (this.speed * exportObj.SMALL_BASE_WIDTH) + (base.width / 2);
      y_offset = ((base.width - exportObj.TEMPLATE_WIDTH) / 2) - this.end_distance_from_front;
      switch (this.direction) {
        case 'left':
          rotation = 0;
          transform = base.getBarrelRollTransform(this.direction, this.start_distance_from_front).translate(-x_offset, y_offset);
          break;
        case 'right':
          rotation = 0;
          transform = base.getBarrelRollTransform(this.direction, this.start_distance_from_front).translate(x_offset, y_offset);
          break;
        case 'leftforward':
          d = exportObj.BANK_INSIDE_RADII[this.speed] + (exportObj.TEMPLATE_WIDTH / 2);
          rotation = 45;
          transform = base.getBarrelRollTransform(this.direction, this.start_distance_from_front).translate(0, -d).rotate(Math.PI / 4).translate(-base.width / 2, d + y_offset);
          break;
        case 'leftbackward':
          d = exportObj.BANK_INSIDE_RADII[this.speed] + (exportObj.TEMPLATE_WIDTH / 2);
          rotation = 315;
          transform = base.getBarrelRollTransform(this.direction, this.start_distance_from_front).translate(0, d).rotate(-Math.PI / 4).translate(-base.width / 2, -d + y_offset);
          break;
        case 'rightforward':
          d = exportObj.BANK_INSIDE_RADII[this.speed] + (exportObj.TEMPLATE_WIDTH / 2);
          rotation = 315;
          transform = base.getBarrelRollTransform(this.direction, this.start_distance_from_front).translate(0, -d).rotate(-Math.PI / 4).translate(base.width / 2, d + y_offset);
          break;
        case 'rightbackward':
          d = exportObj.BANK_INSIDE_RADII[this.speed] + (exportObj.TEMPLATE_WIDTH / 2);
          rotation = 45;
          transform = base.getBarrelRollTransform(this.direction, this.start_distance_from_front).translate(0, d).rotate(Math.PI / 4).translate(base.width / 2, -d + y_offset);
          break;
        default:
          throw new Error("Invalid direction " + this.direction);
      }
      return {
        transform: transform,
        heading_deg: (base.getRotation() + rotation) % 360
      };
    };

    BarrelRoll.prototype.getTemplateForBase = function(base) {
      switch (this.direction) {
        case 'left':
        case 'right':
          return new exportObj.templates.Straight({
            speed: this.speed,
            base: base,
            where: this.direction,
            distance_from_front: this.start_distance_from_front
          });
        case 'leftforward':
        case 'rightbackward':
        case 'leftbackward':
        case 'rightforward':
          return new exportObj.templates.Bank({
            speed: this.speed,
            base: base,
            where: this.direction,
            direction: this.direction,
            distance_from_front: this.start_distance_from_front
          });
        default:
          throw new Error("Invalid direction " + this.direction);
      }
    };

    BarrelRoll.prototype.toHTML = function() {
      switch (this.direction) {
        case 'left':
          return "<span class=\"movement\">" + (exportObj.ManeuverGrid.makeManeuverIcon("straight", {
            rotate: -90
          })) + "&nbsp;" + this.speed + "</span>";
        case 'right':
          return "<span class=\"movement\">" + (exportObj.ManeuverGrid.makeManeuverIcon("straight", {
            rotate: 90
          })) + "&nbsp;" + this.speed + "</span>";
        case 'leftforward':
          return "<span class=\"movement\">" + (exportObj.ManeuverGrid.makeManeuverIcon("bankright", {
            rotate: -90
          })) + "&nbsp;" + this.speed + "</span>";
        case 'leftbackward':
          return "<span class=\"movement\">" + (exportObj.ManeuverGrid.makeManeuverIcon("bankleft", {
            rotate: -90
          })) + "&nbsp;" + this.speed + "</span>";
        case 'rightforward':
          return "<span class=\"movement\">" + (exportObj.ManeuverGrid.makeManeuverIcon("bankleft", {
            rotate: 90
          })) + "&nbsp;" + this.speed + "</span>";
        case 'rightbackward':
          return "<span class=\"movement\">" + (exportObj.ManeuverGrid.makeManeuverIcon("bankright", {
            rotate: -90
          })) + "&nbsp;" + this.speed + "</span>";
        default:
          throw new Error("Invalid direction " + this.direction);
      }
    };

    return BarrelRoll;

  })(Movement);

  exportObj.movements.Decloak = (function(_super) {
    __extends(Decloak, _super);

    function Decloak(args) {
      Decloak.__super__.constructor.call(this, args);
      this.speed = 2;
    }

    return Decloak;

  })(exportObj.movements.BarrelRoll);

  exportObj.movements.LargeBarrelRoll = (function(_super) {
    __extends(LargeBarrelRoll, _super);

    function LargeBarrelRoll(args) {
      LargeBarrelRoll.__super__.constructor.call(this, args);
      this.speed = 1;
    }

    LargeBarrelRoll.prototype.getBaseTransformAndHeading = function(base) {
      var rotation, transform, x_offset, y_offset;
      x_offset = exportObj.TEMPLATE_WIDTH + (base.width / 2);
      y_offset = ((base.width - exportObj.SMALL_BASE_WIDTH) / 2) - this.end_distance_from_front;
      switch (this.direction) {
        case 'left':
          rotation = 0;
          transform = base.getLargeBarrelRollTransform(this.direction, this.start_distance_from_front).translate(-x_offset, y_offset);
          break;
        case 'right':
          rotation = 0;
          transform = base.getLargeBarrelRollTransform(this.direction, this.start_distance_from_front).translate(x_offset, y_offset);
          break;
        default:
          throw new Error("Invalid direction " + this.direction);
      }
      return {
        transform: transform,
        heading_deg: (base.getRotation() + rotation) % 360
      };
    };

    LargeBarrelRoll.prototype.getTemplateForBase = function(base) {
      switch (this.direction) {
        case 'left':
        case 'right':
          return new exportObj.templates.Straight({
            speed: this.speed,
            base: base,
            where: "" + this.direction + "large",
            distance_from_front: this.start_distance_from_front
          });
        default:
          throw new Error("Invalid direction " + this.direction);
      }
    };

    return LargeBarrelRoll;

  })(exportObj.movements.BarrelRoll);

}).call(this);

/*
//@ sourceMappingURL=movement.map
*/
