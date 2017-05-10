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

function playerCanTargetPlayer(id, targetId)
  local auth = getAuthedAdmin(id)
  local targetAuth = getAuthedAdmin(targetId)

  if auth == nil then
    if targetAuth == nil then
      return true
    else
      return false
    end
  end

  if targetAuth == nil then
    return true
  end

  if auth.immunity >= targetAuth.immunity then
    return true
  end

  return false
end
