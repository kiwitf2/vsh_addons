// Give full crits for rest of round
characterTraitsClasses.push(class extends CharacterTrait
{
    function OnTickAlive(timeDelta)
    {
        local currentGlow = GetPropBool(player, "m_bGlowEnabled");
        local mercsAlive = GetAliveMercCount();
        if(!currentGlow && mercsAlive == 1){
            SetPropBool( player, "m_bGlowEnabled", true );
        }
    }
});