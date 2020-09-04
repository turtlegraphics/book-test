--[[
     A Pandoc 2 lua filter converting Pandoc native divs to html environments
     Author: Bryan Clair
     License: Public domain
--]]

-- counters: one counter for each class of fenced block
counters = {}
-- labels: each labeled block lives here
labels = {}
-- chapter counter and current chapter string
chapter = 0
cur_chapter = "??"

-- handle_fenced_div
--   assign a number
--   associate that number with the div's identifier
handle_fenced_div = function (div)
  local env = div.classes[1]
  
  -- if the div has no class, we're not interested
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
    if labels[label] then
      io.stderr:write("Duplicate fenced block label: " .. label .. "\n")
    end
    labels[label] = cur_chapter .. "." .. tostring(counters[env])
  end
end

-- new_chapter
--   increment chapter counter (carefully)
--   reset fenced div counters
function new_chapter(el)
  -- check if this is a numbered chapter
  local numbered = true
  for i,c in ipairs(el.classes) do
    if c == "unnumbered" then numbered = false end 
  end
  
  -- set the current chapter label prefix
  if numbered then
    chapter = chapter + 1
    cur_chapter = tostring(chapter)
  else
    -- use first character of identifier as the chapter value
    cur_chapter = el.identifier:sub(1,1):upper()
  end
  
  -- reset all counters
  counters = {}
end

-- Called on all Block elements, dispatch as appropriate
function block_dispatch(el)
  if el.t == "Header" and el.level == 1 then
    new_chapter(el)
  elseif el.t == "Div" then
    handle_fenced_div(el)
  end
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

-- returning in this order means that the labels get resolved
-- before the reference handler replaces them
return {{ Block = block_dispatch } , { Str = fixrefs }}