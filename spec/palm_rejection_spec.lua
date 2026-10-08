--[[--
Palm rejection tests, run against the real main.lua.
KOReader modules are replaced with permissive stubs so the plugin can be
loaded outside the reader; the Input object is a minimal fake.
Run with: busted spec/palm_rejection_spec.lua
--]]--

package.path = package.path .. ";pencil.koplugin/?.lua"

-- A stub that accepts any field access or call and returns another stub.
local function make_stub()
    return setmetatable({}, {
        __index = function() return make_stub() end,
        __call = function() return make_stub() end,
    })
end

local clock = 0

local stubs = {
    ["device"] = setmetatable({ screen = make_stub() }, {
        __index = function() return function() return true end end,
    }),
    ["ui/time"] = {
        now = function() return clock end,
        to_ms = function(t) return t end,
    },
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

local PEN_SLOT = 4

local function new_pencil(opts)
    opts = opts or {}
    local p = setmetatable({
        palm_rejection = opts.palm_rejection ~= false,
    }, { __index = Pencil })
    p.isEnabled = function() return true end
    return p
end

-- Fake Input: pen proximity lives in ev_slots[pen_slot].tool, like input.lua.
local function new_input()
    return {
        pen_slot = PEN_SLOT,
        ev_slots = { [PEN_SLOT] = { slot = PEN_SLOT, tool = 0 } },
        MTSlots = {},
    }
end

local function pen_near(input, near) input.ev_slots[PEN_SLOT].tool = near and 1 or 0 end

-- Run one frame with the given finger slots; returns the slot numbers kept.
local function frame(p, input, fingers)
    input.MTSlots = {}
    for _, f in ipairs(fingers) do
        table.insert(input.MTSlots, { slot = f[1], id = f[2], tool = 0, x = 10, y = 10 })
    end
    p:filterPalmSlots(input)
    local kept = {}
    for _, s in ipairs(input.MTSlots) do table.insert(kept, s.slot) end
    return kept
end

describe("palm rejection (real main.lua)", function()
    before_each(function() clock = 0 end)

    it("drops a touch that starts while the pen is near, including its lift", function()
        local p, input = new_pencil(), new_input()
        pen_near(input, true)
        assert.are.same({}, frame(p, input, { { 0, 7 } }))
        pen_near(input, false)
        assert.are.same({}, frame(p, input, { { 0, 7 } }))
        assert.are.same({}, frame(p, input, { { 0, -1 } }))
        -- A new touch after that goes through.
        assert.are.same({ 0 }, frame(p, input, { { 0, 8 } }))
    end)

    it("drops touches shortly after the pen was used, then lets them through", function()
        local p, input = new_pencil(), new_input()
        clock = 1000
        p.last_stylus_time = 1000
        clock = 1500
        assert.are.same({}, frame(p, input, { { 1, 3 } }))
        frame(p, input, { { 1, -1 } })
        clock = 1000 + 801
        assert.are.same({ 1 }, frame(p, input, { { 1, 4 } }))
    end)

    it("leaves a touch that began before the pen arrived untouched until its lift", function()
        local p, input = new_pencil(), new_input()
        assert.are.same({ 0 }, frame(p, input, { { 0, 5 } }))
        pen_near(input, true)
        assert.are.same({ 0 }, frame(p, input, { { 0, 5 } }))
        assert.are.same({ 0 }, frame(p, input, { { 0, -1 } }))
    end)

    it("keeps a finger and drops only the palm when both are on screen", function()
        local p, input = new_pencil(), new_input()
        assert.are.same({ 0 }, frame(p, input, { { 0, 5 } }))
        pen_near(input, true)
        assert.are.same({ 0 }, frame(p, input, { { 0, 5 }, { 1, 6 } }))
    end)

    it("never touches the pen slot", function()
        local p, input = new_pencil(), new_input()
        pen_near(input, true)
        input.MTSlots = { { slot = PEN_SLOT, id = PEN_SLOT, tool = 1 } }
        p:filterPalmSlots(input)
        assert.are.equal(1, #input.MTSlots)
    end)

    it("does nothing when the option is off", function()
        local p, input = new_pencil({ palm_rejection = false }), new_input()
        pen_near(input, true)
        assert.are.same({ 0 }, frame(p, input, { { 0, 5 } }))
    end)

    it("wraps routeStylusEvents once and filters after stylus routing", function()
        local p, input = new_pencil(), new_input()
        local routed = 0
        input.routeStylusEvents = function() routed = routed + 1 end
        p:installPalmFilter(input)
        local wrapped = input.routeStylusEvents
        p:installPalmFilter(input)
        assert.are.equal(wrapped, input.routeStylusEvents)
        input:routeStylusEvents()
        assert.are.equal(1, routed)
    end)
end)
