function splitBySpace(stringToSplit)
  local args = {}
  for arg in string.gmatch(stringToSplit, "%S+") do
    args[#args + 1] = arg
  end
  return args
end

function startsWith(theString, start)
  return string.sub(theString, 1, string.len(start)) == start
end

function highestOfTwo(int1, int2)
  if int1 > int2 then
    return int1
  else
    return int2
  end
end
