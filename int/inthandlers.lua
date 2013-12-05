-- Interrupt handler example
-- From http://www.eluaproject.net/doc/master/en_inthandlers.html


local vtmrid = tmr.VIRT0
local to = 1500000
local uartid = 0

local prev_tmr, new_prev_tmr, prev_gpio

-- This is the timer interrupt handler
local function tmr_handler( resnum )
  print( string.format( "Timer interrupt for id %d", resnum ) )
  if prev_tmr then prev_tmr( resnum ) end
end

-- This is the timer interrupt handler that gets set after tmr_handler
local function new_tmr_handler( resnum )
  print( string.format( "NEW HANDLER: timer interrupt for id %d", resnum ) )
  -- This will chain to the previous interrupt handler (tmr_handler above)
  if new_prev_tmr then new_prev_tmr( resnum ) end
end

-- This is the GPIO interrupt on change (falling edge) interrupt
local function gpio_negedge_handler( resnum )
    local port, pin = pio.decode( resnum )
  print( string.format( "GPIO NEGEDGE interrupt on port %d, pin %d", port, pin ) )
  if prev_gpio then prev_gpio( resnum ) end
end

pio.pin.setdir( pio.INPUT, pio.P0_0 )

-- Set timer interrupt handler
prev_tmr = cpu.set_int_handler( cpu.INT_TMR_MATCH, tmr_handler )
-- Set GPIO interrupt on change (negative edge) interrupt handler
prev_gpio = cpu.set_int_handler( cpu.INT_GPIO_NEGEDGE, gpio_negedge_handler )
-- Setup periodic timer interrupt for virtual timer 0
tmr.set_match_int( vtmrid, to, tmr.INT_CYCLIC )
-- Enable GPIO interrupt on change (negative edge) for pin 0 of port 0
cpu.sei( cpu.INT_GPIO_NEGEDGE, pio.P0_0 )
-- Enable timer match interrupt on virtual timer 0
cpu.sei( cpu.INT_TMR_MATCH, vtmrid )

local tmrid, count = 0, 0
while true do
  print "Outside interrupt"
  for i = 1, 1000 do tmr.delay( tmrid, 1000 ) end
  if uart.getchar( uartid, 0 ) ~= "" then break end
  count = count + 1
  if count == 5 then
    print "Changing timer interrupt handler"
    new_prev_tmr = cpu.set_int_handler( cpu.INT_TMR_MATCH, new_tmr_handler )
  end
end

-- Cleanup
-- Stop the timer from generating periodic interrupts
tmr.set_match_int( vtmrid, 0, tmr.INT_CYCLIC );
-- Disable the GPIO interrupt on change (negative edge) interrupt
cpu.cli( cpu.INT_GPIO_NEGEDGE, pio.P0_0 )
-- Disable the timer interrupt on match interrupt
cpu.cli( cpu.INT_TMR_MATCH, vtmrid )
-- Clear the timer interrupt handler
cpu.set_int_handler( cpu.INT_TMR_MATCH, nil );
-- Clear the GPIO interrupt handler
cpu.set_int_handler( cpu.INT_GPIO_NEGEDGE, nil );
