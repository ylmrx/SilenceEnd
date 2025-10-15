---@diagnostic disable: need-check-nil
function cut(buf)
  local chans = buf.number_of_channels
  -- locate where to cut
  local point = buf.number_of_frames + 1
  for c = 1,chans do
    for f = 1,buf.number_of_frames do
      if math.abs(buf:sample_data(c, f)) >=  0.009 then
        point = math.min(f, point)
        break
      end
    end
  end
  -- cut
  buf:prepare_sample_data_changes()
  for c = 1,chans do
    for f = 1,buf.number_of_frames do
      if f < buf.number_of_frames - point then
        buf:set_sample_data(c, f, buf:sample_data(c, f+point))
      else
        buf:set_sample_data(c, f, 0)
      end
    end
  end
  buf:finalize_sample_data_changes()
  
end

function move_sample_silence()
  local smp = renoise.song().selected_sample
  cut(smp.sample_buffer)
end

function move_all_samples_silence()
  local inst = renoise.song().selected_instrument
  local samples = inst.samples
  for _, sample in ipairs(samples) do
    cut(sample.sample_buffer)
  end
end

renoise.tool():add_menu_entry {
  name = "Sample Editor:Process:Put sample silence at the end",
  invoke = function ()
    move_sample_silence()
  end
}

renoise.tool():add_menu_entry {
  name = "Instrument Box:Move silences to the end",
  invoke = function ()
    move_all_samples_silence()
  end
}