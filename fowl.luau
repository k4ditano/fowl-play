-- Fowl Play's logic. The game runs in the console's steps: sixty a second,
-- whatever the monitor's rate, counted in frames as it was. The scene draws
-- what the facts and the models say, in the console's 256 × 240 pixels.
-- Its parts are in logic/: the sounds and tunes (music), the board and the
-- end of a round (board), games A and B over the marsh (marsh) and game C's
-- clays (range). They share what is kept here, in `G`.

local G = {
    quiet = false, loud = 1, flashing = true,
    top = { 12000, 12000, 12000 },
    screen = 0, choice = 0, game = 0, round = 1, score = 0,
    phase = "title", t = 0, frame = 0, paused = false,
    marks = {}, idx = 1, shells = 3, targets = {}, pops = {},
    flash = 0, flash_boxes = {}, pending = nil,
}

-- What was last told to the scene: a fact only travels when it changes.
local told = {}
function G.put(name, v)
    if told[name] ~= v then
        told[name] = v
        fact[name] = v
    end
end
function G.say_text(name, v)
    if told["t:" .. name] ~= v then
        told["t:" .. name] = v
        text[name] = v
    end
end

require("logic/music")(G)
require("logic/board")(G)
require("logic/marsh")(G)
require("logic/range")(G)

-- ── what is kept: the top scores and the switches ──
local function save()
    sys.call("files.write", "fowl.json", { v = 1, top = G.top, quiet = G.quiet, flashing = G.flashing })
end
G.save = save

local function hint()
    text.hint_t = "M SOUND " .. (G.quiet and "OFF" or "ON ") .. "  F FLASH " .. (G.flashing and "ON" or "OFF")
end

do
    local ok, kept = pcall(sys.ask, "files.read", "fowl.json", "json")
    if ok and type(kept) == "table" then
        if type(kept.top) == "table" then
            for i = 1, 3 do
                G.top[i] = tonumber(kept.top[i]) or G.top[i]
            end
        end
        G.quiet = kept.quiet == true
        G.flashing = kept.flashing ~= false
        -- For tests: a fixed seed, a game to start, and a gun that fires by itself
        -- (`aim`: the frames it waits on each target; `miss`, every how many it misses).
        if type(kept.test) == "table" then
            G.test = kept.test
            math.randomseed(tonumber(kept.test.seed) or 1)
        end
    end
end
sound.volume(0.8)
hint()

-- ── the title ──
local function show_title()
    G.screen, G.phase, G.paused = 0, "title", false
    fact.screen, fact.paused, fact.banner = 0, false, 0
    G.put("dog.show", false)
    fact.choice = G.choice
    text.top_t = string.format("TOP SCORE = %d", G.top[G.choice + 1])
    model.ducks, model.clays, model.held, model.pops, model.boxes = {}, {}, {}, {}, {}
end
G.show_title = show_title

local function start(choice)
    G.choice = choice
    G.game = choice -- 0 game A, 1 game B, 2 game C
    G.round, G.score = 1, 0
    G.music.stop()
    if choice == 2 then
        G.range.begin()
    else
        G.marsh.begin()
    end
end

local function choose(d)
    G.choice = (G.choice + d) % 3
    fact.choice = G.choice
    text.top_t = string.format("TOP SCORE = %d", G.top[G.choice + 1])
    G.music.blip()
end

-- ── the gun ──
local aim_x = 0
on("aimx", function(x)
    aim_x = x
end)
on("aimy", function(y)
    if aim_x < 0 then
        -- One of the title's lines.
        if G.screen == 0 then
            start(math.floor(y))
        end
        return
    end
    G.pull(aim_x, y)
end)

-- The trigger: a shell, the flash, and whatever was in the sight.
function G.pull(x, y)
    if G.paused or G.screen == 0 then
        return
    end
    if G.phase ~= "fly" or G.shells <= 0 or G.flash > 0 then
        return
    end
    local game = G.screen == 2 and G.range or G.marsh
    G.shells -= 1
    fact.shells = G.shells
    G.music.shot()
    local boxes = {}
    for _, d in ipairs(G.targets) do
        if game.can_hit(d) then
            table.insert(boxes, game.box(d))
        end
    end
    if G.flashing then
        G.flash, G.flash_boxes, G.flash_fresh = 1, boxes, true
    end
    game.shoot(x, y)
end

-- ── the frames ──
local acc = 0
local function step()
    G.frame += 1
    if G.flash > 0 then
        -- One frame black, one with the targets white, as the light gun needed.
        if G.flash_fresh then
            G.flash_fresh = false
            return
        end
        G.flash += 1
        if G.flash > 3 then
            G.flash = 0
        end
        return
    end
    if G.test and G.test.aim and G.phase == "fly" then
        G.auto = (G.auto or 0) + 1
        local game = G.screen == 2 and G.range or G.marsh
        for _, d in ipairs(G.targets) do
            if game.can_hit(d) and G.auto % G.test.aim == 0 then
                local b = game.box(d)
                G.shots = (G.shots or 0) + 1
                local off = (G.test.miss and G.shots % G.test.miss == 0) and 60 or 0
                G.pull(b.x + b.w / 2 + off, b.y + b.h / 2)
                break
            end
        end
    end
    if G.screen == 1 then
        G.marsh.step()
    elseif G.screen == 2 then
        G.range.step()
    end
    for i = #G.pops, 1, -1 do
        local p = G.pops[i]
        p.life -= 1
        if p.life <= 0 then
            table.remove(G.pops, i)
        end
    end
end

local function draw()
    G.put("flash", G.flash == 1 and 1 or (G.flash == 2 and 2 or 0))
    if G.flash == 2 then
        model.boxes = G.flash_boxes
    end
    if G.screen == 0 then
        return
    end
    local game = G.screen == 2 and G.range or G.marsh
    game.draw()
    local pops = {}
    for _, p in ipairs(G.pops) do
        table.insert(pops, { x = p.x, y = p.y, label = p.label })
    end
    model.pops = pops
    G.board.draw()
end

-- ── a game controller: its stick aims a sight, A pulls the trigger ──
local sx, sy, sight = 128, 100, false
local was = {}
local function pad_step()
    local p = pad(1)
    if not p then
        return
    end
    local function pressed(b)
        local now = p[b] == true
        local edge = now and not was[b]
        was[b] = now
        return edge
    end
    if math.abs(p.lx) > 0.18 or math.abs(p.ly) > 0.18 then
        sight = true
        sx = math.clamp(sx + p.lx * 3.4, 0, 255)
        sy = math.clamp(sy + p.ly * 3.4, 0, 239)
    end
    local a, start_, up, down = pressed("a"), pressed("start"), pressed("up"), pressed("down")
    if G.screen == 0 then
        if up then choose(-1) end
        if down then choose(1) end
        if a or start_ then start(G.choice) end
        return
    end
    if start_ then G.toggle_pause() end
    if a then
        sight = true
        G.pull(sx, sy)
    end
    G.put("sight.on", sight)
    G.put("sight.x", math.floor(sx))
    G.put("sight.y", math.floor(sy))
end

local last_mouse = nil
on("frame", function(dt)
    pad_step()
    -- The mouse moving takes the aim back from the controller.
    local mx = mouse.x
    if mx and mx ~= last_mouse and sight then
        sight = false
        G.put("sight.on", false)
    end
    last_mouse = mx
    if G.paused then
        return
    end
    acc += dt
    local n = 0
    while acc >= 1 / 60 and n < 4 do
        acc -= 1 / 60
        step()
        n += 1
    end
    if n == 4 then
        acc = 0
    end
    draw()
end)

function G.toggle_pause()
    if G.screen == 0 then
        return
    end
    G.paused = not G.paused
    fact.paused = G.paused
    G.music.blip()
end

on("key_down", function(name)
    if name == "m" then
        G.quiet = not G.quiet
        if G.quiet then G.music.stop() end
        hint()
        save()
        return
    end
    if name == "f" then
        G.flashing = not G.flashing
        hint()
        save()
        return
    end
    if G.screen == 0 then
        if name == "Up" or name == "w" then choose(-1) end
        if name == "Down" or name == "s" or name == "Tab" then choose(1) end
        if name == "Return" or name == "space" or name == "KP_Enter" then start(G.choice) end
        return
    end
    if name == "p" or name == "Escape" then
        G.toggle_pause()
    elseif name == "q" and G.paused then
        G.music.stop()
        show_title()
    end
end)

show_title()
G.music.tune("title")
if G.test and G.test.start then
    after(300, function() start(G.test.start) end)
end
