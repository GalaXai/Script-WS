'use strict';
/*global require */
var Drone = require('drone'),
  blocks = require('blocks');

function sand_castle(side, height) {
  // defaults
  if (typeof side == 'undefined') side = 24;
  if (typeof height == 'undefined') height = 10;
  if (height < 8 || side < 20)
    throw new java.lang.RuntimeException(
      'Castles must be at least 20 wide X 8 tall'
    );
  // how big the towers at each corner will be...
  var towerSide = 10;
  var towerHeight = height + 4;

  // the main castle building will be front and right of the first tower
  up(2)
  this.chkpt('sand_castle')
    .down(2)
    .chessboard(blocks.water, blocks.water, side+10)
    .move('sand_castle')
    .fwd(towerSide / 2)
    .right(towerSide / 2)
    .fort_base(side, height)

    .fwd(side -1)
    .right(Math.floor(side/ 2) -5)
    .up(3)
    .box(blocks.glass_pane, 10, 3, 1)
    .move('sand_castle');

  // now place 4 towers at each corner (each tower is another fort)
  for (var corner = 0; corner < 4; corner++) {
    // construct a 'tower' fort
    this.fort_base(towerSide, towerHeight, false)
      .chkpt('tower-' + corner)
      .up(towerHeight - 5) // create 2 doorways from main castle rampart into each tower
      .box(blocks.glass, 3, 3, 3)
      .fwd(towerSide - 1)
      .right(towerSide - 3)
      .box(blocks.air, 1, 2, 1)
      .back(2)
      .right(2)
      .box(blocks.air, 1, 2, 1)
      .move('tower-' + corner)
      .fwd(side + towerSide - 1) // move forward the length of the castle then turn right
      .turn();
  }
  this.move('sand_castle');
  echo(self, "🏰 Your sand castle has been built!");
}
Drone.extend(sand_castle);
