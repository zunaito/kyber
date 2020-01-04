--  kyber 
--    basic convolution platform
--   
-- [[ . ]]
-- key1 = alt
-- enc1 = kernel
-- enc2 = framesize
-- enc3 = crossfade
-- alt + enc3 = trigger
--
-- https://llllllll.co/t/? ****edit 
-- @glia

engine.name = "Kyber"

local alt = false

local lfo = include("lib/hnds_kyber")
local lfo_targets = {
  "none",
  "kernel",
  "framesize",
  "crossfade",
  "trigger",
}


function lfo.process()
  -- for lib hnds
  for i = 1, 4 do
    local target = params:get(i .. "lfo_target")
    if params:get(i .. "lfo") == 2 then
      -- kernel
      if target == 2 then
        params:set(lfo_targets[target], lfo.scale(lfo[i].slope, -1.0, 2.0, 0.00, 6.00))
      -- framesize
      elseif target == 3 then
        params:set(lfo_targets[target], lfo.scale(lfo[i].slope, -1.0, 2.0, 0.50, 5.00))
      -- crossfade
      elseif target == 4 then
        params:set(lfo_targets[target], lfo.scale(lfo[i].slope, -1.0, 2.0, 0.00, 1.00))
      -- trigger
      end
    end
  end
end


function init()
  -- params
  -- kernel
  params:add_control("kernel", "kernel", controlspec.new(0.00, 10.00, "lin", 0.01, 2.00, ""))
  params:set_action("kernel", function(value) engine.delay_time(value) end)
  -- framesize
  params:add_control("size", "size", controlspec.new(0.5, 5.0, "lin", 0.01, 2.00, ""))
  params:set_action("size", function(value) engine.delay_size(value) end)
  -- crossfade
  params:add_control("xfade", "xfade", controlspec.new(0.0, 1.0, "lin", 0.01, 0.10, ""))
  params:set_action("xfade", function(value) engine.delay_damp(value) end)
  -- trigger
  params:add_control("trig", "trig", controlspec.new(0.0, 1.0, "lin", 0.01, 0.707, ""))
  params:set_action("trig", function(value) engine.delay_diff(value) end)

  -- for hnds
  for i = 1, 4 do
    lfo[i].lfo_targets = lfo_targets
  end
  lfo.init()

  norns.enc.sens(1, 5)

  -- redraw timer
  screen_metro = metro.init()
  screen_metro.time = 1/15
  screen_metro.event = function() redraw() end
  screen_metro:start()
end


function key(n, z)
  if n == 1 then alt = z == 1 and true or false end
end


function enc(n, d)
  if n == 1 then
    params:delta("kernel", d)
  end
  if alt then
    if n == 3 then
      params:delta("trigger", d)
    end
  else
    if n == 2 then
      params:delta("size", d)
    elseif n == 3 then
      params:delta("xfade", d)
    end
  end
end


function redraw()
  screen.clear()
  screen.aa(0)
  screen.level(15)
  screen.move(5, 15)
  screen.font_size(16)
  screen.text("greyhole")
  screen.move(75, 15)
  screen.line(120, 15)
  screen.stroke()
  -- controls
  screen.font_size(8)

  
  screen.move(8, 28)
  screen.text("kernel:")
  screen.move(120, 28)
  screen.text_right(string.format("%.2f", params:get("kernel")))

  screen.level(alt and 2 or 10)
  screen.move(8, 36)
  screen.text("size:  ")
  screen.move(120, 36)
  screen.text_right(string.format("%.2f", params:get("framesize")))

  screen.move(8, 44)
  screen.text("xfade:  ")
  screen.move(120, 44)
  screen.text_right(string.format("%.2f", params:get("crossfade")))

  screen.level(alt and 10 or 2)
  screen.move(8, 52)
  screen.text("trig:  ")
  screen.move(120, 52)
  screen.text_right(string.format("%.2f", params:get("trigger")))

  screen.update()
end
