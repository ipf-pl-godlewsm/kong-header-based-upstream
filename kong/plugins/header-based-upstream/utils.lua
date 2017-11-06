local _M = {}

-- Returns difference between a and b
function _M.difference(a, b)

    local ret = {}

    if a == nil and b == nil then
        return ret
    end

    if a == nil and b ~= nil then
        return b
    end

    if a ~= nil and b == nil then
        return a
    end

    local aa = {}
    for k,v in pairs(a) do aa[v]=true end
    for k,v in pairs(b) do aa[v]=nil end
    
    local n = 0
    for k,v in pairs(a) do
        if aa[v] ~= nil then 
            n=n+1 
            ret[n]=v 
        end
    end
    return ret
end

function _M.table_contains(table, element)
    for _, value in pairs(table) do
      if value == element then
        return true
      end
    end
    return false
  end

function _M.table_length(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

return _M