local ref = level_up_hand
function level_up_hand(card, hand, instant, amount, ...)
    if next(SMODS.find_card("j_vtude_planetarytravel")) and (card.config.center.set == "Planet" or card.config.center.set == "Star")then
        local last=nil
        local next=nil
        local find=false
        for _,k in pairs(G.handlist) do
            local v=G.GAME.hands[k]
            if find==true and v.visible == true then
                next=k;break
            end
            if k==hand then
                find=true
            end
            if find==false and v.visible == true then
                last=k
            end
        end
            if last~=nil then
                update_hand_text({sound = 'button', volume = 0.7, pitch = 0.18, delay = 0.1}, {handname=localize(hand, 'poker_hands'),chips = G.GAME.hands[hand].chips, mult = G.GAME.hands[hand].mult, level=G.GAME.hands[hand].level})
                ref(card, last, true, amount)
            end
            if next~=nil then
                update_hand_text({sound = 'button', volume = 0.7, pitch = 0.18, delay = 0.1}, {handname=localize(hand, 'poker_hands'),chips = G.GAME.hands[hand].chips, mult = G.GAME.hands[hand].mult, level=G.GAME.hands[hand].level})
                ref(card, next, true, amount)
            end
        -- update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.1}, {handname=localize(hand, 'poker_hands'),chips = G.GAME.hands[hand].chips, mult = G.GAME.hands[hand].mult, level=G.GAME.hands[hand].level})
    end
    local val = ref(card,hand,instant,amount, ...)
    return val
end