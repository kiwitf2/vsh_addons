local jumped = false;
local jumpCooldown = 3;
local lastDisplayTime = Time()

function BraveJumpTrait::OnFrameTickAlive()
{
    local buttons = GetPropInt(boss, "m_nButtons");

    if (!boss.IsOnGround())
    {
        if (jumpStatus == BOSS_JUMP_STATUS.WALKING)
            jumpStatus = BOSS_JUMP_STATUS.JUMP_STARTED;
        else if (jumpStatus == BOSS_JUMP_STATUS.JUMP_STARTED && !(buttons & IN_JUMP))
            jumpStatus = BOSS_JUMP_STATUS.CAN_DOUBLE_JUMP;
    }
    else
        jumpStatus = BOSS_JUMP_STATUS.WALKING;

    if (buttons & IN_JUMP && jumpStatus == BOSS_JUMP_STATUS.CAN_DOUBLE_JUMP)
    {
        if(Time() < lastTimeJumped + jumpCooldown)
        {
            if (lastDisplayTime + 0.7 <= Time())
            {
                // shows brave jump timer in chat upon trying to doublejump (to counteract some players not being able to see game_text_tf)
                // hello hi kiwi here probablyt a better way to do this but im stupid :steamhappy:
                local jumpTimeCeil = ceil(3 - (Time() - lastTimeJumped))
                ClientPrint(boss, 3, "\x03Brave Jump ready in " + jumpTimeCeil + " seconds.")
                lastDisplayTime = Time()
            }
            return
        }

        lastTimeJumped = Time();
        jumped = true;
        if (!IsRoundSetup() && Time() - voiceLinePlayed > 1.5)
        {
            voiceLinePlayed = Time();
            EmitPlayerVO(boss, "jump");
        }

        jumpStatus = BOSS_JUMP_STATUS.DOUBLE_JUMPED;
        Perform();
    }

    if (!jumped && Time() > lastTimeJumped + 30)
    {
        NotifyJump();
    }
}

local cooldown_text_tf;

function BraveJumpTrait::Perform()
{
    local buttons = GetPropInt(boss, "m_nButtons");
    local eyeAngles = boss.EyeAngles();
    local forward = eyeAngles.Forward();
    forward.z = 0;
    forward.Norm();
    local left = eyeAngles.Left();
    left.z = 0;
    left.Norm();

    local forwardmove = 0
    if (buttons & IN_FORWARD)
        forwardmove = 1;
    else if (buttons & IN_BACK)
        forwardmove = -1;
    local sidemove = 0
    if (buttons & IN_MOVELEFT)
        sidemove = -1;
    else if (buttons & IN_MOVERIGHT)
        sidemove = 1;

    local newVelocity = Vector(0,0,0);
    newVelocity.x = forward.x * forwardmove + left.x * sidemove;
    newVelocity.y = forward.y * forwardmove + left.y * sidemove;
    newVelocity.Norm();
    newVelocity *= 300;
    newVelocity.z = jumpForce

    local currentVelocity = boss.GetAbsVelocity();
    if (currentVelocity.z < 300)
        currentVelocity.z = 0;

    SetPropEntity(boss, "m_hGroundEntity", null);
    boss.SetAbsVelocity(currentVelocity + newVelocity);

    cooldown_text_tf = SpawnEntityFromTable("game_text_tf", {
        message = "Brave Jump ready in "+jumpCooldown+"...",
        icon = "ico_notify_flag_moving_alt",
        background = 0,
        display_to_team = TF_TEAM_BOSS
    });

    EntFireByHandle(cooldown_text_tf, "Display", "", 0.1, boss, boss);
    for(local i = 1; i < jumpCooldown; i++)
    {
        EntFireByHandle(cooldown_text_tf, "AddOutput", "message Brave Jump ready in "+(jumpCooldown - i)+"...", i - 0.1, boss, boss);
        EntFireByHandle(cooldown_text_tf, "Display", "", i, boss, boss);
    }
    EntFireByHandle(cooldown_text_tf, "AddOutput", "message Brave Jump ready!", jumpCooldown - 0.1, boss, boss);
    EntFireByHandle(cooldown_text_tf, "AddOutput", "background "+TF_TEAM_BOSS, jumpCooldown - 0.1, boss, boss);
    EntFireByHandle(cooldown_text_tf, "Display", "", jumpCooldown, player, player);
    EntFireByHandle(cooldown_text_tf, "Kill", "", jumpCooldown+0.1, player, player);
}

function BraveJumpTrait::NotifyJump()
{
    local text_tf = SpawnEntityFromTable("game_text_tf", {
        message = "#ClassTips_1_2",
        icon = "ico_notify_flag_moving_alt",
        background = TF_TEAM_BOSS,
        display_to_team = TF_TEAM_BOSS
    });
    EntFireByHandle(text_tf, "Display", "", 0.1, player, player);
    EntFireByHandle(text_tf, "Kill", "", 1, player, player);
}