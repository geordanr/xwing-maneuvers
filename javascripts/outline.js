// Generated by CoffeeScript 1.6.3
(function() {
  var exportObj;

  exportObj = typeof exports !== "undefined" && exports !== null ? exports : this;

  exportObj.drawOutlineOn = function(stage) {
    var outlinelayer;
    outlinelayer = new Kinetic.Layer({
      name: 'outline'
    });
    outlinelayer.add(new Kinetic.Rect({
      width: stage.width(),
      height: stage.height(),
      stroke: 'black',
      strokeWidth: 2
    }));
    return stage.add(outlinelayer);
  };

}).call(this);

/*
//@ sourceMappingURL=outline.map
*/
