-- Game C: clays. Two at a time are thrown from the trap house, up and away
-- towards the far trees, smaller as they go; three shells for the pair. A clay
-- not hit before it is lost in the distance is a miss.

return function(G)
    local R = {}
    G.range = R
    local B = G.board

    local TRAP_X, TRAP_Y = 128, 168

    local function new_clay(slot)
        local left = (slot == 0) == (math.random() < 0.5)
        return {
            slot = slot, state = "wait", t = 0, wait = slot * 14,
            span = math.max(72, 150 - (G.round - 1) * 6),
            sx = TRAP_X + (math.random() - 0.5) * 12, sy = TRAP_Y,
            ex = left and (24 + math.random() * 80) or (152 + math.random() * 80),
            ey = 118 + math.random() * 14,
            apex = 50 + math.random() * 40,
            x = TRAP_X, y = TRAP_Y,
        }
    end

    local function where(c)
        local f = c.t / c.span
        local e = 1 - (1 - f) * (1 - f)
        c.x = c.sx + (c.ex - c.sx) * e
        c.y = c.sy + (c.ey - c.sy) * e - c.apex * math.sin(math.pi * math.min(f * 1.15, 1))
        c.size = math.min(7, math.floor(f * 8.5))
        c.r = 8 * (1 - f * 0.85) + 1.5
    end

    local function clay_step(c)
        if c.state == "wait" then
            c.wait -= 1
            if c.wait <= 0 then
                c.state = "fly"
                G.music.launch()
            end
        elseif c.state == "fly" then
            c.t += 1
            where(c)
            if c.t >= c.span then
                c.state = "gone"
                G.marks[G.idx + c.slot] = 2
            end
        elseif c.state == "broken" then
            c.t += 1
            c.y += 0.6
            if c.t >= c.until_ then
                c.state = "down"
            end
        end
    end

    function R.begin()
        G.screen = 2
        fact.screen = 2
        fact.pink_sky = false
        G.put("dog.show", false)
        G.next_round = R.round
        G.on_over = nil
        R.round()
    end

    function R.round()
        B.new_round()
        G.targets = {}
        G.phase, G.t = "intro", 0
        B.say("ROUND", tostring(G.round))
        G.music.stop()
        G.wait = math.ceil(G.music.tune("range") / 1000 * 60) + 20
    end

    function R.can_hit(c)
        return c.state == "fly"
    end

    function R.box(c)
        local r = math.ceil(c.r + 2)
        return { x = c.x - r, y = c.y - r, w = r * 2, h = r * 2 }
    end

    function R.shoot(x, y)
        local best, far = nil, 1e9
        for _, c in ipairs(G.targets) do
            if c.state == "fly" then
                local dx, dy = x - c.x, y - c.y
                local dd = dx * dx + dy * dy
                if dd <= (c.r + 3) ^ 2 and dd < far then
                    best, far = c, dd
                end
            end
        end
        if best then
            best.state, best.t, best.until_ = "broken", 0, 26
            G.marks[G.idx + best.slot] = 1
            G.music.smash((best.x - 128) / 128)
            B.add(B.clay_worth(G.round), best.x, best.y - 10)
        end
    end

    function R.step()
        G.t += 1
        if G.phase == "intro" then
            if G.t >= G.wait then
                B.say(nil)
                G.phase, G.t = "launch", 0
            end
        elseif G.phase == "launch" then
            if G.t >= 30 then
                G.targets = { new_clay(0), new_clay(1) }
                G.shells = 3
                fact.shells = 3
                G.phase, G.t = "fly", 0
            end
        elseif G.phase == "fly" then
            local busy = 0
            for _, c in ipairs(G.targets) do
                clay_step(c)
                if c.state ~= "gone" and c.state ~= "down" then busy += 1 end
            end
            if busy == 0 then
                G.phase, G.t = "after", 0
            end
        elseif G.phase == "after" then
            if G.t >= 36 then
                G.idx += 2
                G.targets = {}
                if G.idx > 10 then
                    G.phase, G.t = "tally", 0
                else
                    G.phase, G.t = "launch", 0
                end
            end
        else
            B.tally_step()
        end
    end

    function R.draw()
        local list = {}
        for _, c in ipairs(G.targets) do
            local cell = c.state == "broken" and (8 + (c.t // 7) % 2) or (c.size or 0)
            table.insert(list, { x = math.floor(c.x), y = math.floor(c.y), cell = cell, show = c.state == "fly" or c.state == "broken" })
        end
        model.clays = list
    end

    return R
end
