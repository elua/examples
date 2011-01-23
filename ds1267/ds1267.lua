-- eLua examples
-- DS1267 Digital Potentiometers SPI controlled by eLua

clock = spi.setup( 0, spi.MASTER, 1e6, 0, 0, 8 )
pio.pin.setdir( pio.OUTPUT, pio.PA_4 )
pio.pin.setlow( pio.PA_4 )

function set_ds1267(pos0, pos1)
  pio.pin.sethigh( pio.PA_4 )
  spi.write( 0, 0, pos1, pos0 )
  pio.pin.setlow( pio.PA_4)
end


      