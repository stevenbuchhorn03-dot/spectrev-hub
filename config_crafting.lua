-- Crafting: recipe slots by position (x,y) and optional size (width, height).
-- result: { name = "target_item", amount = 1 }
CraftingConfig = CraftingConfig or {}

-- Show recipe zone coordinates as red outline on crafting grid (debug)
CraftingConfig.DebugRecipeZones = true

-- 4x4 "big slot" index when used (slot = 0,1,2,3...)
CraftingConfig.BigSlotSize = 4

--[[
  X,Y SCHEMA (config.lua crafting = 8 columns x 8 rows example)
  ─────────────────────────────────────────────────────────
  x = column (left to right, 0-based)
  y = row (top to bottom, 0-based)
  One cell = (x, y). Example: "5th column, 3rd row" → x=4, y=2

        x=0   x=1   x=2   x=3   x=4   x=5   x=6   x=7
        ┌────┬────┬────┬────┬────┬────┬────┬────┐
  y=0   │0,0 │1,0 │2,0 │3,0 │4,0 │5,0 │6,0 │7,0 │  row 1
        ├────┼────┼────┼────┼────┼────┼────┼────┤
  y=1   │0,1 │1,1 │2,1 │3,1 │4,1 │5,1 │6,1 │7,1 │  row 2
        ├────┼────┼────┼────┼────┼────┼────┼────┤
  y=2   │0,2 │1,2 │2,2 │3,2 │4,2 │5,2 │6,2 │7,2 │  row 3  ← (4,2) = 5th col 3rd row
        ├────┼────┼────┼────┼────┼────┼────┼────┤
  y=3   │0,3 │1,3 │2,3 │3,3 │4,3 │5,3 │6,3 │7,3 │  row 4
        ├────┼────┼────┼────┼────┼────┼────┼────┤
  y=4   │0,4 │1,4 │2,4 │3,4 │4,4 │5,4 │6,4 │7,4 │  ...
        └────┴────┴────┴────┴────┴────┴────┴────┘
        1st  2nd  3rd  4th  5th  6th  7th  8th  column

  SLOT DEFINITION (all optional, can be mixed):

  1) x, y, width, height (position + desired area)
     Defines the RECTANGULAR AREA from (x,y) to (x+width-1, y+height-1).
     Any item that fully covers this area is accepted (3x3, 4x7, 3x4 etc.).
     Example: { x = 4, y = 2, width = 2, height = 3, item = "plastic", amount = 1 }
     → One plastic covering (4,2)-(5,4) is enough; item can be 2x3, 4x7 or 3x4.
     EDGE: If area extends outside grid it is clipped; only the part inside grid is required.
     E.g. on 8x8 grid (6,2)+3x3 becomes (6,2)+2x3 (bottom-right); item must cover this 2x3 area.
     If width/height omitted: any item covering (x,y) cell is accepted.

  2) x, y (position only)
     { x = 0, y = 0, item = "metalscrap", amount = 2 }
     Item covering (x,y) with correct name/amount is enough.

  3) slot (4x4 big slot index)
     { slot = 0, item = "metalscrap", amount = 2 }
     slot 0=top-left, 1=top-right, 2=bottom-left, 3=bottom-right (8x8 grid, 4x4 big slot)
]]

-- Recipes: first matching recipe is applied
CraftingConfig.Recipes = {
    -- Repair Kit: Metal Scrap 2x2 top-left (0,0), Plastic 1x1 (6,4) as in image
    {
        id = "repairkit",
        name = "Repair Kit",
        slots = {
            { x = 0, y = 0, width = 3, height =3, item = "metalscrap", amount = 2 },  -- top-left 2x2
            { x = 6, y = 7, width = 3, height = 3, item = "plastic", amount = 1 },       -- (6,4) 3x3 area
        },
        result = { name = "repairkit", amount = 1 },
    },
    {
      id = "money_50k",
      name = "50K Banded",
      slots = {
          { x = 0, y = 0, width = 3, height =3, item = "cash", amount = 20000 },
          { x = 3, y = 0, width = 3, height =3, item = "cash", amount = 20000 },
          { x = 0, y = 3, width = 3, height =3, item = "cash", amount = 10000 },  -- top-left 2x2
          { x = 5, y = 5, width = 3, height = 3, item = "bands_50k", amount = 1 },       -- (6,4) 3x3 area
      },
      result = { name = "money_50k", amount = 1 },
  },
    -- Example: for 3x3 metalscrap use top-left (0,0)-(5,5); (6,4)+3x3 does not fit in 8x8 grid.
    -- { x = 0, y = 0, width = 3, height = 3, item = "metalscrap", amount = 2 },
}