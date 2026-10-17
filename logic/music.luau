-- The sounds: the console's two square voices, its triangle and its noise,
-- made with tones. A tune is written as notes (`"t150 o5 l8 c e g >c4"`, the
-- way music was typed into machines then) and asked for all at once: each note
-- with its own `delay`, which the mixer keeps to the sample.
--
-- t tempo · o octave · l length of a note left without one · > < an octave up
-- or down · c d e f g a b a note, # or + sharp, - flat, then its length (4 a
-- quarter, 8 an eighth…) and a dot for half as long again · r a rest.
-- All the tunes are this game's own.

return function(G)
    local S = {}
    G.music = S

    local SEMI = { c = -9, d = -7, e = -5, f = -4, g = -2, a = 0, b = 2 }
    local function hz(octave, semi)
        return 440 * 2 ^ ((octave - 4) + semi / 12)
    end

    local function tone(t)
        if G.test and G.test.tones then
            log(string.format("tone %s %.0f Hz %.0f ms at %.0f", t.wave or "square", t.freq or 0, t.ms or 0, t.delay or 0))
            return nil
        end
        if G.quiet then
            return nil
        end
        t.volume = (t.volume or 0.2) * G.loud
        return sound.tone(t)
    end
    S.tone = tone

    -- One voice of a tune: how long it lasts, in milliseconds.
    local function voice(v, start)
        local s = string.lower(v.notes)
        local tempo, octave, length = 120, 4, 8
        local at, i = start or 0, 1
        local function number()
            local d = string.match(s, "^%d+", i)
            if d then
                i += #d
                return tonumber(d)
            end
            return nil
        end
        while i <= #s do
            local ch = string.sub(s, i, i)
            i += 1
            if ch == "t" then
                tempo = number() or tempo
            elseif ch == "o" then
                octave = number() or octave
            elseif ch == "l" then
                length = number() or length
            elseif ch == ">" then
                octave += 1
            elseif ch == "<" then
                octave -= 1
            elseif SEMI[ch] or ch == "r" then
                local semi = SEMI[ch] or 0
                local nx = string.sub(s, i, i)
                if nx == "#" or nx == "+" then
                    semi += 1
                    i += 1
                elseif nx == "-" then
                    semi -= 1
                    i += 1
                end
                local n = number() or length
                local ms = 240000 / tempo / n
                if string.sub(s, i, i) == "." then
                    ms *= 1.5
                    i += 1
                end
                if ch ~= "r" then
                    tone({
                        wave = v.wave or "square", duty = v.duty or 0.5,
                        freq = hz(octave, semi), ms = ms * (v.gate or 0.85),
                        attack = 2, release = v.release or math.min(40, ms * 0.3),
                        volume = v.volume or 0.16, delay = at,
                    })
                end
                at += ms
            end
        end
        return at
    end

    -- A tune of several voices; answers how long it lasts, in milliseconds.
    function S.play(voices)
        local longest = 0
        for _, v in ipairs(voices) do
            longest = math.max(longest, voice(v))
        end
        return longest
    end

    function S.stop()
        sound.stop()
    end

    -- ── the tunes ──
    S.tunes = {
        -- The title: a bright call.
        title = {
            { notes = "t160 o5 l16 c e g >c8 <g8 e8 g4", duty = 0.25 },
            { notes = "t160 o3 l8 c g c g c4", wave = "triangle", volume = 0.22 },
        },
        -- The dog sets out across the field: a short march.
        intro = {
            { notes = "t150 o5 l8 g e g >c4 <g4 a g e c d4 r8 g e g >c4 <b4 a g f d c4. r8", duty = 0.25 },
            { notes = "t150 o4 l8 e c e g4 e4 f e c <g b4 r8 >e c e g4 g4 f e d <b >c4. r8", duty = 0.5, volume = 0.1 },
            { notes = "t150 o3 l4 c g c g f g c g c g f g c2", wave = "triangle", volume = 0.24 },
        },
        -- Game C: a quicker start.
        range = {
            { notes = "t170 o5 l8 c d e g e g >c4 <g4 >c4", duty = 0.25 },
            { notes = "t170 o3 l4 c g c g c4", wave = "triangle", volume = 0.24 },
        },
        -- The dog shows what it found.
        caught = {
            { notes = "t180 o5 l16 c e g >c8 <g16 >c8.", duty = 0.25 },
            { notes = "t180 o3 l8 c g >c4", wave = "triangle", volume = 0.22 },
        },
        caught2 = {
            { notes = "t180 o5 l16 e g >c e8 c16 e8.", duty = 0.25 },
            { notes = "t180 o4 l16 c e g >c8 <g16 >c8.", duty = 0.5, volume = 0.1 },
            { notes = "t180 o3 l8 c g >c4", wave = "triangle", volume = 0.22 },
        },
        -- The dog laughs: two notes, back and forth, quick.
        laugh = {
            { notes = "t200 o5 l16 g e g e g e g e g e g e", duty = 0.125, gate = 0.6, volume = 0.14 },
        },
        -- Enough hits: on to the next round.
        clear = {
            { notes = "t160 o5 l8 c e g e f a >c4 <b16 >c4.", duty = 0.25 },
            { notes = "t160 o3 l8 c g e g f >c <c4 g16 c4.", wave = "triangle", volume = 0.22 },
        },
        -- All ten.
        perfect = {
            { notes = "t170 o5 l16 c e g >c <e g >c e <g >c e g8 r16 e g4.", duty = 0.25 },
            { notes = "t170 o4 l16 g >c e g <c e g >c <e g >c e8 r16 c e4.", duty = 0.5, volume = 0.1 },
            { notes = "t170 o3 l8 c g e g c g c4 r16 c4.", wave = "triangle", volume = 0.22 },
        },
        -- Too few: the end.
        over = {
            { notes = "t110 o5 l8 g f e d c4 <g4 >c2", duty = 0.5 },
            { notes = "t110 o3 l8 e d c <b a4 g4 >c2", wave = "triangle", volume = 0.22 },
        },
    }

    function S.tune(name)
        return S.play(S.tunes[name])
    end

    -- ── the sounds ──
    function S.shot()
        tone({ wave = "noise", freq = 1800, to = 140, ms = 240, release = 200, volume = 0.32 })
        tone({ wave = "square", freq = 200, to = 55, ms = 110, release = 80, volume = 0.16 })
    end
    function S.quack(pan)
        tone({ wave = "square", duty = 0.25, freq = 760, to = 520, ms = 70, volume = 0.1, pan = pan })
        tone({ wave = "square", duty = 0.25, freq = 680, to = 430, ms = 110, volume = 0.1, pan = pan, delay = 95 })
    end
    function S.flap(pan)
        tone({ wave = "noise", freq = 300, to = 200, ms = 50, volume = 0.05, pan = pan })
    end
    function S.fall(ms, pan)
        tone({ wave = "square", duty = 0.5, freq = 1500, to = 330, ms = ms, release = 60, volume = 0.1, pan = pan })
    end
    function S.thud(pan)
        tone({ wave = "noise", freq = 320, to = 60, ms = 150, release = 120, volume = 0.24, pan = pan })
        tone({ wave = "triangle", freq = 130, to = 50, ms = 170, volume = 0.26, pan = pan })
    end
    function S.bark()
        tone({ wave = "square", duty = 0.25, freq = 340, to = 220, ms = 80, volume = 0.16 })
        tone({ wave = "square", duty = 0.25, freq = 380, to = 230, ms = 90, volume = 0.16, delay = 150 })
    end
    function S.jump()
        tone({ wave = "square", duty = 0.5, freq = 300, to = 900, ms = 220, volume = 0.1 })
    end
    function S.rustle()
        tone({ wave = "noise", freq = 900, to = 400, ms = 260, release = 200, volume = 0.12 })
    end
    function S.ding()
        tone({ wave = "square", duty = 0.125, freq = 1760, ms = 60, release = 40, volume = 0.1 })
    end
    function S.blip()
        tone({ wave = "square", duty = 0.25, freq = 990, ms = 40, release = 20, volume = 0.1 })
    end
    function S.launch()
        tone({ wave = "noise", freq = 2600, to = 700, ms = 260, release = 180, volume = 0.16 })
        tone({ wave = "square", duty = 0.125, freq = 420, to = 980, ms = 200, volume = 0.06 })
    end
    function S.smash(pan)
        tone({ wave = "noise", freq = 2400, to = 300, ms = 180, release = 140, volume = 0.26, pan = pan })
    end
    function S.away()
        tone({ wave = "square", duty = 0.25, freq = 600, to = 1200, ms = 400, volume = 0.08 })
    end

    return S
end
