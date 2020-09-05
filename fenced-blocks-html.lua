--[[
     A Pandoc 2 lua filter converting Pandoc native divs to html environments
     Author: Bryan Clair
     License: Public domain
--]]

-- SETTINGS
---- this really should be handled in the YAML in bookdown so it can be customized
divstyle = {
  remark = { numbered = false, style = "remark" },
  definition = { style = "definition"},
  example = { sequence = "definition", style = "definition"},
  proof = { numbered = false, style = "remark" }
}

-- GLOBALS
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
--   insert heading text
handle_fenced_div = function (div)
  local env = div.classes[1]
  
  -- if the div has no class, we're not interested
  if not env then return nil end

  -- setup divstyle
  if not divstyle[env] then
    divstyle[env] = {} -- use defaults
  end
  style = divstyle[env].style or "plain"
  sequence = divstyle[env].sequence or env
  numbered = true
  if divstyle[env].numbered ~= nil then
    numbered = divstyle[env].numbered
  end

  -- increment counter for this env
  if counters[sequence] then
    counters[sequence] = counters[sequence] + 1
  else
    counters[sequence] = 1
  end

  -- calculate numbering string for this env
  if numbered then
    env_number = cur_chapter .. "." .. tostring(counters[sequence])
  else
    env_number = ""
  end

  -- set label in dictionary if there is a label
  local label = div.identifier
  if label ~= '' then
    if labels[label] then
      io.stderr:write("Duplicate fenced block label: " .. label .. "\n")
    end
    labels[label] = env_number
  end
  
  -- insert begin text before content
  begintxt = string.format(
    '<span class="divhead-%s %s-before">%s %s</span>',
    style,  -- divhead class plain, definition, remark, etc.
    env,    -- class for customization of this env's style
    env:gsub("^%l", string.upper),  -- display class with uppercase first letter
    env_number  -- display number
  )
  table.insert(
    div.content, 1,
    pandoc.RawBlock('html', begintxt)
  )
  return div
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
  return nil
end

-- Called on all Block elements, dispatch as appropriate
function block_dispatch(el)
  if el.t == "Header" and el.level == 1 then
    return new_chapter(el)
  elseif el.t == "Div" then
    return handle_fenced_div(el)
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