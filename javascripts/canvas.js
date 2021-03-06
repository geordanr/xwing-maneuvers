// Generated by CoffeeScript 1.6.3
(function() {
  var exportObj;

  exportObj = typeof exports !== "undefined" && exports !== null ? exports : this;

  exportObj.SMALL_BASE_WIDTH = 40;

  exportObj.LARGE_BASE_WIDTH = 80;

  exportObj.TEMPLATE_WIDTH = exportObj.SMALL_BASE_WIDTH / 2;

  exportObj.BANK_INSIDE_RADII = ['', 75, 122, 173];

  exportObj.TURN_INSIDE_RADII = ['', 27, 52, 79];

  exportObj.init = function(ctx) {
    return ctx.lineWidth = 1;
  };

  exportObj.drawSmallBase = function(ctx) {
    return exportObj.drawBase(ctx, exportObj.SMALL_BASE_WIDTH);
  };

  exportObj.drawLargeBase = function(ctx) {
    return exportObj.drawBase(ctx, exportObj.LARGE_BASE_WIDTH);
  };

  exportObj.drawBase = function(ctx, width) {
    var nub_offset;
    ctx.save();
    ctx.translate(-width / 2, -width / 2);
    ctx.strokeRect(0, 0, width, width);
    ctx.beginPath();
    ctx.moveTo(1, 0);
    ctx.lineTo(width / 2, width / 2);
    ctx.lineTo(width - 1, 0);
    ctx.stroke();
    nub_offset = (width - exportObj.TEMPLATE_WIDTH) / 2;
    ctx.strokeRect(nub_offset - 1, -1, 1, 2);
    ctx.strokeRect(nub_offset - 1, width - 1, 1, 2);
    ctx.strokeRect(nub_offset + exportObj.TEMPLATE_WIDTH, -1, 1, 2);
    ctx.strokeRect(nub_offset + exportObj.TEMPLATE_WIDTH, width - 1, 1, 2);
    return ctx.restore();
  };

  exportObj.transformToCenterAndHeading = function(ctx, width, center_x, center_y, heading_radians) {
    ctx.translate(center_x, center_y);
    return ctx.rotate(heading_radians);
  };

  exportObj.translateToNubsFromCenter = function(ctx, width) {
    return ctx.translate(-exportObj.TEMPLATE_WIDTH / 2, -width / 2);
  };

  exportObj.drawStraight = function(ctx, length) {
    return ctx.strokeRect(0, 0, exportObj.TEMPLATE_WIDTH, -exportObj.SMALL_BASE_WIDTH * length);
  };

  exportObj.drawBank = function(ctx, length, direction) {
    var angle, radius;
    radius = exportObj.BANK_INSIDE_RADII[length];
    ctx.beginPath();
    switch (direction) {
      case 'left':
        angle = -Math.PI / 4.0;
        ctx.arc(-radius, 0, radius, angle, 0);
        ctx.lineTo(exportObj.TEMPLATE_WIDTH, 0);
        ctx.arc(-radius, 0, radius + exportObj.TEMPLATE_WIDTH, 0, angle, true);
        break;
      case 'right':
        angle = -3 * Math.PI / 4.0;
        ctx.arc(radius + exportObj.TEMPLATE_WIDTH, 0, radius, angle, Math.PI, true);
        ctx.lineTo(0, 0);
        ctx.arc(radius + exportObj.TEMPLATE_WIDTH, 0, radius + exportObj.TEMPLATE_WIDTH, Math.PI, angle);
        break;
      default:
        throw new Error("Invalid direction " + direction);
    }
    ctx.closePath();
    return ctx.stroke();
  };

  exportObj.drawTurn = function(ctx, length, direction) {
    var angle, radius;
    angle = -Math.PI / 2;
    radius = exportObj.TURN_INSIDE_RADII[length];
    ctx.beginPath();
    switch (direction) {
      case 'left':
        ctx.arc(-radius, 0, radius, angle, 0);
        ctx.lineTo(exportObj.TEMPLATE_WIDTH, 0);
        ctx.arc(-radius, 0, radius + exportObj.TEMPLATE_WIDTH, 0, angle, true);
        break;
      case 'right':
        ctx.arc(radius + exportObj.TEMPLATE_WIDTH, 0, radius + exportObj.TEMPLATE_WIDTH, angle, Math.PI, true);
        ctx.lineTo(exportObj.TEMPLATE_WIDTH, 0);
        ctx.arc(radius + exportObj.TEMPLATE_WIDTH, 0, radius, Math.PI, angle);
        break;
      default:
        throw new Error("Invalid direction " + direction);
    }
    ctx.closePath();
    return ctx.stroke();
  };

}).call(this);

/*
//@ sourceMappingURL=canvas.map
*/
