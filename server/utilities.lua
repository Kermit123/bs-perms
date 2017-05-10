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
