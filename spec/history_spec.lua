--[[--
Undo / redo tests, run against the real main.lua.
KOReader modules are replaced with permissive stubs so the plugin can be
loaded outside the reader.
Run with: busted spec/history_spec.lua
--]]--

package.path = package.path .. ";pencil.koplugin/?.lua"

-- A stub that accepts any field access or call and returns another stub.
local function make_stub()
    return setmetatable({}, {
        __index = function() return make_stub() end,
        __call = function() return make_stub() end,
    })
end

local stubs = {
    ["ui/uimanager"] = setmetatable({}, { __index = function() return function() end end }),
    ["ui/widget/container/inputcontainer"] = {
        -- No stub fallback: unset fields must read as nil, as in KOReader.
        extend = function(_, o) return o or {} end,
    },
    ["gettext"] = function(s) return s end,
    ["logger"] = setmetatable({}, { __index = function() return function() end end }),
}

local function load_pencil()
    table.insert(package.loaders, 2, function(name)
        if name == "lib/geometry" then return nil end
        return function() return stubs[name] or make_stub() end
    end)
    local Pencil = dofile("pencil.koplugin/main.lua")
    table.remove(package.loaders, 2)
    return Pencil
end

local Pencil = load_pencil()

local function new_pencil()
    local p = setmetatable({
        strokes = {},
        page_strokes = {},
        undo_stack = {},
        redo_stack = {},
        view = {},
    }, { __index = Pencil })
    p.rebuildAnnotationGroups = function() end
    p.saveStrokes = function() end
    return p
end

local function add(p, name)
    local stroke = { name = name, page = 1, points = { { x = 0, y = 0 } } }
    table.insert(p.strokes, stroke)
    p:pushUndo({ type = "add", stroke_idx = #p.strokes })
    return stroke
end

local function names(p)
    local out = {}
    for _, s in ipairs(p.strokes) do table.insert(out, s.name) end
    return out
end

describe("undo / redo (real main.lua)", function()
    it("redoes an undone stroke", function()
        local p = new_pencil()
        add(p, "a")
        add(p, "b")
        p:undoLastStroke()
        assert.are.same({ "a" }, names(p))
        p:redoLastStroke()
        assert.are.same({ "a", "b" }, names(p))
    end)

    it("undoes the right stroke after an earlier one was erased", function()
        local p = new_pencil()
        local a = add(p, "a")
        add(p, "b")
        add(p, "c")
        -- Erase "a": indices of b and c shift down by one.
        table.remove(p.strokes, 1)
        p:pushUndo({ type = "delete", strokes = { a } })
        p:undoLastStroke() -- restores a
        p:undoLastStroke() -- removes c, not whatever sits at its old index
        assert.are.same({ "b", "a" }, names(p))
    end)

    it("redoes an undone erase", function()
        local p = new_pencil()
        local a = add(p, "a")
        add(p, "b")
        table.remove(p.strokes, 1)
        p:pushUndo({ type = "delete", strokes = { a } })
        p:undoLastStroke()
        assert.are.same({ "b", "a" }, names(p))
        p:redoLastStroke()
        assert.are.same({ "b" }, names(p))
    end)

    it("clears redo history on a new action", function()
        local p = new_pencil()
        add(p, "a")
        p:undoLastStroke()
        add(p, "b")
        p:redoLastStroke()
        assert.are.same({ "b" }, names(p))
    end)

    it("walks back and forth through several steps", function()
        local p = new_pencil()
        add(p, "a")
        add(p, "b")
        add(p, "c")
        p:undoLastStroke()
        p:undoLastStroke()
        p:undoLastStroke()
        assert.are.same({}, names(p))
        p:undoLastStroke() -- nothing left: no-op
        p:redoLastStroke()
        p:redoLastStroke()
        assert.are.same({ "a", "b" }, names(p))
        p:redoLastStroke()
        p:redoLastStroke() -- nothing left: no-op
        assert.are.same({ "a", "b", "c" }, names(p))
    end)
end)
