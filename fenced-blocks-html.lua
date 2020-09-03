--[[
     A Pandoc 2 lua filter converting Pandoc native divs to html environments
     Author: Bryan Clair
     License: Public domain
--]]

-- counters: one counter for each class of fenced block
counters = {}
-- labels: each labeled block lives here
labels = {}

-- this function finds fenced divs, assigns a number,
-- and associates that number with the div's identifier
get_fenced_div_labels = function (div)
  local env = div.classes[1]
  
  -- if the div has no class, the object is left unchanged
  if not env then return nil end

  -- increment counter for this class
  if counters[env] then
    counters[env] = counters[env] + 1
  else
    counters[env] = 1
  end

  -- handle labeled blocks
  local label = div.identifier
  if label ~= '' then
    -- store for later reference (NEED TO CHECK FOR DUPLICATES HERE)
    labels[label] = counters[env]
  end

  return div
end

-- this function finds @ref(label) references and replaces
-- them with the appropriate number and a link to the block
fixrefs = function (elem)
  reflabel = elem.text:match "@ref%((.-)%)"
  if reflabel and labels[reflabel] then
    local link = '<a href="#' .. reflabel .. '">'
    link = link .. labels[reflabel] .. '</a>'
    return pandoc.RawInline("html", link)
  else
    return elem
  end
end

-- returning in this order means that the labels get built before the reference handler
return {{ Div = get_fenced_div_labels } , { Str = fixrefs }}