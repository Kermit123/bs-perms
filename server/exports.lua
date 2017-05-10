function playerHasFlag(id, flag)
  local authed = getAuthedAdmin(source)
  if not authed then
    return false
  end
  if hasFlags(authed.flags, flag) then
    return true
  end
  return false
end
