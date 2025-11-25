SMODS.Atlas({key = "VTudeJokers", path = "Jokers.png", px = 71, py = 95, atlas_table = "ASSET_ATLAS"}):register()
SMODS.Atlas({key = "VTudeConsumables", path = "Consumables.png", px = 71, py = 95, atlas_table = "ASSET_ATLAS"}):register()
SMODS.load_file("hooks.lua")()
--THIS IS STUPID
--SMODS.ConsumableType {
--    key = "vtude_GrilledChicken",
--    primary_colour = HEX("964616"),
--    secondary_colour = HEX("964616"),
--    collection_rows = { 1, 1 },
--    shop_rate = 0
--}
--
--SMODS.Consumable {
--    key = 'grilledchicken',
--    set = 'vtude_GrilledChicken',
--    atlas = 'VTudeConsumables',
--    hidden = true,
--    loc_txt = {
--        name = 'Grilled Chicken',
--        text = {
--            "WIP",
--        }
--    },
--    pos = { x = 0, y = 1},
--}

SMODS.Joker {
    key = "scratchedjoker",
    pos = { x = 0, y = 0 },
    rarity = 3,
    blueprint_compat = false,
    cost = 8,
    atlas = 'VTudeJokers',
    config = { },
    credits = {
        art = "Squeakitties",
        idea = "Squeakitties"
    },
    loc_txt = {
        name = "Scratched Joker",
        text = {
            "Hands of five cards with {C:attention}ONLY 3s, 4s and Aces{} are a new hand type {C:attention}Full Home{}",
        },
    }
}

SMODS.Joker {
    key = 'infinitejoker',
    loc_txt = {
        name = 'Infinite Joker Glitch',
        text = {
            "Add a permanent copy of every {C:attention}#2#{}th card drawn",
            "to deck and draw it to {C:attention}hand{}",
            "{C:inactive}(#1#/#2#){}",
        }
    },
    config = { extra = {draw_tally = 0, draws = 20 } },
    rarity = 1,
    atlas = 'VTudeJokers',
    pos = { x = 1, y = 0 },
    cost = 5,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.draw_tally, card.ability.extra.draws } }
    end,
    calculate = function(self, card, context)
        if context.hand_drawn
                or context.other_drawn
                and not context.blueprint then
            for _, playing_card in ipairs(context.hand_drawn or context.other_drawn) do
                card.ability.extra.draw_tally = card.ability.extra.draw_tally + 1
                if card.ability.extra.draw_tally >= card.ability.extra.draws then
                    local _card = copy_card(playing_card)
                    _card:add_to_deck()
                    G.deck.config.card_limit = G.deck.config.card_limit + 1
                    table.insert(G.playing_cards, _card)
                    G.hand:emplace(_card)
                    card.ability.extra.draw_tally = card.ability.extra.draw_tally - card.ability.extra.draws
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            _card:start_materialize()
                            return true
                        end
                    }))
                    SMODS.calculate_effect({message = localize('k_copied_ex'), colour = G.C.CHIPS}, card)
                    SMODS.calculate_context({ playing_card_added = true, cards = { _card } })
                end
            end
        end
    end
}

SMODS.Joker {
    key = "planetarytravel",
    pos = { x = 2, y = 0 },
    rarity = 2,
    blueprint_compat = false,
    cost = 7,
    atlas = 'VTudeJokers',
    config = { },
    loc_txt = {
        name = "Planetary Travel",
        text = {
            "Using a {C:planet}Planet{} card will also level up Adjacent Hands",
        },
    }
}

SMODS.Joker {
    key = "evilhiker",
    pos = { x = 3, y = 0 },
    rarity = 3,
    blueprint_compat = false,
    cost = 8,
    atlas = 'VTudeJokers',
    config = { },
    loc_txt = {
        name = "Placeholdery Mc Placeface",
        text = {
            "[WIP] Doesn't Work",
            "5 Card Hands with ONLY cards you've never played before are {C:attention}Straight Flushes{}",
        },
    },
    calculate = function(self, card, context)
        if context.evaluate_poker_hand then
            if #context.full_hand < 5 then
                return {}
            end
            local is_unplayed = true
            for _, card in ipairs(context.full_hand) do
                if card.base.times_played > 0 then is_unplayed = false end
            end
            if is_unplayed then return { replace_scoring_name = "Straight Flush" } end
        end
    end
}

SMODS.PokerHandPart {
    key = 'vtude_fullhome',
    func = function(hand)
        if #hand < 5 then
            return {}
        end
        if not next(SMODS.find_card("j_vtude_scratchedjoker")) then
            return {}
        end
        local validCards = 0
        local candidates = { [4] = {}, [14] = {}, [3] = {}}
        for _, card in ipairs(hand) do
            local id = card:get_id()
            if id == 4 or id == 14 or id == 3 then
                validCards = validCards+1
                table.insert(candidates[id], card)
            end
        end
        local available_ranks = {}
        for rank, cards_list in pairs(candidates) do
            if #cards_list > 0 then
                table.insert(available_ranks, rank)
            end
        end
        local total_ranks = #available_ranks
        if total_ranks < 3 or validCards < 5 then
            return {}
        end
        return {hand}
    end
}

SMODS.PokerHand({
    key = "vtude_fullhome",
    chips = 80,
    mult = 8,
    l_chips = 35,
    l_mult = 4,
    visible = function(self)
        return next(SMODS.find_card("j_vtude_scratchedjoker", true))
    end,
    example = {
        { 'S_4', true },
        { 'H_A', true },
        { 'C_A', true },
        { 'S_3', true },
        { 'C_3', true },
    },
    evaluate = function(parts,hand)
        return parts.vtude_fullhome
    end
})

SMODS.PokerHand {
    key = "vtude_flushhome",
    visible = false,
    mult = 17,
    chips = 170,
    l_mult = 4,
    l_chips = 45,
    example = {
        { 'S_4', true },
        { 'S_A', true },
        { 'S_A', true },
        { 'S_3', true },
        { 'S_3', true }
    },
    evaluate = function(parts, hand)
        if not next(parts.vtude_fullhome) or not next(parts._flush) then return {} end
        return { SMODS.merge_lists(parts.vtude_fullhome, parts._flush) }
    end
}

SMODS.Consumable {
    key = 'greensun',
    set = 'Planet',
    atlas = 'VTudeConsumables',
    set_card_type_badge = function(self, card, badges)
        badges[#badges+1] = create_badge(localize('vtude_sun_q'), G.C.GREEN, G.C.BLACK, 1.2 )
    end,
    config = { hand_type = 'vtude_fullhome', softlock = true },
    pos = { x = 0, y = 0 },
    generate_ui = 0,
    credits = {
        idea = "Squeakitties"
    },
    process_loc_text = function(self)
        local target_text = G.localization.descriptions[self.set]['c_mercury'].text
        SMODS.Consumable.process_loc_text(self)
        G.localization.descriptions[self.set][self.key] = {}
        G.localization.descriptions[self.set][self.key].text = target_text
    end
}

SMODS.Consumable {
    key = 'skaia',
    set = 'Planet',
    atlas = 'VTudeConsumables',
    set_card_type_badge = function(self, card, badges)
        badges[#badges+1] = create_badge(localize('vtude_sky_q'), G.C.SECONDARY_SET.Planet, G.C.WHITE, 1.2 )
    end,
    config = { hand_type = 'vtude_flushhome', softlock = true },
    pos = { x = 1, y = 0 },
    generate_ui = 0,
    process_loc_text = function(self)
        local target_text = G.localization.descriptions[self.set]['c_mercury'].text
        SMODS.Consumable.process_loc_text(self)
        G.localization.descriptions[self.set][self.key] = {}
        G.localization.descriptions[self.set][self.key].text = target_text
    end
}