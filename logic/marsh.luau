-- Games A and B, over the marsh. Each round the dog walks out sniffing,
-- stops, hears something and leaps into the grass; then the ducks come up out
-- of it, one at a time (A) or two (B). A duck flies in straight lines, turning
-- at the edges and now and then on a whim, until it is hit or its time is up
-- —or the shells are— and it gets away, up past the top of the sky. After
-- each one the dog comes up out of the grass: holding what fell, or laughing.

return function(G)
    local M = {}
    G.marsh = M
    local B = G.board

    local GRASS = 148      -- the top of the grass: what is lower is hidden by it
    local WALK_Y = 137     -- the dog's top when it walks, its feet on the dirt
    local UP_Y = 104       -- its top risen out of the grass, from the chest up
    local FLIGHT = 330     -- the frames a duck has before it gets away

    local dog = { x = -60, y = WALK_Y, cell = 0, show = false, front = true }
    local script, turn_hits = {}, {}

    -- ── the dog ──
    -- What it does at the start of a round, one step after the other.
    local function walk_script()
        return {
            { "walk", 18 }, { "sniff", 54 }, { "walk", 58 }, { "sniff", 54 },
            { "walk", 84 }, { "alert", 34 }, { "leap", 44 },
        }
    end

    local function dog_step()
        local s = script[1]
        if not s then
            return true
        end
        local what = s[1]
        s.t = (s.t or 0) + 1
        local t = s.t
        if what == "walk" then
            dog.show, dog.front, dog.y = true, true, WALK_Y
            dog.x += 0.75
            dog.cell = (t // 8) % 4
            if dog.x >= s[2] then
                table.remove(script, 1)
            end
        elseif what == "sniff" then
            dog.cell = 4 + (t // 9) % 2
            if t >= s[2] then
                table.remove(script, 1)
            end
        elseif what == "alert" then
            dog.cell = 6
            if t == 1 then
                G.music.bark()
            end
            if t >= s[2] then
                table.remove(script, 1)
            end
        elseif what == "leap" then
            -- Up and over, then down into the grass, where it is behind it.
            if t == 1 then
                s.x0, s.y0 = dog.x, dog.y
                G.music.jump()
            end
            local f = t / s[2]
            dog.x = s.x0 + 26 * f
            dog.y = s.y0 - 46 * math.sin(math.pi * f) + 40 * f
            dog.cell = f < 0.5 and 7 or 8
            dog.front = f < 0.5
            if t >= s[2] then
                dog.show = false
                G.music.rustle()
                table.remove(script, 1)
            end
        elseif what == "rise" then
            -- Up out of the grass, a while there, and down again.
            local up, hold = 14, s[2]
            dog.show, dog.front, dog.x = true, false, s.x
            if t <= up then
                dog.y = GRASS + 4 - (GRASS + 4 - UP_Y) * (t / up)
            elseif t <= up + hold then
                dog.y = UP_Y
                if t == up + 1 then
                    if s.laugh then
                        G.music.tune("laugh")
                    else
                        G.music.tune(#s.held == 2 and "caught2" or "caught")
                    end
                end
            else
                dog.y = UP_Y + (GRASS + 4 - UP_Y) * ((t - up - hold) / up)
            end
            if s.laugh then
                dog.cell = 11 + (t // 5) % 2
                if s.forever and t > up then
                    dog.y = UP_Y
                end
            else
                dog.cell = #s.held == 2 and 10 or 9
            end
            if t >= up * 2 + hold and not s.forever then
                dog.show = false
                table.remove(script, 1)
            end
        end
        return #script == 0
    end

    -- ── the ducks ──
    local function pick_kind()
        local r, x = G.round, math.random()
        local black, blue = 0.6, 0.3
        if r >= 10 then
            black, blue = 0.3, 0.4
        elseif r >= 5 then
            black, blue = 0.42, 0.38
        end
        if x < black then return 0 end
        if x < black + blue then return 1 end
        return 2
    end

    local function speed_of(kind)
        local base = ({ 0.95, 1.25, 1.55 })[kind + 1]
        return base * math.min(1 + 0.07 * (G.round - 1), 2.3)
    end

    local function head(d, angle)
        d.vx = math.cos(math.rad(angle)) * d.speed
        d.vy = math.sin(math.rad(angle)) * d.speed
    end

    local function new_duck(slot)
        local kind = pick_kind()
        local d = {
            kind = kind, slot = slot, state = "fly",
            x = 40 + math.random() * 150, y = GRASS + 2,
            speed = speed_of(kind), turn = 40 + math.random(60),
            quack = 10 + math.random(30), anim = math.random(0, 3),
        }
        local right = math.random() < 0.5
        if d.x < 70 then right = true elseif d.x > 160 then right = false end
        head(d, right and -(45 + math.random(0, 20)) or -(135 - math.random(0, 20)))
        return d
    end

    local function turn_now(d)
        -- A new heading: mostly across and up or down, now and then steep.
        local angles = { -20, -35, -50, -65, 20, 35, 50, 0, -80 }
        local a = angles[math.random(#angles)]
        if d.y > 100 and a > 0 then a = -a end
        if math.random() < 0.5 then a = 180 - a end
        head(d, a)
        d.turn = 35 + math.random(85)
    end

    local function flee(d)
        if d.state == "fly" then
            d.state = "flee"
            d.vx, d.vy = 0, -2.6
        end
    end

    local function duck_step(d)
        local pan = (d.x + 16 - 128) / 128
        if d.state == "fly" then
            d.x += d.vx
            d.y += d.vy
            if d.x < 0 then d.x, d.vx = 0, math.abs(d.vx) end
            if d.x > 224 then d.x, d.vx = 224, -math.abs(d.vx) end
            if d.y < 6 then d.y, d.vy = 6, math.abs(d.vy) end
            if d.y > 112 and d.vy > 0 then d.vy = -math.abs(d.vy) end
            d.turn -= 1
            if d.turn <= 0 and d.y < 120 then turn_now(d) end
            d.quack -= 1
            if d.quack <= 0 then
                G.music.quack(pan)
                d.quack = 50 + math.random(60)
            end
        elseif d.state == "flee" then
            d.y += d.vy
            if d.y < -36 then
                d.state = "gone"
                G.marks[G.idx + d.slot] = 2
            end
        elseif d.state == "hit" then
            d.t -= 1
            if d.t <= 0 then
                d.state = "fall"
                G.music.fall(math.max(200, (GRASS + 2 - d.y) / 1.7 / 60 * 1000), pan)
            end
        elseif d.state == "fall" then
            d.y += 1.7
            if d.y >= GRASS + 2 then
                d.state = "down"
                G.music.thud(pan)
                table.insert(turn_hits, d)
            end
        end
    end

    local function duck_cell(d)
        local face = 0
        local frame
        if d.state == "hit" then
            frame = 6
        elseif d.state == "fall" then
            frame = 7
            face = ((G.frame // 6) % 2) * 8
        else
            local wing = ({ 0, 1, 2, 1 })[(G.frame // 5 + d.anim) % 4 + 1]
            local climbing = d.state == "flee" or (d.vy < -0.4 * d.speed)
            frame = (climbing and 3 or 0) + wing
            face = (d.state == "flee" and (d.last_face or 0)) or (d.vx < 0 and 8 or 0)
            d.last_face = face
        end
        return d.kind * 16 + frame + face
    end

    -- ── the round ──
    local function launch()
        if G.test then log(string.format("frame %d: duck %d", G.frame, G.idx)) end
        G.targets, turn_hits = {}, {}
        for slot = 0, B.at_once() - 1 do
            table.insert(G.targets, new_duck(slot))
        end
        G.shells = 3
        fact.shells = 3
        G.phase, G.t, G.flight = "fly", 0, FLIGHT
        dog.show = false
    end

    function M.begin()
        G.screen = 1
        fact.screen = 1
        fact.pink_sky = false
        G.next_round = M.round
        G.on_over = M.over
        M.round()
    end

    function M.round()
        B.new_round()
        G.targets = {}
        dog.x, dog.y, dog.show, dog.front = -60, WALK_Y, true, true
        script = walk_script()
        G.phase, G.t = "walk", 0
        B.say("ROUND", tostring(G.round))
        G.music.stop()
        G.music.tune("intro")
    end

    -- Game over: the dog comes up laughing and stays.
    function M.over()
        script = { { "rise", 400, x = 100, laugh = true, held = {}, forever = true } }
        dog.show = false
    end

    function M.can_hit(d)
        return d.state == "fly"
    end

    function M.box(d)
        return { x = d.x + 3, y = d.y + 3, w = 26, h = 26 }
    end

    function M.shoot(x, y)
        local best, far = nil, 1e9
        for _, d in ipairs(G.targets) do
            if d.state == "fly" then
                local dx, dy = x - (d.x + 16), y - (d.y + 15)
                if math.abs(dx) <= 15 and math.abs(dy) <= 14 then
                    local dd = dx * dx + dy * dy
                    if dd < far then best, far = d, dd end
                end
            end
        end
        if G.test then log(string.format("frame %d: shot at %d,%d: %s", G.frame, x, y, best and "hit" or "miss")) end
        if best then
            best.state, best.t = "hit", 32
            G.marks[G.idx + best.slot] = 1
            B.add(B.worth(best.kind, G.round), best.x + 16, best.y + 4)
        end
        if G.shells == 0 then
            -- Out of shells: what is still flying gets away.
            for _, d in ipairs(G.targets) do
                d.late = 18
            end
        end
    end

    function M.step()
        G.t += 1
        if G.phase == "walk" then
            if G.t == 150 then B.say(nil) end
            if dog_step() and G.t > 30 then
                B.say(nil)
                G.phase, G.t = "launch", 0
            end
        elseif G.phase == "launch" then
            if G.t >= 24 then launch() end
        elseif G.phase == "fly" then
            G.flight -= 1
            local flying, away = 0, false
            for _, d in ipairs(G.targets) do
                if d.late then
                    d.late -= 1
                    if d.late <= 0 then
                        d.late = nil
                        flee(d)
                    end
                end
                if G.flight <= 0 then flee(d) end
                duck_step(d)
                if d.state == "fly" or d.state == "hit" or d.state == "fall" or d.state == "flee" then
                    flying += 1
                end
                if d.state == "flee" then away = true end
            end
            if away and not fact.pink_sky then
                fact.pink_sky = true
                B.say("FLY AWAY")
                G.music.away()
            end
            if flying == 0 then
                G.phase, G.t = "after", 0
            end
        elseif G.phase == "after" then
            if G.t == 10 then
                fact.pink_sky = false
                B.say(nil)
            end
            if G.t >= 34 then
                local held = {}
                local sum = 0
                for _, d in ipairs(turn_hits) do
                    table.insert(held, d.kind)
                    sum += d.x
                end
                if #held > 0 then
                    local x = math.clamp(sum / #held - 12, 16, 184)
                    script = { { "rise", 70, x = x, held = held } }
                else
                    script = { { "rise", 80, x = 100, laugh = true, held = {} } }
                end
                G.phase, G.t = "dog", 0
            end
        elseif G.phase == "dog" then
            if dog_step() then
                G.idx += B.at_once()
                G.targets = {}
                if G.idx > 10 then
                    G.phase, G.t = "tally", 0
                else
                    G.phase, G.t = "launch", 0
                end
            end
        elseif G.phase == "tally" or G.phase == "judged" then
            dog_step()
            B.tally_step()
        end
    end

    function M.draw()
        local ducks = {}
        for _, d in ipairs(G.targets) do
            local shown = d.state ~= "down" and d.state ~= "gone"
            table.insert(ducks, { x = math.floor(d.x), y = math.floor(d.y), cell = duck_cell(d), show = shown })
        end
        model.ducks = ducks
        G.put("dog.x", math.floor(dog.x))
        G.put("dog.y", math.floor(dog.y))
        G.put("dog.cell", dog.cell)
        G.put("dog.show", dog.show)
        G.put("dog.front", dog.front)
        -- What it holds hangs from its paws: the right one, then the left.
        local held = {}
        local s = script[1]
        if dog.show and s and s[1] == "rise" and not s.laugh then
            local paws = { { 51, 12 }, { 5, 12 } }
            for i, kind in ipairs(s.held) do
                local p = paws[i]
                table.insert(held, { x = math.floor(dog.x) + p[1] - 14, y = math.floor(dog.y) + p[2] - 2, cell = kind * 16 + 7 })
            end
        end
        model.held = held
    end

    return M
end
