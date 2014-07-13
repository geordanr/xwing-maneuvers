// Generated by CoffeeScript 1.6.3
(function() {
  var exportObj;

  exportObj = typeof exports !== "undefined" && exports !== null ? exports : this;

  exportObj.Base = (function() {
    function Base(args) {
      var nub_offset;
      this.size = args.size;
      this.position = args.position;
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
      if (!(this.position instanceof exportObj.Position)) {
        throw new Error("Position required");
      }
      this.group = new Kinetic.Group({
        x: this.position.center_x,
        y: this.position.center_y,
        offsetX: this.width / 2,
        offsetY: this.width / 2,
        rotation: this.position.heading_deg
      });
      this.group.add(new Kinetic.Rect({
        name: 'base',
        x: 0,
        y: 0,
        width: this.width,
        height: this.width
      }));
      this.group.add(new Kinetic.Line({
        name: 'firing_arc',
        points: [1, 0, this.width / 2, this.width / 2, this.width - 1, 0]
      }));
      nub_offset = exportObj.TEMPLATE_WIDTH / 2;
      this.group.add(new Kinetic.Rect({
        name: 'nub',
        x: (this.width / 2) - nub_offset - 1,
        y: -2,
        width: 1,
        height: 2
      }));
      this.group.add(new Kinetic.Rect({
        name: 'nub',
        x: (this.width / 2) + nub_offset - 1,
        y: -2,
        width: 1,
        height: 2
      }));
      this.group.add(new Kinetic.Rect({
        name: 'nub',
        x: (this.width / 2) - nub_offset - 1,
        y: this.width,
        width: 1,
        height: 2
      }));
      this.group.add(new Kinetic.Rect({
        name: 'nub',
        x: (this.width / 2) + nub_offset - 1,
        y: this.width,
        width: 1,
        height: 2
      }));
    }

    Base.prototype.draw = function(layer, args) {
      var child, _i, _len, _ref, _ref1, _ref2, _results;
      layer.add(this.group);
      _ref = this.group.children;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        child = _ref[_i];
        child.stroke((_ref1 = args.stroke) != null ? _ref1 : 'black');
        child.strokeWidth((_ref2 = args.strokeWidth) != null ? _ref2 : 1);
        _results.push(child.draw());
      }
      return _results;
    };

    Base.prototype.getRotation = function() {
      return this.group.rotation();
    };

    Base.prototype.getFrontNubTransform = function() {
      return this.group.getAbsoluteTransform().copy().translate(this.width / 2, 0);
    };

    Base.prototype.getRearNubTransform = function() {
      return this.group.getAbsoluteTransform().copy().translate(this.width / 2, this.width);
    };

    Base.prototype.getBarrelRollTransform = function(side, distance_from_front) {
      if (distance_from_front > this.width - exportObj.TEMPLATE_WIDTH) {
        throw new Error("Barrel roll template placed too far back (" + distance_from_front + " but base width is " + this.width + ") and template width is " + exportObj.TEMPLATE_WIDTH);
      }
      distance_from_front += exportObj.TEMPLATE_WIDTH / 2;
      switch (side) {
        case 'left':
          return this.group.getAbsoluteTransform().copy().translate(0, distance_from_front);
        case 'right':
          return this.group.getAbsoluteTransform().copy().translate(this.width, distance_from_front);
        default:
          throw new Error("Invalid side " + side);
      }
    };

    return Base;

  })();

}).call(this);

/*
//@ sourceMappingURL=base.map
*/
