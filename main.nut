::maxHealth <- 100000; // Don't initialize to zero or else you get random divide by zeroes.
::currentHealth <- 100000;

// Helper to erase listeners we want to replace.
function EraseListener(event, order, indexToRemove)
{
    local listenerToRemove = null;
    if(listeners[event] == null) {
        return;
    }
    local count = 0;
    for(local i = 0; i < listeners[event].len(); i++)
    {
        if(listeners[event][i][0] == order && count == indexToRemove) {
            listenerToRemove = i;
            break;
        } else if (listeners[event][i][0] == order) {
            count++;
        }
    }
    if(listenerToRemove != null)
    {

        local sizeBefore = listeners[event].len();
        listeners[event].remove(listenerToRemove);
        local sizeAfter = listeners[event].len();

        if(sizeAfter - sizeBefore == 1)
        {
            printl("Removed listener "+event+" "+order);
        } else {
            printl("ERROR in removing listener "+event+" "+order);
        }
    }
}

IncludeScript("vsh_addons/health.nut");
IncludeScript("vsh_addons/damage_scoring.nut");
IncludeScript("vsh_addons/round_time.nut");
IncludeScript("vsh_addons/control_point.nut");
IncludeScript("vsh_addons/brave_jump_dampening.nut");
IncludeScript("vsh_addons/rps_damage_increase.nut");
IncludeScript("vsh_addons/anti_afk.nut");

// OVERRIDE: Clamp stab damage (and market gardner) to 5000 max
function CalcStabDamage(victim)
{
    return clamp(GetPerPlayerDamageQuota(victim), 500, 5000);
}
