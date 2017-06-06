DTF2 = DTF2 or { }
DTF2.TableRandom = function(tab)
  local valids
  do
    local _accum_0 = { }
    local _len_0 = 1
    for _index_0 = 1, #tab do
      local val = tab[_index_0]
      if type(val) ~= 'table' then
        _accum_0[_len_0] = val
        _len_0 = _len_0 + 1
      end
    end
    valids = _accum_0
  end
  if #valids == 0 then
    return nil
  end
  return valids[math.random(1, #valids)]
end
