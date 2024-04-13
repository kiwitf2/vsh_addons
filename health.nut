// Separate function so we can get maxhealth without setting the maxHealth variable.
::GetStartingHealth <- function(mercCount)
{
    if (mercCount < 2)
    {
        return 1000;
    } else if (mercCount > 32) {
        local baseHealth = GetStartingHealth(32);
        local unroundedH = baseHealth * mercCount / 32;
        local roundedH = floor(unroundedH / 100) * 100;
        return roundedH;
    }
    local unrounded = mercCount * mercCount * API_GetFloat("health_factor") + (mercCount < 6 ? 1300 : 2000);
    local rounded = floor(unrounded / 100) * 100;
    return rounded;
}

// OVERRIDE: Reduce health for higher player counts
::CalcBossMaxHealth <- function(mercCount)
{
    local health = GetStartingHealth(mercCount);
    maxHealth = health;
    return health;
}

// Track current health for damage calculations.
AddListener("tick_always", 5, function(timeDelta)
{
    if(!IsRoundOver() && IsAnyBossAlive())
    {
        local boss = GetBossPlayers()[0];
        currentHealth = boss.GetHealth();
    }
});