-- The board on the dirt —the round, the shells, the ten marks and the
-- score— and what is the same for every game: what a hit is worth, how many
-- a round asks for, the boxes that say things, and the end of a round, when
-- the marks are put in order and counted.

return function(G)
    local B = {}
    G.board = B

    -- What a round asks for, and what things are worth in it.
    function B.quota(r)
        if r <= 10 then return 6 end
        if r <= 12 then return 7 end
        if r <= 14 then return 8 end
        if r <= 19 then return 9 end
        return 10
    end
    function B.worth(kind, r)
        local row = r <= 5 and { 500, 1000, 1500 } or (r <= 10 and { 800, 1600, 2400 } or { 1000, 2000, 3000 })
        return row[kind + 1]
    end
    function B.clay_worth(r)
        return r <= 5 and 500 or (r <= 10 and 800 or 1000)
    end
    function B.bonus(r)
        if r <= 10 then return 10000 end
        if r <= 15 then return 15000 end
        if r <= 20 then return 20000 end
        return 30000
    end

    function B.say(a, b)
        text.line1, text.line2 = a or "", b or ""
        fact.banner = (a == nil and 0) or (b == nil and 1) or 2
    end

    function B.add(points, x, y)
        G.score = math.min(G.score + points, 999999)
        table.insert(G.pops, { x = math.floor(x), y = math.floor(y), label = tostring(points), life = 70 })
    end

    -- A new round: ten marks white, three shells.
    function B.new_round()
        G.marks = {}
        for i = 1, 10 do
            G.marks[i] = 0
        end
        G.idx, G.shells = 1, 3
        fact.shells = 3
        fact.quota = B.quota(G.round)
        fact["board.clay"] = G.screen == 2
        text.round_t = "R=" .. G.round
    end

    -- How many of the targets now in the air: one in game A, two in B and C.
    function B.at_once()
        return G.game == 0 and 1 or 2
    end

    function B.draw()
        G.say_text("score_t", string.format("%06d", G.score))
        local clay = G.screen == 2 and 2 or 0
        local list = {}
        local now = G.phase == "fly" or G.phase == "launch"
        for i = 1, 10 do
            local m = G.marks[i] or 0
            -- The ones in the air now blink; at the end of a good round, all do.
            local lit = true
            if m == 0 and now and i >= G.idx and i < G.idx + B.at_once() then
                lit = (G.frame // 8) % 2 == 0
            end
            if G.phase == "judged" and G.passed and m == 1 then
                lit = (G.frame // 8) % 2 == 0
            end
            table.insert(list, { cell = clay + (m == 1 and 1 or 0), lit = lit })
        end
        model.marks = list
    end

    -- ── the end of a round ──
    -- The hits go to the left one place at a time, with a ding each, and then
    -- they are counted against what the round asked for.
    function B.tally_step()
        G.t += 1
        if G.phase == "tally" then
            if G.t % 10 ~= 0 then
                return
            end
            for i = 1, 9 do
                if G.marks[i] ~= 1 and G.marks[i + 1] == 1 then
                    G.marks[i], G.marks[i + 1] = G.marks[i + 1], G.marks[i]
                    G.music.ding()
                    return
                end
            end
            local hits = 0
            for i = 1, 10 do
                if G.marks[i] == 1 then hits += 1 end
            end
            G.hits = hits
            G.passed = hits >= B.quota(G.round)
            log(string.format("round %d: %d of 10 (asked %d), score %d", G.round, hits, B.quota(G.round), G.score))
            G.phase, G.t = "judged", 0
            if hits == 10 then
                local bonus = B.bonus(G.round)
                G.score = math.min(G.score + bonus, 999999)
                B.say("PERFECT!!", tostring(bonus))
                G.wait = math.ceil(G.music.tune("perfect") / 1000 * 60) + 90
            elseif G.passed then
                G.wait = math.ceil(G.music.tune("clear") / 1000 * 60) + 50
            else
                B.say("GAME OVER")
                G.wait = math.ceil(G.music.tune("over") / 1000 * 60) + 150
                if G.on_over then G.on_over() end
            end
        elseif G.phase == "judged" then
            if G.t >= G.wait then
                B.say(nil)
                if G.passed then
                    G.round += 1
                    G.next_round()
                else
                    local slot = G.game + 1
                    if G.score > G.top[slot] then
                        G.top[slot] = G.score
                        G.save()
                    end
                    G.show_title()
                end
            end
        end
    end

    return B
end
