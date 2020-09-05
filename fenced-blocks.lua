--[[
     A Pandoc 2 lua filter converting Pandoc native divs to amsthm style numbered environments.
     Author: Bryan Clair
     License: Public domain
     
     For LaTeX output, things are fairly simple since the amsthm package handles
     all the numbering and cross referencing.
     
     For HTML output, the numbering and cross referencing are done in this filter,
     and those numbers are placed into the HTML output as static values.
     
     Currently this interferes with Bookdown's ```{theorem}``` style blocks, because
     each of those shows up as two blocks in the output.
--]]

--[[
USAGE

::: example
This is a fenced example div that will be numbered.
:::

::: {.example #refname data="Important Example"}
This is an important example that can be referenced.
:::

::: {.theorem data="R is complete" data-latex="$\mathbb{R} is complete"}
You can customize the theorem name for latex with data-latex or for html with data-html.
:::

::: {.theorem data-html="2&pi; Theorem" data-latex="$2\pi$ Theorem"}
This theorem has different names depending on output.
:::

--]]

--[[
SETTINGS

In LaTeX, this setup is handled by amsthm definitions in the preamble.
Since those are currently hardcoded into bookdown, they cannot be changed by this filter.
The settings below match the hardcoded LaTeX settings for html output.

Ideally, these settings should come from the YAML for the source document,
and generate the appropriate LaTeX setup as well.

--]]

divstyle = {
  remark = { numbered = false, style = "remark" },
  definition = { style = "definition"},
  example = { sequence = "definition", style = "definition"},
  proof = { numbered = false, style = "remark", name = "Proof:" },
  exercise = { style = "definition", name = "" }
}

--[[
HTML GLOBALS

--]]

-- counters: one counter for each class of fenced block
counters = {}
-- labels: each labeled block's reference number is stored here
labels = {}
-- chapter counter and current chapter string
chapter = 0
cur_chapter = "??"

--[[
HTML METHODS

--]]

-- handle_fenced_div
--   assign a number
--   associate that number with the div's identifier
--   insert heading text
handle_fenced_div = function (div)
  local env = div.classes[1]
  
  -- if the div has no class, we're not interested
  if not env then return nil end

  -- setup style from divstyle or as defaults
  if not divstyle[env] then
    divstyle[env] = {} -- use defaults
  end

  local name = divstyle[env].name or env:gsub("^%l", string.upper)

  local style = divstyle[env].style or "plain"

  local sequence = divstyle[env].sequence or env

  local numbered = true  -- the 'or' idiom fails for booleans
  if divstyle[env].numbered ~= nil then
    numbered = divstyle[env].numbered
  end

  -- calculate numbering string for this env
  local number = ""
  if numbered then
    -- increment counter for this numbering sequence
    if counters[sequence] then
      counters[sequence] = counters[sequence] + 1
    else
      counters[sequence] = 1
    end
    number = cur_chapter .. "." .. tostring(counters[sequence])
  end

  -- set label in dictionary if there is a label
  local label = div.identifier
  if label ~= '' then
    if labels[label] then
      io.stderr:write("Duplicate fenced block label: " .. label .. "\n")
    end
    labels[label] = number
  end
  
  -- insert begin text before content
  local begintxt = string.format(
    '<span class="divhead-%s %s-before">%s %s</span>',
    style,      -- css class divhead-plain, divhead-definition, divhead-remark, etc.
    env,        -- css class env-before for customization of this env's style
    name,       -- display name
    number  -- display number
  )
  table.insert(
    div.content, 1,
    pandoc.RawBlock('html', begintxt)
  )
  local parentxt = div.attributes["data-html"] or div.attributes["data"]
  if parentxt then
    table.insert(
      div.content, 2,
      pandoc.RawBlock('html', "(" .. parentxt .. ")")
    )
  end

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
  
  -- reset all env counters
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

--[[
LATEX METHODS

--]]
latex_div = function (div)
  local env = div.classes[1]

  -- if the div has no class, the object is left unchanged
  if not env then return nil end

  -- build begin text
  local begintxt = '\\begin{' .. env .. '}'
  
  local data = div.attributes['data-latex'] or div.attributes['data']
  if data then
    begintxt = begintxt .. '[' .. data .. ']'
  end
  
  local label = div.identifier
  if label ~= '' then
    begintxt = begintxt .. '\\label{' .. label .. '}'
    -- don't let the identifier escape to become a double label
    div.identifier = ''
  end

  -- insert text before and after content
  table.insert(
    div.content, 1,
    pandoc.RawBlock('tex', begintxt)
  )
  table.insert(
    div.content,
    pandoc.RawBlock('tex', '\\end{' .. env .. '}')
  )
  return div
end

--[[
FILTER

--]]

if FORMAT == "latex" or FORMAT == "beamer" then
  return {{ Div = latex_div }}
elseif FORMAT == "gitbook" or FORMAT == "html" or FORMAT == "html4" then
  -- returning in this order means that the labels get resolved
  -- before the reference handler replaces them
  return {{ Block = block_dispatch } , { Str = fixrefs }}
else
  return nil
end

