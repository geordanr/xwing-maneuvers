// Generated by CoffeeScript 1.6.3
(function() {
  var exportObj;

  exportObj = typeof exports !== "undefined" && exports !== null ? exports : this;

  exportObj.Ship = (function() {
    function Ship(args) {
      var _ref;
      this.name = (_ref = args.name) != null ? _ref : 'Unnamed Ship';
      this.size = args.size;
      this.move_history = [];
    }

    return Ship;

  })();

  exportObj.ShipInstance = (function() {
    function ShipInstance(args) {
      var nub_offset;
      this.ship = args.ship;
      this.width = (function() {
        switch (this.ship.size) {
          case 'small':
            return exportObj.SMALL_BASE_WIDTH;
          case 'large':
            return exportObj.LARGE_BASE_WIDTH;
          default:
            throw new Error("Invalid size " + this.size);
        }
      }).call(this);
      this.group = new Kinetic.Group({
        x: args.x,
        y: args.y,
        offsetX: this.width / 2,
        offsetY: this.width / 2,
        rotation: args.heading_deg
      });
      this.group.add(new Kinetic.Rect({
        x: 0,
        y: 0,
        width: this.width,
        height: this.width,
        stroke: 'black',
        strokeWidth: 1
      }));
      this.group.add(new Kinetic.Line({
        points: [1, 0, this.width / 2, this.width / 2, this.width - 1, 0],
        stroke: 'black',
        strokeWidth: 1
      }));
      nub_offset = exportObj.TEMPLATE_WIDTH / 2;
      this.group.add(new Kinetic.Rect({
        x: (this.width / 2) - nub_offset - 1,
        y: -2,
        width: 1,
        height: 2,
        stroke: 'black',
        strokeWidth: 1
      }));
      this.group.add(new Kinetic.Rect({
        x: (this.width / 2) + nub_offset - 1,
        y: -2,
        width: 1,
        height: 2,
        stroke: 'black',
        strokeWidth: 1
      }));
      this.group.add(new Kinetic.Rect({
        x: (this.width / 2) - nub_offset - 1,
        y: this.width,
        width: 1,
        height: 2,
        stroke: 'black',
        strokeWidth: 1
      }));
      this.group.add(new Kinetic.Rect({
        x: (this.width / 2) + nub_offset - 1,
        y: this.width,
        width: 1,
        height: 2,
        stroke: 'black',
        strokeWidth: 1
      }));
    }

    ShipInstance.prototype.placeTemplate = function(template) {
      template.shape.move(this.group.getTransform().point({
        x: this.width / 2,
        y: 0
      }));
      return template.shape.rotation(this.group.getRotation());
    };

    return ShipInstance;

  })();

}).call(this);

/*
//@ sourceMappingURL=kinetic.map
*/
