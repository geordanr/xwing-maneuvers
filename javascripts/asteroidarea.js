// Generated by CoffeeScript 1.6.3
(function() {
  var exportObj;

  exportObj = typeof exports !== "undefined" && exports !== null ? exports : this;

  exportObj.drawAsteroidAreaOn = function(stage) {
    var asteroidlayer;
    asteroidlayer = new Kinetic.Layer({
      name: 'asteroidarea'
    });
    asteroidlayer.add(new Kinetic.Rect({
      x: exportObj.RANGE2,
      y: exportObj.RANGE2,
      width: stage.width() - 2 * exportObj.RANGE2,
      height: stage.height() - 2 * exportObj.RANGE2,
      fill: '#eee',
      fillAlpha: 0.1
    }));
    return stage.add(asteroidlayer);
  };

}).call(this);

/*
//@ sourceMappingURL=asteroidarea.map
*/
