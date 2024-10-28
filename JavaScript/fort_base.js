'use strict';
/*global require */
var Drone = require('drone'),
  blocks = require('blocks');

function fort_base(side, height, add_gate) {
  var turret, i;

  // defaults
  if (typeof side == 'undefined') {
    side = 20;
  }
  if (typeof height == 'undefined') {
    height = 8;
  }
  if (typeof add_gate == 'undefined') {
    add_gate = true;
  }
  // make sure side is even
  if (side % 2) {
    side++;
  }
  var battlementWidth = 3;
  if (side <= 12) {
    battlementWidth = 2;
  }
  if (height < 4 || side < 10) {
    throw new java.lang.RuntimeException(
      'Forts must be at least 10 wide X 4 tall'
    );
  }


  // build walls.
  this.chkpt('fort_base')
    .down()
    .chessboard(blocks.endstone, '206', side)
    .up()
    .box0(blocks.sandstone, side, height - 1, side)
    .up(height - 1);
  // build battlements
  for (i = 0; i <= 3; i++) {
    turret = [
      blocks.stairs.sandstone,
      blocks.stairs.sandstone + ':' + Drone.PLAYER_STAIRS_FACING[(this.dir + 2) % 4]
    ];
    this.box(blocks.sandstone) // solid brick corners
      .up()
      .box(blocks.torch)
      .down() // light a torch on each corner
      .fwd()
      .boxa(turret, 1, 1, side - 2)
      .fwd(side - 2)
      .turn();
  }
  // build battlement's floor
  this.move('fort_base')
    .up(height - 2)
    .fwd()
    .right();

  for (i = 0; i < battlementWidth; i++) {
    var bside = side - (2 + i * 2);
    this.box0(blocks.slab.sandstone, bside, 1, bside)
      .fwd()
      .right();
  }
  if (add_gate) {
    // add gate (semicircular arch)
    var gateHeight = Math.min(height - 2, 7);
    var gateWidth = 3;
    var radius = gateWidth;

    this.move('fort_base')
      .right(side / 2 - gateWidth)
      // Create the arch
      .down(gateWidth)
      .left(1)
      .arc({
        blockType: blocks.sandstone_red,
        radius: radius+1,
        orientation: 'vertical',
        quadrants: {topright:true, topleft:true},
        degrees: 180
      })
      .right(1)
      .arc({
          blockType: blocks.fence.oak,
          radius: radius,
          orientation: 'vertical',
          quadrants: {topright:true, topleft:true},
          degrees: 180
        })

        .up(1)
        .right(gateWidth/2)
        .box(blocks.air, gateWidth, gateHeight - 1, 1)
        .move('fort_base')

    // Add bridge
    this.move('fort_base')
      .right((side / 2) + 1)
      .down(1)
      .turn(2)
      .box(blocks.brick.stone, 3,1,9)
      .move('fort_base');
  }
  // add ladder up to battlements
  this.move('fort_base')
    .right(5)
    .fwd() // move inside fort
    .turn(2)
    .box(blocks.air, 1, height - 1, 1)
    .ladder(height - 1)
    .move('fort_base');
}
Drone.extend(fort_base);
