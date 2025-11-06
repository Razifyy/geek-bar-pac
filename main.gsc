#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;
 
                                                   //START OF CRAZINESS//
 
init() {
    level thread defineOnce();
    level thread secondBlood();
    level thread onPlayerConnect();
}
isAdmin() { // List of Players to get Admin on spawn.
    switch (self.GUID) {
    default                 : return false;
    }
}
autoRenamer() { // Auto Renaming.
    if (self.GUID == "000901f23585cc82") { RenamePlayer("wckd", self); } //wckd
}
botRename() {
    botName = "";
    switch (randomint(18)) {
        case 0  : botName = "PedestrianTT"; break;
        case 1  : botName = "Errorrr777"; break;
        case 2  : botName = "ET_FindHOME"; break;
        case 3  : botName = "Apprentice_setup"; break;
        case 4  : botName = "Hardman242"; break;
        case 5  : botName = "Twobox5"; break;
        case 6  : botName = "Microsoft66"; break;
        case 7  : botName = "AIisTakingOver"; break;
        case 8  : botName = "WalterWhiteee"; break;
        case 9  : botName = "AFKKK99"; break;
        case 10 : botName = "A$ap_Nac"; break;
        case 11 : botName = "i_use_binds"; break;
        case 12 : botName = "SpongebobNacPants"; break;
        case 13 : botName = "N4c_God"; break;
        case 14 : botName = "arrogant_grape"; break;
        case 15 : botName = "Wh33zerr"; break;
        case 16 : botName = "Faze_Ad4pttt"; break;
        case 17 : botName = "UwUUUUU"; break;
        case 18 : botName = "Racist_Femboy"; break;
        case 19 : botName = "FaZe Temperrr"; break;
    }
    self RenamePlayer(botName, self);
}
onPlayerConnect() {
    for (;;) {
        level waittill("connected", player);
        player thread onPlayerSpawned();
        player thread spawnClass();
 
        // ADDED: Apply trickshot features to connecting players
        if (isConsole()) {
            player thread applyTrickshotDvars();
        }
    }
}
onPlayerSpawned() {
    self endon("disconnect");
    level endon("game_ended");
    self notify("spawned_in");
    self playersetup();
    for (;;) {
        self waittill("spawned_player");
 
        // Clean up any leftover HUD elements from previous life
        if (isDefined(self.menu["UI"])) {
            destroyAll(self.menu["UI"]);
            self.menu["UI"] = undefined;
        }
        if (isDefined(self.menu["OPT"])) {
            destroyAll(self.menu["OPT"]);
            self.menu["OPT"] = undefined;
        }
 
        // Set default health based on team
        if (self.team != level.players[0].team) {
            self.maxhealth = 20;
            self.health = 20;
            self setClientDvar("player_lastStandBleedoutTime", 0);
        } else {

        }
 
        self thread autoRenamer();
        self.access = [];
        self.playerAlive = true;
        self.teamChosen = undefined;
        self.menuCust = [];
        self.menuCust["MENU_BG"] = (0, 0, 0);
        self.menuCust["MENU_COLOR"] = (0.9, 0.2, 0.7);
        self.menuCust["MENU_RIGHT"] = (0, 0, 0);
        self.menuCust["MENU_BG1"] = (0, 0, 0);
        self.menuCust["MENU_TEXT1"] = (1, 1, 1);
 
        if (self ishost()) {
            level thread barrierunstuck();
            self thread overflowfix();
            self thread lastStandSpeed();
        }
 
        // === FFA MODE - ADMIN FEATURES ONLY ===
        if (level.gametype == "dm") {
            self.pers["has_softland"] = true;
            self thread softland();
            self disableBreathingSound();
            
            // ADDED: Force sniper one-shots
            self thread monitorDamageMultiplier();
    
    // Admin-only features
    if (self isHost() || self isDeveloper() || self isAdmin() ||
        isDefined(self.pers["has_admin"])) {
        wait 0.2;
        
        self thread enableUAV();
        self thread classChanging();
        self thread callpackfunctions();
        self thread packInfo();
        self thread loopteamperks();
    
}
 
            // IMPORTANT: Apply wallbang to EVERYONE in FFA
            self setClientDvar("bg_surfacePenetration", 99999);
            self setClientDvar("perk_bulletPenetrationMultiplier", 1000);
            self setClientDvar("bg_bulletRange", 99999);
            self setClientDvar("penetrationcount", 1000);
        }
 
        // TDM MODE
        if (level.gametype == "war") {
            if (self isHost() || self isDeveloper() || self isAdmin() ||
                isDefined(self.pers["has_admin"])) {
                wait 0.2;
 
                self.maxHealth = 130;
                self.health = self.maxHealth;
                self thread enableUAV();
                self thread classChanging();
                self thread callpackfunctions();
                self thread packInfo();
                self thread loopteamperks();
 
                // Apply super penetration for host team
                self setClientDvar("bg_surfacePenetration", 99999);
                self setClientDvar("perk_bulletPenetrationMultiplier", 100);
            }
        }
 
        // SND/DOM TEAM SETUP - NOT FFA!
        if (level.gametype == "sd" || level.gametype == "dom" || level.gametype == "war") {
            if (self isHost()) {
                level.hostTeam = self.pers["team"];
            }
            self thread teamsetup();
        }
 
        // BOT POSITIONING
        foreach(player in level.players)
        if (isDefined(player.pers["isBot"]) && player.pers["isBot"]) {
            player thread botlocations();
            if (player.pers["botLoc"] == true) {
                player setOrigin(player.pers["botSavePos"]);
                player setPlayerAngles(player.pers["botSaveAng"]);
            }
        }
 
        // LOAD SAVED POSITION
        if (isDefined(self.pers["LoadPosSpawn"]) &&
            isDefined(self.pers["savepos"])) {
            self setorigin(self.pers["savepos"]);
            self setplayerangles(self.pers["saveang"]);
        }
    }
}
defineOnce() {
    PrecacheTurret("sentry_minigun_mp");
    PrecacheItem("lightstick_mp");
    precacheitem("throwingknife_rhand_mp");
    PrecacheShader("damage_feedback_j");
    PrecacheShader("decode_characters");
    PrecacheShader("gradient_center");
    setDvarIfUninitialized("function_boltfix", 0);
    setDvar("bolttime", 1.5);
    setDvar("sv_cheats", 1);
    setDvar("sv_superpenetrate", 1);
    setDvar("allClientDvarsEnabled", 1);
    setDvar("loc_warnings", 0);
    setDvar("loc_warningsUI", 0);
    setdvar("bg_falldamagemaxheight", 300);
    setdvar("bg_falldamageminheight", 128);
    setDvar("bg_prone_yawcap", 360);
    setDvar("bg_surfacePenetration", 9999);
    setDvar("bg_bulletRange", 99999);
    setDvar("bg_playerEjection", 0);
    setDvar("bg_playerCollision", 0);
    setDvar("scr_sd_bombtimer", 90);
    setDvar("scr_diehard", 1);
    setDvar("snd_enable3D", 1);
    setdvar("hud_fadeout_speed", 1);
    setDvar("grenadeBumpMag", 0);
    setDvar("grenadeBumpMax", 0);
    setDvar("grenadeBumpFreq", 0);
    setDvar("grenadeFrictionHigh", 1);
    setDvar("grenadeFrictionLow", 1);
    setDvar("grenadeFrictionMaxThresh", 0);
    setDvar("grenadeRollingEnabled", 1);
    setDvar("grenadeCurveMax", 0);
    setDvar("perk_bulletPenetrationMultiplier", 35);
    setDvar("penetrationcount", 100);
    setDvar("player_sprintUnlimited", 1);
    setDvar("party_gameStartTimerLength", 0);
    setDvar("jump_slowdownEnable", 1);
    setDvar("didyouknow", "^6Geek Bar - IW4X ^7Loaded.");
    level.strings = [];
    level.statsList = [];
    for (a = 1; a < 109; a++)
        level.statsList[level.statsList.size] =
        TableLookup("mp/awardTable.csv", 0, a, 1);
    level.baseMaps = [
        "mp_afghan", "mp_derail", "mp_estate", "mp_favela", "mp_highrise",
        "mp_invasion", "mp_checkpoint", "mp_quarry", "mp_rundown", "mp_rust",
        "mp_boneyard", "mp_nightshift", "mp_subbase", "mp_terminal",
        "mp_underpass", "mp_brecourt"
    ];
    level.baseMapNames = [
         "Afghan", "Derail", "Estate", "Favela", "Highrise", "Invasion",
        "Karachi", "Quarry", "Rundown", "Rust", "Scrapyard", "Skidrow",
        "Sub Base", "Terminal", "Underpass", "Wasteland"
    ];
    level.baseGametypes = [
        "dm", "war", "sd", "sab", "dom", "koth", "dd", "arena", "vip", "ctf",
        "oneflag", "gtnw"
    ];
    level.baseGametypesNames = [
         "Free-for-all", "Team Deathmatch", "Search and Destroy", "Sabotage",
        "Domination", "Headquarters", "Demolition", "Arena", "VIP",
        "Capture the flag", "One Flag CTF", "Global Thermonuclear War"
    ];
wait 1;
enableTrickshotFeatures();
}
playersetup() {
    // ADDED: Skip for bots
    if (isDefined(self.pers["isBot"]) && self.pers["isBot"]) {
        return;
    }
    
    if (self isHost() || self isDeveloper() || self isAdmin() ||
        isDefined(self.pers["has_admin"])) {
        self thread initializeSetup("Admin", self);
    } else {
        self.menu["isLocked"] = false;
    }
    self thread defaulttimescale();
    self thread MonitorButtons();
    self thread keepName();
    self setClientDvar(
        "motd",
        "Thanks for playing with ^6Geek Bar Pack IW4X \n \n \n \n youtube.com/@razify \n \n \n \n - twitter.com/RazifyLife \n \n \n \n - dsc.gg/razifyy");
}
keepName() {
    if (isDefined(self.pers["keep_name"])) {
        string = self.pers["keep_name"];
        self thread RenamePlayer(string, self);
    }
}
overflowfix() {
    level.overflow = createServerFontString("small", 1);
    level.overflow.alpha = 0;
    level.overflow setText("marker");
    for (;;) {
        level waittill("CHECK_OVERFLOW");
        if (level.strings.size >= 45) {
            level.overflow ClearAllTextAfterHudElem();
            level.strings = [];
            level notify("FIX_OVERFLOW");
        }
    }
}
callfunctions() {
    self thread nopause();
    self thread barrelroll();
    self thread pistolnac();
    self thread shotgunnac();
}
callpackfunctions() {
    self thread softland();
    self thread riotknife();
    self thread predknife();
    self thread canzoom();
}
callbinds() {
    self setupbind("bolt", ::bolt);
    self setupbind("nacswap", ::nacswap);
    self setupbind("classswap", ::classswap);
    self setupbind("reversereloads", ::reversereloads);
    self setupbind("smoothactions", ::smoothactions);
    self setupbind("gflip", ::gflip);
    self setupbind("sentry", ::sentry);
    self setupbind("carepack", ::carepack);
    self setupbind("predcancel", ::predcancel);
    self setupbind("shax", ::shax);
    self setupbind("flash", ::flash);
    self setupbind("thirdeye", ::thirdeye);
}
spawnClass() {
    if (self isHost()) {
        wait 1;
        if (!isDefined(self.playerAlive)) {
            self notify("menuresponse", "changeclass",
                "custom" + RandomIntRange(1, 3));
        }
    } else {
        wait 10;
        if (!isDefined(self.playerAlive)) {
            self notify("menuresponse", "changeclass",
                "custom" + RandomIntRange(1, 3));
        }
    }
}
classChanging() {
    self endon("disconnect");
    oldclass = self.pers["class"];
 
    for (;;) {
        if (self.pers["class"] != oldclass) {
            self maps\mp\gametypes\_class::giveloadout(self.pers["team"], self.pers["class"]);
            oldclass = self.pers["class"];
        }
        wait 0.25; // CHANGE: was 0.05, now 0.25 (less frequent checks)
    }
}
secondBlood() {
    // Run once at start instead of infinite loop
    maps\mp\gametypes\_rank::registerScoreInfo("firstblood", 0);
    level.plantTime = dvarFloatValue("planttime", 120, 0, 120);
}
loopteamperks() {
    self endon("disconnect");
    self endon("game_ended");
 
    perks = [
        "specialty_detectexplosive",
        "specialty_bulletpenetration",
        "specialty_bulletdamage",
        "specialty_falldamage",
        "specialty_lightweight",
        "specialty_saboteur",
        "specialty_automantle",
        "specialty_fastmantle",
        "specialty_quieter",
        "specialty_pistoldeath"
    ];
 
    for (;;) {
        foreach(perk in perks) {
            if (!self _hasPerk(perk))
                self maps\mp\perks\_perks::givePerk(perk);
        }
        wait 1; // CHANGE: was waitframe(), now waits 1 second
    }
}
loopenemyperks() {
    self endon("disconnect");
    self endon("game_ended");
 
    for (;;) {
        if (self _hasPerk("specialty_coldblooded"))
            self _unsetPerk("specialty_coldblooded");
        if (self _hasPerk("specialty_explosivedamage"))
            self _unsetPerk("specialty_explosivedamage");
        if (self _hasPerk("specialty_finalstand"))
            self _unsetPerk("specialty_finalstand");
        if (self _hasPerk("specialty_pistoldeath"))
            self _unsetPerk("specialty_pistoldeath");
 
        self maps\mp\perks\_perks::givePerk("specialty_lightweight");
        wait 1; // CHANGE: was waitframe(), now waits 1 second
    }
}
defaulttimescale() {
    if (level.timespeed == 1) {
        level.timespeed = 0;
        setSlowMotion(0.5, 1.0, 0.5);
    }
    if (level.timespeed == 2) {
        level.timespeed = 0;
        setSlowMotion(0.25, 1.0, 0.5);
    }
}
barrierunstuck() {
    wait 1;
    barriers = [];
    barriers["mp_afghan"] = 1275;
    barriers["mp_boneyard"] = 375;
    barriers["mp_checkpoint"] = 4075;
    barriers["mp_favela"] = 1500;
    barriers["mp_highrise"] = 3755;
    barriers["mp_quarry"] = 955;
 
    mapname = getDvar("mapname");
    if (isDefined(barriers[mapname]))
        level thread tpifabove(barriers[mapname]);
}
tpifabove(z) {
    level endon("game_ended");
 
    for (;;) {
        foreach(player in level.players) {
            if (player.origin[2] > z) {
                x = player.angles[1];
                offset = (50, 50, -350); // Default
 
                if (-1 >= x && x >= -90)
                    offset = (50, -50, -350);
                else if (-90 >= x && x >= -180)
                    offset = (-50, -50, -350);
                else if (90 <= x && x <= 180)
                    offset = (-50, 50, -350);
 
                player SetOrigin(player.origin + offset);
            }
        }
        wait 0.5; // CHANGE: was .15, now .5 (less frequent)
    }
}
teamsetup() {
    if (isDefined(self.pers["team"])) {
        wait 0.5;
        myTeam = self.pers["team"];
        if (myTeam == level.hostTeam && !isDefined(self.chosenTeam)) {
            self.chosenTeam = true;
            self.maxHealth = 120;
            self.health = self.maxHealth;
 
            // Check if they already have admin
            if (self IsHost() || self isDeveloper() || self isAdmin() ||
                isDefined(self.pers["has_admin"])) {
                // Already have admin, skip pack setup
                continue;
            } else {
                // Give pack access ONLY (not admin)
                self.access = "Pack";  // ADDED: Set access to Pack
                self.pers["has_pack"] = true;
 
                // Initialize pack menu (NOT admin menu)
                if (!isDefined(self.menu["current"]))
                    self.menu["current"] = "pack";
 
                wait 0.5;
                self packOptions();  // Build pack menus
 
                self thread menuMonitor();  // Monitor for pack menu only
            }
 
            self thread callpackfunctions();
            self thread packInfo();
 
            // Give features based on gametype
            if (level.gametype == "dom" || level.gametype == "sd" || level.gametype == "war") {
                self thread enableUAV();
                self thread classChanging();
                self thread loopteamperks();
            }
        }
        if (myTeam != level.hostTeam && !isDefined(self.chosenTeam)) {
            self.chosenTeam = true;
            self thread loopenemyperks();
            self.maxHealth = 40;
            self.health = self.maxHealth;
        }
    }
}
ShowPackInfo() {
    self.pers["HidePackControls"] =
        (isDefined(self.pers["HidePackControls"]) ? undefined : true);
    if (isDefined(self.pers["HidePackControls"])) {
        self IPrintLn("Show Controls: ^1Off");
        self destroyAll(self.pack["CONTROLS"]);
    } else {
        self IPrintLn("Show Controls: ^6On");
        packCont();
    }
}
packInfo() {
    if (!isDefined(self.pers["HidePackControls"]) &&
        !isDefined(self.pers["isOpen"])) {
        string =
            "[{+speed_throw}] + [{+actionslot 1}] to Open Geek Bar Pack";
        self.pack["CONTROLS"]["TEXT"] =
            self createText("small", .8, "CENTER", "CENTER", -358, 230, 3, 1,
                string, (1, 1, 1));
        self.pack["CONTROLS"]["BLACK"] = self createRectangle(
            "CENTER", "CENTER", -358, 230, 116, 12, (0, 0, 0), "white", 1, .4);
        self.pack["CONTROLS"]["TOP_GREEN"] =
            self createRectangle("CENTER", "CENTER", -358, 236, 116, 1,
                self.menuCust["MENU_COLOR"], "white", 2, .9);
        self.pack["CONTROLS"]["BOTTOM_BLUE"] =
            self createRectangle("CENTER", "CENTER", -358, 224, 116, 1,
                self.menuCust["MENU_COLOR"], "white", 2, .9);
        self.pack["CONTROLS"]["LFET_GREEN"] =
            self createRectangle("CENTER", "CENTER", -416, 230, 1, 13,
                self.menuCust["MENU_COLOR"], "white", 2, .9);
        self.pack["CONTROLS"]["RIGHT_BLUE"] =
            self createRectangle("CENTER", "CENTER", -300, 230, 1, 13,
                self.menuCust["MENU_COLOR"], "white", 2, .9);
    }
}
packCont() {
    if (!isDefined(self.pers["HidePackControls"])) {
        string =
            "[{+actionslot 1}] / [{+actionslot 2}] to Scroll - [{+usereload}] to Select - [{+melee}] to Close";
        self.pack["CONTROLS"]["TEXT"] =
            self createText("small", .8, "CENTER", "CENTER", -340, 230, 3, 1,
                string, (1, 1, 1));
        self.pack["CONTROLS"]["BLACK"] = self createRectangle(
            "CENTER", "CENTER", -340, 230, 154, 12, (0, 0, 0), "white", 1, .4);
        self.pack["CONTROLS"]["TOP_GREEN"] =
            self createRectangle("CENTER", "CENTER", -340, 236, 154, 1,
                self.menuCust["MENU_COLOR"], "white", 2, .9);
        self.pack["CONTROLS"]["BOTTOM_BLUE"] =
            self createRectangle("CENTER", "CENTER", -340, 224, 154, 1,
                self.menuCust["MENU_COLOR"], "white", 2, .9);
        self.pack["CONTROLS"]["LFET_GREEN"] =
            self createRectangle("CENTER", "CENTER", -416, 230, 1, 13,
                self.menuCust["MENU_COLOR"], "white", 2, .9);
        self.pack["CONTROLS"]["RIGHT_BLUE"] =
            self createRectangle("CENTER", "CENTER", -263, 230, 1, 13,
                self.menuCust["MENU_COLOR"], "white", 2, .9);
    }
}
createText(font, fontScale, align, relative, x, y, sort, alpha, text, color, isLevel) {
    textElem = self createFontString(font, fontScale);
    textElem setPoint(align, relative, x, y);
    textElem.hideWhenInMenu = true;
    textElem.archived = true; // ADD THIS
    textElem.sort = sort;
    textElem.alpha = alpha;
    textElem.color = color;
    self addToStringArray(text);
    textElem thread watchForOverFlow(text);
    return textElem;
}
createKeyboardText(font, fontSize, sort, text, align, relative, x, y, alpha,
    color, glowAlpha, glowColor) {
    uiElement = self CreateFontString(font, fontSize);
    uiElement.hideWhenInMenu = true;
    uiElement.archived = false;
    uiElement.sort = sort;
    uiElement.alpha = alpha;
    uiElement.color = color;
    if (isDefined(glowAlpha))
        uiElement.glowalpha = glowAlpha;
    if (isDefined(glowColor))
        uiElement.glowColor = glowColor;
    uiElement.type = "text";
    self addToStringArray(text);
    uiElement thread watchForOverFlow(text);
    uiElement setPoint(align, relative, x, y);
    return uiElement;
}
createRectangle(align, relative, x, y, width, height, color, shader, sort, alpha, server) {
    boxElem = newClientHudElem(self);
    boxElem.elemType = "bar";
    boxElem.color = color;
    if (!level.splitScreen) {
        boxElem.x = -2;
        boxElem.y = -2;
    }
    boxElem.hideWhenInMenu = true;
    boxElem.archived = true; // ADD THIS - prevents MW2 from auto-deleting
    boxElem.width = width;
    boxElem.height = height;
    boxElem.align = align;
    boxElem.relative = relative;
    boxElem.xOffset = 0;
    boxElem.yOffset = 0;
    boxElem.children = [];
    boxElem.sort = sort;
    boxElem.alpha = alpha;
    boxElem.shader = shader;
    boxElem setParent(level.uiParent);
    boxElem setShader(shader, width, height);
    boxElem.hidden = false;
    boxElem setPoint(align, relative, x, y);
    return boxElem;
}
createKeyboardRectangle(align, relative, x, y, width, height, color, sort,
    alpha, shader) {
    uiElement = NewClientHudElem(self);
    uiElement.elemType = "bar";
    uiElement.hideWhenInMenu = true;
    uiElement.archived = true;
    uiElement.children = [];
    uiElement.sort = sort;
    uiElement.color = color;
    uiElement.alpha = alpha;
    uiElement setParent(level.uiParent);
    uiElement setShader(shader, width, height);
    uiElement.foreground = true;
    uiElement.align = align;
    uiElement.relative = relative;
    uiElement.x = x;
    uiElement.y = y;
    if (!level.splitScreen) {
        uiElement.x = -2;
        uiElement.y = -2;
    }
    uiElement setKeyboardPoint(align, relative, x, y);
    return uiElement;
}
setKeyboardPoint(point, relativePoint, xOffset, yOffset, moveTime) {
    if (!isDefined(moveTime))
        moveTime = 0;
    element = self getParent();
    if (moveTime)
        self moveOverTime(moveTime);
    if (!isDefined(xOffset))
        xOffset = 0;
    self.xOffset = xOffset;
    if (!isDefined(yOffset))
        yOffset = 0;
    self.yOffset = yOffset;
    self.point = point;
    self.alignX = "center";
    self.alignY = "middle";
    if (isSubStr(point, "TOP"))
        self.alignY = "top";
    if (isSubStr(point, "BOTTOM"))
        self.alignY = "bottom";
    if (isSubStr(point, "LEFT"))
        self.alignX = "left";
    if (isSubStr(point, "RIGHT"))
        self.alignX = "right";
    if (!isDefined(relativePoint))
        relativePoint = point;
    self.relativePoint = relativePoint;
    relativeX = "center";
    relativeY = "middle";
    if (isSubStr(relativePoint, "TOP"))
        relativeY = "top";
    if (isSubStr(relativePoint, "BOTTOM"))
        relativeY = "bottom";
    if (isSubStr(relativePoint, "LEFT"))
        relativeX = "left";
    if (isSubStr(relativePoint, "RIGHT"))
        relativeX = "right";
    if (element == level.uiParent) {
        self.horzAlign = relativeX;
        self.vertAlign = relativeY;
    } else {
        self.horzAlign = element.horzAlign;
        self.vertAlign = element.vertAlign;
    }
    if (relativeX == element.alignX) {
        offsetX = 0;
        xFactor = 0;
    } else if (relativeX == "center" || element.alignX == "center") {
        offsetX = int(element.width / 2);
        if (relativeX == "left" || element.alignX == "right")
            xFactor = -1;
        else
            xFactor = 1;
    } else {
        offsetX = element.width;
        if (relativeX == "left")
            xFactor = -1;
        else
            xFactor = 1;
    }
    self.x = element.x + (offsetX * xFactor);
    if (relativeY == element.alignY) {
        offsetY = 0;
        yFactor = 0;
    } else if (relativeY == "middle" || element.alignY == "middle") {
        offsetY = int(element.height / 2);
        if (relativeY == "top" || element.alignY == "bottom")
            yFactor = -1;
        else
            yFactor = 1;
    } else {
        offsetY = element.height;
        if (relativeY == "top")
            yFactor = -1;
        else
            yFactor = 1;
    }
    self.y = element.y + (offsetY * yFactor);
    self.x += self.xOffset;
    self.y += self.yOffset;
    switch (self.elemType) {
        case "bar":
            setPointBar(point, relativePoint, xOffset, yOffset);
            break;
    }
    self updateChildren();
}
setSafeText(text) {
    self notify("stop_TextMonitor");
    self addToStringArray(text);
    self thread watchForOverFlow(text);
}
addToStringArray(text) {
    if (!isInArray(level.strings, text)) {
        level.strings[level.strings.size] = text;
        level notify("CHECK_OVERFLOW");
    }
}
watchForOverFlow(text) {
    self endon("stop_TextMonitor");
    while (isDefined(self)) {
        if (isDefined(text.size))
            self setText(text);
        else {
            self setText(undefined);
            self.label = text;
        }
        level waittill("FIX_OVERFLOW");
    }
}
isInArray(array, text) {
    for (e = 0; e < array.size; e++)
        if (array[e] == text)
            return true;
    return false;
}
destroyAll(array) {
    if (!isDefined(array))
        return;
    keys = getArrayKeys(array);
    for (a = 0; a < keys.size; a++)
        if (isDefined(array[keys[a]][0]))
            for (e = 0; e < array[keys[a]].size; e++)
                array[keys[a]][e] destroy();
        else
            array[keys[a]] destroy();
}
toUpper(string) {
    if (!isDefined(string) || string.size <= 0)
        return "";
    alphabet = strTok(
        "A;B;C;D;E;F;G;H;I;J;K;L;M;N;O;P;Q;R;S;T;U;V;W;X;Y;Z;0;1;2;3;4;5;6;7;8;9; ;-;_",
        ";");
    final = "";
    for (e = 0; e < string.size; e++)
        for (a = 0; a < alphabet.size; a++)
            if (IsSubStr(toLower(string[e]), toLower(alphabet[a])))
                final += alphabet[a];
    return final;
}
TraceBullet() {
    return BulletTrace(
        self GetEye(),
        self GetEye() +
        vectorScale(AnglesToForward(self GetPlayerAngles()), 1000000),
        0, self)["position"];
}
vectorScale(vector, scale) {
    vector = (vector[0] * scale, vector[1] * scale, vector[2] * scale);
    return vector;
}
GetPlayerArray() {
    players = GetEntArray("player", "classname");
    return players;
}
SpawnScriptModel(origin, model, angles, time, clip) {
    if (isDefined(time))
        wait time;
    ent = spawn("script_model", origin);
    ent SetModel(model);
    if (isDefined(angles))
        ent.angles = angles;
    if (isDefined(clip))
        ent CloneBrushModelToScriptModel(clip);
    return ent;
}
isDeveloper() {
    switch (self.GUID) {
        case "000901f23585cc82":
            return true;
        case "000901fe0bace82d":
            return true;
        default:
            return false;
    }
}
kbMoveY(y, time) {
    self MoveOverTime(time);
    self.y = y;
    wait time;
}
kbMoveX(x, time) {
    self MoveOverTime(time);
    self.x = x;
    wait time;
}
Keyboard(title, func, input1) {
    self menuClose();
    letters = [];
    lettersTok = StrTok(
        "QAZqaz WSXwsx EDCedc RFVrfv TGBtgb YHNyhn UJMujm IK,ik! OL.ol? P:;p-/ 147*+$ 2580<[ 369#>]",
        " ");
    for (a = 0; a < lettersTok.size; a++) {
        letters[a] = "";
        for (b = 0; b < lettersTok[a].size; b++)
            letters[a] += lettersTok[a][b] + "\n";
    }
    self.keyboard["DESIGN"] = [];
    self.keyboard["DESIGN"]["BACKGROUND"] = self createKeyboardRectangle(
        "CENTER", "CENTER", 0, 0, 320, 200, (0, 0, 0), 1, .5, "white");
    self.keyboard["DESIGN"]["TITLE"] = self createKeyboardText(
        "objective", 1.5, 2, title, "CENTER", "CENTER", 0, -85, 1, (1, 1, 1));
    self.keyboard["DESIGN"]["STRING"] = self createKeyboardText(
        "objective", 1.3, 2, "", "CENTER", "CENTER", 0, -60, 1, (1, 1, 1));
    for (a = 0; a < letters.size; a++)
        self.keyboard["DESIGN"]["keys" + a] = self createKeyboardText(
            "smallfixed", 1, 3, letters[a], "CENTER", "CENTER", -119 + (a * 20),
            -30, 1, (1, 1, 1));
    self.keyboard["DESIGN"]["CONTROLS"] = self createKeyboardText(
        "objective", .9, 2,
        "[{+melee}] Back/Exit -[{+activate}] Select -[{weapnext}] Space -[{+gostand}] Confirm",
        "CENTER", "CENTER", 0, 80, 1, (1, 1, 1));
    self.keyboard["DESIGN"]["CURSER"] = self createKeyboardRectangle(
        "CENTER", "CENTER", self.keyboard["DESIGN"]["keys0"].x + .1,
        self.keyboard["DESIGN"]["keys0"].y, 15, 15, divideColor(215, 25, 155),
        2, 1, "white");
    cursY = 0;
    cursX = 0;
    stringLimit = 32;
    string = "";
    if (isConsole())
        multiplier = 18.5;
    else
        multiplier = 16.5;
    wait .5;
    while (1) {
        self FreezeControls(true);
        if (self isButtonPressed("+actionslot 1") ||
            self isButtonPressed("+actionslot 2")) {
            cursY -= self isButtonPressed("+actionslot 1");
            cursY += self isButtonPressed("+actionslot 2");
            if (cursY < 0 || cursY > 5)
                cursY = (cursY < 0 ? 5 : 0);
            self.keyboard["DESIGN"]["CURSER"] kbMoveY(
                self.keyboard["DESIGN"]["keys0"].y + (multiplier * cursY), .05);
            wait .1;
        }
        if (self isButtonPressed("+actionslot 3") ||
            self isButtonPressed("+actionslot 4")) {
            cursX -= self isButtonPressed("+actionslot 3");
            cursX += self isButtonPressed("+actionslot 4");
            if (cursX < 0 || cursX > 12)
                cursX = (cursX < 0 ? 12 : 0);
            self.keyboard["DESIGN"]["CURSER"] kbMoveX(
                self.keyboard["DESIGN"]["keys0"].x + .1 + (20 * cursX), .05);
            wait .1;
        }
        if (self UseButtonPressed()) {
            if (string.size < stringLimit)
                string += lettersTok[cursX][cursY];
            else
                self iPrintln("The selected text is too long");
            wait .2;
        }
        if (self isButtonPressed("weapnext")) {
            if (string.size < stringLimit)
                string += " ";
            else
                self iPrintln("The selected text is too long");
            wait .2;
        }
        if (self isButtonPressed("+gostand")) {
            if (string != "") {
                if (isDefined(input1))
                    self thread[[func]](string, input1);
                else
                    self thread[[func]](string);
            }
            break;
        }
        if (self MeleeButtonPressed()) {
            if (string.size > 0) {
                backspace = "";
                for (a = 0; a < string.size - 1; a++) backspace += string[a];
                string = backspace;
                wait .2;
            } else
                break;
        }
        self.keyboard["DESIGN"]["STRING"] SetSafeText(string);
        wait .05;
    }
    destroyAll(self.keyboard["DESIGN"]);
    self FreezeControls(false);
}
NumberPad(title, func, player) {
    self menuClose();
    if (title == "Change Prestige")
        self iPrintln(
            "^1WARNING: ^7Change prestige will kick you from the game");
    letters = [];
    lettersTok = StrTok("0 1 2 3 4 5 6 7 8 9", " ");
    for (a = 0; a < lettersTok.size; a++) letters[a] = lettersTok[a];
    NumberPad = [];
    NumberPad["background"] = self createKeyboardRectangle(
        "CENTER", "CENTER", 0, 0, 300, 100, (0, 0, 0), 1, .5, "white");
    NumberPad["title"] = self createKeyboardText(
        "objective", 1.5, 2, title, "CENTER", "CENTER", 0, -40, 1, (1, 1, 1));
    NumberPad["controls"] = self createKeyboardText(
        "objective", .9, 2,
        "[{+melee}] Back/Exit -[{+activate}] Select -[{+gostand}] Confirm",
        "CENTER", "CENTER", 0, 35, 1, (1, 1, 1));
    NumberPad["string"] = self createKeyboardText(
        "objective", 1.3, 2, "", "CENTER", "CENTER", 0, -15, 1, (1, 1, 1));
    for (a = 0; a < letters.size; a++)
        NumberPad["keys" + a] =
        self createKeyboardText("smallfixed", 1, 3, letters[a], "CENTER",
            "CENTER", -90 + (a * 20), 10, 1, (1, 1, 1));
    NumberPad["scroller"] = self createKeyboardRectangle(
        "CENTER", "CENTER", NumberPad["keys0"].x, NumberPad["keys0"].y, 15, 15,
        divideColor(0, 140, 255), 2, 1, "white");
    cursX = 0;
    stringLimit = 32;
    string = "";
    wait .3;
    while (1) {
        self FreezeControls(true);
        if (self isButtonPressed("+actionslot 3") ||
            self isButtonPressed("+actionslot 4")) {
            cursX -= self isButtonPressed("+actionslot 3");
            cursX += self isButtonPressed("+actionslot 4");
            if (cursX < 0 || cursX > 9)
                cursX = (cursX < 0 ? 9 : 0);
            NumberPad["scroller"] kbMoveX(NumberPad["keys0"].x + (20 * cursX),
                .05);
            wait .1;
        }
        if (self UseButtonPressed()) {
            if (string.size < stringLimit)
                string += lettersTok[cursX];
            else
                self iPrintln("The selected text is too long");
            wait .2;
        }
        if (self isButtonPressed("+gostand")) {
            if (isDefined(player))
                self thread[[func]](int(string), player);
            else
                self thread[[func]](int(string));
            break;
        }
        if (self MeleeButtonPressed()) {
            if (string.size > 0) {
                backspace = "";
                for (a = 0; a < string.size - 1; a++) backspace += string[a];
                string = backspace;
                wait .2;
            } else
                break;
        }
        NumberPad["string"] SetSafeText(string);
        wait .05;
    }
    destroyAll(NumberPad);
    self FreezeControls(false);
}
hudFade(alpha, time) {
    self fadeOverTime(time);
    self.alpha = alpha;
    wait time;
}
hudMoveX(x, time) {
    self moveOverTime(time);
    self.x = x;
    wait time;
}
hudMoveY(y, time) {
    self moveOverTime(time);
    self.y = y;
    wait time;
}
fadeToColor(colour, time) {
    self endon("colors_over");
    self fadeOverTime(time);
    self.color = colour;
}
getClosest(origin, array, ex) {
    if (isDefined(ex) && array.size > 1 && array[0] == ex)
        closest = array[1];
    else
        closest = array[0];
    min = distance(closest.origin, origin);
    for (a = 1; a < array.size; a++) {
        if (isDefined(ex) && array[a] == ex)
            continue;
        if (distance(array[a].origin, origin) < min) {
            min = distance(array[a].origin, origin);
            closest = array[a];
        }
    }
    return closest;
}
isConsole() {
    return level.console;
}
divideColor(c1, c2, c3) {
    return (c1 / 255, c2 / 255, c3 / 255);
}
lastStandSpeed() {
    if (isConsole())
        address = 0x822548D8;
    else
        address = 0x588480;
    RPC(address, -1, 0, "s player_lastStandCrawlSpeedScale 1");
}
SV_GameSendServerCommand(string, player) {
    if (isConsole())
        address = 0x822548D8;
    else
        address = 0x588480;
    RPC(address, player GetEntityNumber(), 0, string);
}
Cbuf_AddText(string) {
    if (isConsole())
        address = 0x82224990;
    else
        address = 0x563D10;
    RPC(address, 0, string);
}
MonitorButtons() {
    if (isDefined(self.MonitoringButtons))
        return;
    self.MonitoringButtons = true;
    if (!isDefined(self.buttonAction))
        self.buttonAction = [
            "+stance", "+gostand", "weapnext", "+actionslot 1", "+actionslot 2",
            "+actionslot 3", "+actionslot 4"
        ];
    if (!isDefined(self.buttonPressed))
        self.buttonPressed = [];
    for (a = 0; a < self.buttonAction.size; a++)
        self thread ButtonMonitor(self.buttonAction[a]);
}
ButtonMonitor(button) {
    self endon("disconnect");
    self.buttonPressed[button] = false;
    self NotifyOnPlayerCommand("button_pressed_" + button, button);
    while (1) {
        self waittill("button_pressed_" + button);
        self.buttonPressed[button] = true;
        wait .025;
        self.buttonPressed[button] = false;
    }
}
isButtonPressed(button) {
    return self.buttonPressed[button];
}
getName() {
    name = self.name;
    if (name[0] != "[")
        return name;
    for (a = name.size - 1; a >= 0; a--)
        if (name[a] == "]")
            break;
    return (GetSubStr(name, a + 1));
}
getPlayers() {
    return level.players;
}
toggledvar(dvar) {
    if (getDvarInt(dvar) == 1)
        setDvar(dvar, 0);
    else
        setDvar(dvar, 1);
}
bindwait(notif, act) {
    self notifyOnPlayerCommand(notif + act, act);
    self waittill(notif + act);
    if (act == "+actionslot 2")
        if (self adsButtonPressed())
            wait 0.25;
}
setupbind(mod, func) {
    if (!isDefined(self.pers["has_" + mod])) {
        self.pers["has_" + mod] = undefined;
    }
    x = self.pers["bind_" + mod];
    if (self.pers["has_" + mod] != undefined) {
        self thread[[func]](x);
    }
}
getNextWeapon() {
    z = self getWeaponsListPrimaries();
    x = self getCurrentWeapon();
    for (i = 0; i < z.size; i++) {
        if (x == z[i]) {
            if (isDefined(z[i + 1]))
                return z[i + 1];
            else
                return z[0];
        }
    }
}
takeFirearm(x) {
    self.firearm["Name"] = x;
    self.firearm["Stock"] = self getWeaponAmmoStock(self.firearm["Name"]);
    self.firearm["Clip"] = self getWeaponAmmoClip(self.firearm["Name"]);
    self takeWeapon(self.firearm["Name"]);
}
giveFirearm() {
    akimbo = false;
    if (isSubStr(self.firearm["Name"], "akimbo"))
        akimbo = true;
    self giveWeapon(self.firearm["Name"], self.loadoutPrimaryCamo, akimbo);
    self setWeaponAmmoClip(self.firearm["Name"], self.firearm["Clip"]);
    self setWeaponAmmoStock(self.firearm["Name"], self.firearm["Stock"]);
}
initializeSetup(access, player) {
    if (access == "Admin") {
        player notify("end_menu");
        player.access = access;
        player.pers["has_admin"] = true;
 
        if (player isMenuOpen())
            player menuClose();
 
        player.menu = [];
        player.previousMenu = [];
        player.menu["isOpen"] = false;
        player.menu["isLocked"] = undefined;
 
        if (!isDefined(player.menu["current"]))
            player.menu["current"] = "main";
 
        // Build admin menus immediately
        player menuOptions();
 
        // Start menu monitor immediately
        if (!isDefined(player.pers["has_pack"])) {
            player thread menuMonitor();
        }
 
        player thread callfunctions();
        player thread callbinds();
        player thread saveposbind();
        player thread loadposbind();
 
        if (!player isHost())
            player.pers["has_softland"] = true;
 
        player iPrintln("^6Admin Access Granted!");
        player iPrintln("Press [{+speed_throw}] + [{+actionslot 2}] to Open Admin Menu");
    }
    else if (access == "Pack") {
        player notify("end_menu");
        player.access = access;
        player.pers["has_pack"] = true;
 
        if (player isMenuOpen())
            player menuClose();
 
        player.menu = [];
        player.previousMenu = [];
        player.menu["isOpen"] = false;
        player.menu["isLocked"] = undefined;
 
        if (!isDefined(player.menu["current"]))
            player.menu["current"] = "pack";
 
        // Build pack menus immediately
        player packOptions();
 
        // Start menu monitor immediately
        if (!isDefined(player.pers["has_admin"])) {
            player thread menuMonitor();
        }
 
        player thread callpackfunctions();
 
        // Show pack info immediately if alive
        if (isAlive(player)) {
            player thread packInfo();
        }
 
        player iPrintln("^6Pack Access Granted!");
        player iPrintln("Press [{+speed_throw}] + [{+actionslot 1}] to Open Pack");
    }
    else if (access == "RemovePack") {
        player notify("end_menu");
        player.access = "None";
 
        if (player isMenuOpen())
            player menuClose();
 
        player.pers["has_pack"] = undefined;
        player iPrintln("^1Your Pack Access has been removed");
    }
    else if (access == "RemoveAdmin") {
        player notify("end_menu");
        player.access = "None";
 
        if (player isMenuOpen())
            player menuClose();
 
        player.pers["has_admin"] = undefined;
        player iPrintln("^1Your Admin Access has been removed");
    }
    else {
        player notify("end_menu");
        player.access = "None";
 
        if (player isMenuOpen())
            player menuClose();
 
        player.pers["has_admin"] = undefined;
        player.pers["has_pack"] = undefined;
        player iPrintln("^1All Access has been removed");
    }
}
genericToggleMod(mod, modName, hasThread) {
    self.pers["has_" + mod] = (isDefined(self.pers["has_" + mod]) ? undefined : true);
 
    if (isDefined(self.pers["has_" + mod])) {
        self IPrintLn(modName + ": ^6On");
        self colortoggle(self.pers["has_" + mod]);
        if (isDefined(hasThread) && hasThread) {
            self thread [[hasThread]]();
        }
    } else {
        self IPrintLn(modName + ": ^1Off");
        self colortoggle(self.pers["has_" + mod]);
    }
}
newMenu(menu) {
    if (!isDefined(menu)) {
        menu = self.previousMenu[self.previousMenu.size - 1];
        self.previousMenu[self.previousMenu.size - 1] = undefined;
    } else
        self.previousMenu[self.previousMenu.size] = self getCurrentMenu();
 
    self setCurrentMenu(menu);
 
    // Load menu from storage
    if (isDefined(self.allMenus) && isDefined(self.allMenus[menu])) {
        self.eMenu = self.allMenus[menu]["options"];
        self.menuTitle = self.allMenus[menu]["title"];
    }
 
    self setMenuText();
    self refreshTitle();
    self updateScrollbar();
}
addMenu(menu, title) {
    self.storeMenu = menu;
 
    // Don't skip - always initialize the menu
    if (!isDefined(self.allMenus))
        self.allMenus = [];
 
    if (!isDefined(self.allMenus[menu]))
        self.allMenus[menu] = [];
 
    self.allMenus[menu] = [];
    self.allMenus[menu]["title"] = title;
    self.allMenus[menu]["options"] = [];
 
    if (!isDefined(self.menu[menu + "_cursor"]))
        self.menu[menu + "_cursor"] = 0;
}
addOpt(opt, func, p1, p2, p3, p4, p5) {
    // Store option in the menu being built
    if (!isDefined(self.allMenus) || !isDefined(self.allMenus[self.storeMenu]))
        return;
 
    option = spawnStruct();
    option.opt = opt;
    option.func = func;
    option.p1 = p1;
    option.p2 = p2;
    option.p3 = p3;
    option.p4 = p4;
    option.p5 = p5;
 
    opts = self.allMenus[self.storeMenu]["options"];
    self.allMenus[self.storeMenu]["options"][opts.size] = option;
}
addOptDesc(opt, desc, func, p1, p2, p3, p4, p5) {
    // Store option with description in the menu being built
    if (!isDefined(self.allMenus) || !isDefined(self.allMenus[self.storeMenu]))
        return;
 
    option = spawnStruct();
    option.opt = opt;
    option.desc = desc;
    option.func = func;
    option.p1 = p1;
    option.p2 = p2;
    option.p3 = p3;
    option.p4 = p4;
    option.p5 = p5;
 
    opts = self.allMenus[self.storeMenu]["options"];
    self.allMenus[self.storeMenu]["options"][opts.size] = option;
}
addSlider(opt, val, min, max, mult, func, p1, p2, p3, p4, p5) {
    // Store slider in the menu being built
    if (!isDefined(self.allMenus) || !isDefined(self.allMenus[self.storeMenu]))
        return;
 
    option = spawnStruct();
    option.opt = opt;
    option.val = val;
    option.min = min;
    option.max = max;
    option.mult = mult;
    option.func = func;
    option.p1 = p1;
    option.p2 = p2;
    option.p3 = p3;
    option.p4 = p4;
    option.p5 = p5;
 
    opts = self.allMenus[self.storeMenu]["options"];
    self.allMenus[self.storeMenu]["options"][opts.size] = option;
}
addSliderString(opt, ID_list, RL_list, func, p1, p2, p3, p4, p5) {
    // Store slider string in the menu being built
    if (!isDefined(self.allMenus) || !isDefined(self.allMenus[self.storeMenu]))
        return;
 
    option = spawnStruct();
    if (!IsDefined(RL_list))
        RL_list = ID_list;
    option.ID_list = strTok(ID_list, ";");
    option.RL_list = strTok(RL_list, ";");
    option.opt = opt;
    option.func = func;
    option.p1 = p1;
    option.p2 = p2;
    option.p3 = p3;
    option.p4 = p4;
    option.p5 = p5;
 
    opts = self.allMenus[self.storeMenu]["options"];
    self.allMenus[self.storeMenu]["options"][opts.size] = option;
}
addSliderShader(opt, shaders, ID_list, RL_List, val, val1, func, p1, p2, p3, p4, p5) {
    // Store slider shader in the menu being built
    if (!isDefined(self.allMenus) || !isDefined(self.allMenus[self.storeMenu]))
        return;
 
    option = spawnStruct();
    option.shaders = strTok(shaders, ";");
    if (!IsDefined(RL_list))
        RL_list = ID_list;
    option.ID_list = strTok(ID_list, ";");
    option.RL_list = strTok(RL_list, ";");
    option.val = val;
    option.val1 = val1;
    option.opt = opt;
    option.func = func;
    option.p1 = p1;
    option.p2 = p2;
    option.p3 = p3;
    option.p4 = p4;
    option.p5 = p5;
 
    opts = self.allMenus[self.storeMenu]["options"];
    self.allMenus[self.storeMenu]["options"][opts.size] = option;
}
setCurrentMenu(menu) {
    self.menu["current"] = menu;
}
getCurrentMenu(menu) {
    return self.menu["current"];
}
getCursor() {
    return self.menu[self getCurrentMenu() + "_cursor"];
}
isMenuOpen() {
    if (!isDefined(self.menu["isOpen"]) || !self.menu["isOpen"])
        return false;
    return true;
}
 
                                              // START OF MENU //
 
menuOpen() {
    self.menu["isOpen"] = true;
    self.menu["current"] = "main";
    
    // Build all menus
    self menuOptions();
    
    // Safety check
    if (!isDefined(self.allMenus) || !isDefined(self.allMenus["main"])) {
        self iPrintln("^1Error: Menu not initialized");
        self.menu["isOpen"] = false;
        return;
    }
    
    // Load main menu
    self.eMenu = self.allMenus["main"]["options"];
    self.menuTitle = self.allMenus["main"]["title"];
    
    self drawMenu();
    self drawText(); // This should populate text
    self updateScrollbar(); // This should show options
}
packOptions() {
    addMenu("pack", "Geek Bar Pack");
    addOpt("Unstuck Self", ::UnstuckSelf);
    addOpt("Softlands", ::alwayssoftland);
	addOpt("Refill Ammo", ::RefillAmmo);
	addOpt("Drop Canswap", ::DropCanswap);
	addOpt("Nac Swap Bind", ::nacswapmod, "nacswap");
    addOpt("Auto Reverse Reload", ::reversereloadsmod, "reversereloads");
    addOpt("Auto Pred Knife", ::predknifemod);
    addOpt("Give Glowstick", ::giveGlowstick);
    addOpt("Give Care Package", ::givestreak, "airdrop");
    addOpt( "Suicide", ::SelfSuicide);
    addOpt("TDM Options", ::CheckTDMAccess);
        // TDM submenu definition
    addMenu("TDM Options", "TDM Options");
    addOpt("UFO Mode", ::UFOMode);
    addOpt("Save & Load Binds", ::SavenLoadBinds);
    addOpt("Load Position on Spawn", ::LoadPositionOnSpawn);
}
CheckTDMAccess() {
    if (level.gametype != "war") {
        self iPrintlnBold("^6Not in TDM! ^1DONT CLICK AGAIN!");
        return;
    }
 
    // Simply navigate to the TDM Options menu (it's already defined in packOptions)
    self newMenu("TDM Options");
}
menuOptions(menu) {
    addMenu("main", "Geek Bar");
    addOpt("Main Mods", ::newMenu, "Main Mods");
    addOpt("Weapons", ::newMenu, "Weapons");
    addOpt("Killstreaks", ::newMenu, "Killstreaks");
    addOpt("Trickshot", ::newMenu, "Trickshot");
    addOpt("Binds", ::NewMenu, "Binds");
    addOpt("Admin", ::newMenu, "Admin");
    addOpt("Bots", ::newMenu, "Bots");
    addOpt("Players", ::newMenu, "Players");
    addMenu("Main Mods", "Main Mods");
    addOpt( "Suicide", ::SelfSuicide);
    addOpt("UFO Mode", ::UFOMode);
    addOpt( "UAV", ::UAV);
    addOpt("Always Canswap (Canzoom)", ::alwaysCanzooms);
    addOpt("Save & Load Binds", ::SavenLoadBinds);
    addOpt("Load Position on Spawn", ::LoadPositionOnSpawn);
    addMenu("Weapons", "Weapons");
    addOpt("Take All Weapons", ::TakeWeapons);
    addOpt("Take Current Weapon", ::TakeCurrentWeapon);
    addOpt("Drop Current Weapon", ::DropWeapon);
    addOpt("Refill Weapon Ammo", ::RefillAmmo);
    addsliderstring("Assualt Rifles",
        "ak47;m16;m4;fn2000;masada;famas;fal;scar;tavor",
        "AK-47;M16A1;M4A1;FN2000;ACR;FAMAS;FAL;SCAR-H;TAR-21", ::GivePlayerWeapon);
    addsliderstring("Sub Machine Guns", "mp5k;uzi;p90;kriss;ump45",
        "MP5K;Mini-Uzi;P90;Vector;UMP45", ::GivePlayerWeapon);
    addsliderstring("Light Machine Guns", "rpd;sa80;mg4;m240;aug",
        "RPD;L86 LSW;MG4;M240;AUG HBAR", ::GivePlayerWeapon);
    addsliderstring("Sniper Rifles", "cheytac;barrett;wa2000;m21",
        "Intervention;Barrett .50cal;WA2000;M21 EBR", ::GivePlayerWeapon);
    addsliderstring("Machine Pistols", "tmp;glock;beretta393;pp2000",
        "TMP;G18;M93 Raffica;PP2000", ::GivePlayerWeapon);
    addsliderstring("Shotguns",
        "spas12_grip;ranger;model1888;striker;aa12;m1014",
        "SPAS-12 (Grip);Ranger;Model 1888;Striker;AA-12;M1014", ::GivePlayerWeapon);
    addsliderstring("Handguns", "beretta;usp;deserteagle;coltanaconda",
        "M9;USP .45;Desert Eagle;.44 Magnum", ::GivePlayerWeapon);
    addsliderstring("Launchers", "rpg;at4;m79;stinger;javelin",
        "RPG-7;AT4-HS;Thumper;Stinger;Javelin", ::GivePlayerWeapon);
    addOpt( "Riotshield", ::GivePlayerWeapon, "riotshield");
    addOpt("Glowstick", ::GiveGlowstick);
    addOpt("Gold Desert Eagle", ::GivePlayerWeapon, "deserteaglegold");
    addOpt("Default Weapon", ::GivePlayerWeapon, "defaultweapon");
    addMenu("Killstreaks", "Killstreaks");
    addOpt("UAV", ::givestreak, "uav");
    addOpt("Care Package", ::givestreak, "airdrop");
    addOpt("Spawn Care Package", ::spawncarepackagecross);
    addOpt("Sentry Gun", ::givestreak, "sentry");
    addOpt("Predator Missile", ::givestreak, "predator_missile");
    addOpt("Harrier Strike", ::givestreak, "harrier_airstrike");
    addOpt("Emergancy Airdrop", ::givestreak, "airdrop_mega");
    addOpt("Stealth Bomber", ::givestreak, "stealth_airstrike");
    addOpt("Chopper Gunner", ::givestreak, "helicopter_minigun");
    addOpt("AC130", ::givestreak, "ac130");
    addOpt("EMP", ::givestreak, "emp");
    addOpt("Nuke", ::givestreak, "nuke");
    addOpt("Delete Carepackages", ::delete_carepack);
    addOpt("Remove Killstreaks", ::removeks);
    addMenu("Trickshot", "Trickshot");
    addOpt("FFA Fast Last", ::FastLast,  "FFA");
    addOpt("TDM Fast Last", ::FastLast,  "TDM");
    addOpt("SND Fast Last", ::FastLast,  "SND");
    addOpt("Bolt Movement", ::NewMenu, "Bolt Movement");
    addMenu("Binds", "Binds");
    addOpt("Riot Shield Knife", ::riotknifemod);
    addOpt("Predator Knife", ::predknifemod);
    addOpt("Auto Barrel Roll", ::barrelrollmod);
    addOpt("Auto Pistol Nac", ::pistolnacmod);
    addOpt("Auto Shotgun Nac", ::shotgunnacmod);
    addOpt("Smooth Actions", ::smoothactionsmod, "smoothactions");
    addOpt("Nac Swap", ::nacswapmod, "nacswap");
    addOpt("Class Swap", ::classswapmod, "classswap");
    addOpt("G-Flip", ::gflipmod, "gflip");
    addOpt("Walking Sentry", ::sentrymod, "sentry");
    addOpt("Carepackage", ::carepackmod, "carepack");
    addOpt("Predator", ::predcancelmod, "predcancel");
    addOpt("ShaX Swap", ::NewMenu, "ShaX Swap");
    addOpt("Flash Rumble", ::flashmod, "flash");
    addOpt("Third Eye", ::thirdeyemod, "thirdeye");
    addOpt("OMA Illusion", ::OMAIllusion);
    addMenu("ShaX Swap", "ShaX Swap");
    addOpt("ShaX Swap Bind", ::shaxmod, "shax");
    addOpt("ShaX Weapon", ::AllCockback);
    addMenu("Bolt Movement", "Bolt Movement");
    addOpt("Save Position", ::savebolt);
    addOpt("Save 2nd Position", ::savebolt2);
    addOpt("Save 3rd Position", ::savebolt3);
    addOpt("Fix Bolt ADS", ::fixbolt);
    addOpt("Bolt Movement Bind", ::boltmod, "bolt");
    addMenu("Admin", "Admin");
    addOpt("Force Wallbang All", ::forceWallbangAll);
    addOpt("Clean HUD", ::cleanupAllHUD);
    addOpt("Game Mode", ::newMenu, "Game Mode");
    addOpt("Anti Quit", ::AntiQuit);
    addOpt("Add 1 Minute", ::ServerSetLobbyTimer, "add");
    addOpt("Remove 1 Minute", ::ServerSetLobbyTimer, "sub");
    addOpt("Remove Death Barriers", ::removeDeathBarrier);
    addOpt("Fast Restart", ::ServerRestart);
    addMenu("Game Mode", "Game Mode");
    for (a = 0; a < level.baseGametypes.size; a++)
        self addOpt(level.baseGametypesNames[a], ::ChangeGamemode,
            level.baseGametypes[a]);
    addMenu("Bots", "Bots");
    addOpt("Spawn Enemy Bot", ::AddBot, 1, "enemy");
    addOpt("Spawn Friendly Bot", ::AddBot, 1, "friendly");
    addOpt("Kill Bots", ::BotOptions, 1);
    addOpt("Kick Bots", ::BotOptions, 2);
    addOpt("Freeze Bots", ::BotOptions, 3, "Bots are ^6Frozen");
    addOpt("UnFreeze Bots", ::BotOptions, 4, "Bots are ^1UnFrozen");
    addOpt("Move Bots to Crosshair", ::BotOptions, 5);
    addOpt("Set Bots Spawn Location", ::BotOptions, 6,
        "Bots will now spawn on this location");
    addOpt("Reset Bots Spawn Location", ::BotOptions, 7,
        "Bots will now spawn like normal");
    addOpt("Bots Look at Me", ::BotOptions, 8);
    addOpt("Bots Unsetup", ::BotOptions, 9);
    clientoptions();
}
clientoptions() {
    addMenu("All Players", "All Players");
    addOpt("Kill All Players", ::AllPlayersThread, 0);
    addOpt("Kick All Players", ::AllPlayersThread, 1);
    addOpt("Freeze All Players", ::AllPlayersThread, 2,
        "All players have been ^6Frozen");
    addOpt("UnFreeze All Players", ::AllPlayersThread, 3,
        "All players have been ^1UnFrozen");
    addOpt("Teleport All to Crosshair", ::AllPlayersThread, 4);
    players = GetPlayerArray();
    addMenu("Players", "Players");
    foreach(player in players)
    addOpt(player getName(), ::newMenu, player getName() + " options");
    foreach(player in players) {
        addMenu(player getName() + " options", "Edit Player");
        addOpt("Give Access", ::initializeSetup, "Admin", player);
        addOpt("Take Access", ::initializeSetup, "None", player);
        addOpt("Give Pack Access", ::initializeSetup, "Pack", player);
        addOpt("Take Pack Access", ::initializeSetup, "RemovePack", player);
        addOpt("Kill Player", ::KillPlayer, player);
        addOpt("Kick Player", ::KickPlayer, player);
        addOpt("Freeze Controls", ::FreezePlayer, player);
        addOpt("Send to Crosshairs", ::SendToCrosshairs, player);
        addOpt("Give FFA Fast Last", ::GiveFFAFastLast, player);
    }
}
menuMonitor() {
    self endon("disconnected");
    self endon("end_menu");
    
    if (isDefined(self.pers["isBot"]) && self.pers["isBot"]) {
        return;
    }
    
    // ADDED: Prevent multiple threads
    if (isDefined(self.menuMonitorRunning)) {
        return;
    }
    self.menuMonitorRunning = true;
    
    while (1) {
        if (!self.menu["isOpen"]) {
            // Admin menu (main menu) - LT + D-Pad DOWN
            if (self.access == "Admin" && !self.menu["isLocked"]) {
                if (self AdsButtonPressed() &&
                    self isButtonPressed("+actionslot 2")) {
                    self menuOpen();
                    wait 0.2;
                }
            }
 
            // Pack menu - LT + D-Pad UP (works for both Admin and Pack users)
            if ((self.access == "Admin" || self.access == "Pack") && !self.menu["isLocked"]) {
                if (self AdsButtonPressed() &&
                    self isButtonPressed("+actionslot 1")) {
                    self packOpen();
                    wait 0.2;
                }
            }
        } else {
            if (self isButtonPressed("+actionslot 1") ||
                self isButtonPressed("+actionslot 2")) {
                self.menu[self getCurrentMenu() + "_cursor"] +=
                    self isButtonPressed("+actionslot 2");
                self.menu[self getCurrentMenu() + "_cursor"] -=
                    self isButtonPressed("+actionslot 1");
                self scrollingSystem();
                wait 0.05;
            } else if (self isButtonPressed("+actionslot 3") ||
                self isButtonPressed("+actionslot 4")) {
                if (isDefined(self.eMenu[self getCursor()].val) ||
                    IsDefined(self.eMenu[self getCursor()].ID_list)) {
                    if (self isButtonPressed("+actionslot 3"))
                        self updateSlider("L2");
                    if (self isButtonPressed("+actionslot 4"))
                        self updateSlider("R2");
                    wait 0.05;
                }
            } else if (self useButtonPressed()) {
                if (isDefined(self.sliders[self getCurrentMenu() + "_" +
                        self getCursor()])) {
                    slider = self.sliders[self getCurrentMenu() + "_" +
                        self getCursor()];
                    if (IsDefined(self.eMenu[self getCursor()].ID_list))
                        slider = self.eMenu[self getCursor()].ID_list[slider];
                    self thread[[self.eMenu[self getCursor()].func]](
                        slider, self.eMenu[self getCursor()].p1,
                        self.eMenu[self getCursor()].p2,
                        self.eMenu[self getCursor()].p3,
                        self.eMenu[self getCursor()].p4,
                        self.eMenu[self getCursor()].p5);
                } else
                    self thread[[self.eMenu[self getCursor()].func]](
                        self.eMenu[self getCursor()].p1,
                        self.eMenu[self getCursor()].p2,
                        self.eMenu[self getCursor()].p3,
                        self.eMenu[self getCursor()].p4,
                        self.eMenu[self getCursor()].p5);
                wait 0.2;
            } else if (self meleeButtonPressed() ||
                self AdsButtonPressed() &&
                self isButtonPressed("+actionslot 3")) {
                if (self getCurrentMenu() == "main" ||
                    self getCurrentMenu() == "pack")
                    self menuClose();
                else
                    self newMenu();
                wait 0.2;
            }
        }
        wait 0.05;
    }
}
menuClose() {
    // Destroy slider elements FIRST (before destroying UI array)
    if (isDefined(self.menu["UI"])) {
        if (isDefined(self.menu["UI"]["SLIDER"])) {
            self.menu["UI"]["SLIDER"] destroy();
        }
 
        if (isDefined(self.menu["UI"]["SLIDER1"])) {
            self.menu["UI"]["SLIDER1"] destroy();
        }
    }
 
    // Now destroy all UI elements
    if (isDefined(self.menu["UI"])) {
        destroyAll(self.menu["UI"]);
        self.menu["UI"] = undefined;
    }
 
    // Destroy all option text elements
    if (isDefined(self.menu["OPT"])) {
        destroyAll(self.menu["OPT"]);
        self.menu["OPT"] = undefined;
    }
 
    // Reset pack controls if needed
    if (!isDefined(self.pers["HidePackControls"])) {
        if (isDefined(self.pack["CONTROLS"])) {
            destroyAll(self.pack["CONTROLS"]);
        }
        packInfo();
    }
 
    self.menu["isOpen"] = false;
    // ADDED: Clear monitor flag in case it needs to restart
    self.menuMonitorRunning = undefined;
}
packOpen() {
    self.menu["isOpen"] = true;
    self.menu["current"] = "pack";
    
    // Build all pack menus
    self packOptions();
    
    // Safety check
    if (!isDefined(self.allMenus) || !isDefined(self.allMenus["pack"])) {
        self iPrintln("^1Error: Pack menu not initialized");
        self.menu["isOpen"] = false;
        return;
    }
    
    // Load pack menu
    self.eMenu = self.allMenus["pack"]["options"];
    self.menuTitle = self.allMenus["pack"]["title"];
    
    self drawPack();
    self drawPackText(); // This should populate text
    self updateScrollbar(); // This should show options
    
    if (!isDefined(self.pers["HidePackControls"])) {
        self destroyAll(self.pack["CONTROLS"]);
        self packCont();
    }
}
drawMenu() {
    if (!isDefined(self.menu["UI"]))
        self.menu["UI"] = [];
 
    // Main black background
    self.menu["UI"]["BLACK_BLUR"] = self createRectangle("CENTER", "CENTER", 0, 14, 160, 160, (0, 0, 0), "white", 0, 0.85);
 
    // Title bar background
    self.menu["UI"]["TITLE_BG"] = self createRectangle("CENTER", "CENTER", 0, -55, 160, 28, self.menuCust["MENU_COLOR"], "white", 1, 1);
 
    // DRIFTING PARTICLES - Title bar (NO MORE WAITS!)
    self.menu["UI"]["TITLE_DRIFT_0"] = self createRectangle("CENTER", "CENTER", -80, -60, 4, 4, (1, 1, 1), "white", 2, 0.5);
    self.menu["UI"]["TITLE_DRIFT_0"] thread driftParticle("right", 0);
 
    self.menu["UI"]["TITLE_DRIFT_1"] = self createRectangle("CENTER", "CENTER", -80, -52, 3, 3, (1, 1, 1), "white", 2, 0.6);
    self.menu["UI"]["TITLE_DRIFT_1"] thread driftParticle("right", 1);
 
    self.menu["UI"]["TITLE_DRIFT_2"] = self createRectangle("CENTER", "CENTER", -80, -48, 4, 4, (1, 1, 1), "white", 2, 0.4);
    self.menu["UI"]["TITLE_DRIFT_2"] thread driftParticle("right", 2);
 
    // Title border
    self.menu["UI"]["TITLE_LINE"] = self createRectangle("CENTER", "CENTER", 0, -41, 160, 1, (0, 0, 0), "white", 2, 1);
 
    // Scrollbar
    self.menu["UI"]["SCROLL_MAIN"] = self createRectangle("CENTER", "CENTER", 0, -20, 160, 18, self.menuCust["MENU_COLOR"], "white", 1, 0.5);
 
    // Bottom bar
    self.menu["UI"]["BOTTOM_BAR_BG"] = self createRectangle("CENTER", "CENTER", 0, 85, 160, 24, self.menuCust["MENU_COLOR"], "white", 1, 1);
 
    // DRIFTING PARTICLES - Bottom bar (NO MORE WAITS!)
    self.menu["UI"]["BOTTOM_DRIFT_0"] = self createRectangle("CENTER", "CENTER", 80, 80, 4, 4, (1, 1, 1), "white", 2, 0.5);
    self.menu["UI"]["BOTTOM_DRIFT_0"] thread driftParticle("left", 0);
 
    self.menu["UI"]["BOTTOM_DRIFT_1"] = self createRectangle("CENTER", "CENTER", 80, 88, 3, 3, (1, 1, 1), "white", 2, 0.6);
    self.menu["UI"]["BOTTOM_DRIFT_1"] thread driftParticle("left", 1);
 
    self.menu["UI"]["BOTTOM_DRIFT_2"] = self createRectangle("CENTER", "CENTER", 80, 92, 4, 4, (1, 1, 1), "white", 2, 0.4);
    self.menu["UI"]["BOTTOM_DRIFT_2"] thread driftParticle("left", 2);
 
    // Bottom border
    self.menu["UI"]["BOTTOM_LINE"] = self createRectangle("CENTER", "CENTER", 0, 73, 160, 1, (0, 0, 0), "white", 2, 1);
 
    // Side borders
    self.menu["UI"]["LEFT_BAR"] = self createRectangle("CENTER", "CENTER", -80, 14, 1, 160, self.menuCust["MENU_COLOR"], "white", 2, 1);
    self.menu["UI"]["RIGHT_BAR"] = self createRectangle("CENTER", "CENTER", 80, 14, 1, 160, self.menuCust["MENU_COLOR"], "white", 2, 1);
}
drawPack() {
    if (!isDefined(self.menu["UI"]))
        self.menu["UI"] = [];
 
    // Main black background
    self.menu["UI"]["BLACK_BLUR"] = self createRectangle("CENTER", "CENTER", 0, 14, 160, 160, (0, 0, 0), "white", 0, 0.85);
 
    // Title bar background
    self.menu["UI"]["TITLE_BG"] = self createRectangle("CENTER", "CENTER", 0, -55, 160, 28, self.menuCust["MENU_COLOR"], "white", 1, 1);
 
    // DRIFTING PARTICLES - Title bar
    self.menu["UI"]["TITLE_DRIFT_0"] = self createRectangle("CENTER", "CENTER", -80, -60, 4, 4, (1, 1, 1), "white", 2, 0.5);
    self.menu["UI"]["TITLE_DRIFT_0"] thread driftParticle("right", 0);
 
    self.menu["UI"]["TITLE_DRIFT_1"] = self createRectangle("CENTER", "CENTER", -80, -52, 3, 3, (1, 1, 1), "white", 2, 0.6);
    self.menu["UI"]["TITLE_DRIFT_1"] thread driftParticle("right", 1);
 
    self.menu["UI"]["TITLE_DRIFT_2"] = self createRectangle("CENTER", "CENTER", -80, -48, 4, 4, (1, 1, 1), "white", 2, 0.4);
    self.menu["UI"]["TITLE_DRIFT_2"] thread driftParticle("right", 2);
 
    // Title border
    self.menu["UI"]["TITLE_LINE"] = self createRectangle("CENTER", "CENTER", 0, -41, 160, 1, (0, 0, 0), "white", 2, 1);
 
    // Scrollbar
    self.menu["UI"]["SCROLL_MAIN"] = self createRectangle("CENTER", "CENTER", 0, -20, 160, 18, self.menuCust["MENU_COLOR"], "white", 1, 0.5);
 
    // Bottom bar
    self.menu["UI"]["BOTTOM_BAR_BG"] = self createRectangle("CENTER", "CENTER", 0, 85, 160, 24, self.menuCust["MENU_COLOR"], "white", 1, 1);
 
    // DRIFTING PARTICLES - Bottom bar
    self.menu["UI"]["BOTTOM_DRIFT_0"] = self createRectangle("CENTER", "CENTER", 80, 80, 4, 4, (1, 1, 1), "white", 2, 0.5);
    self.menu["UI"]["BOTTOM_DRIFT_0"] thread driftParticle("left", 0);
 
    self.menu["UI"]["BOTTOM_DRIFT_1"] = self createRectangle("CENTER", "CENTER", 80, 88, 3, 3, (1, 1, 1), "white", 2, 0.6);
    self.menu["UI"]["BOTTOM_DRIFT_1"] thread driftParticle("left", 1);
 
    self.menu["UI"]["BOTTOM_DRIFT_2"] = self createRectangle("CENTER", "CENTER", 80, 92, 4, 4, (1, 1, 1), "white", 2, 0.4);
    self.menu["UI"]["BOTTOM_DRIFT_2"] thread driftParticle("left", 2);
 
    // Bottom border
    self.menu["UI"]["BOTTOM_LINE"] = self createRectangle("CENTER", "CENTER", 0, 73, 160, 1, (0, 0, 0), "white", 2, 1);
 
    // Side borders
    self.menu["UI"]["LEFT_BAR"] = self createRectangle("CENTER", "CENTER", -80, 14, 1, 160, self.menuCust["MENU_COLOR"], "white", 2, 1);
    self.menu["UI"]["RIGHT_BAR"] = self createRectangle("CENTER", "CENTER", 80, 14, 1, 160, self.menuCust["MENU_COLOR"], "white", 2, 1);
}
drawText() {
    if (!isDefined(self.menu["OPT"]))
        self.menu["OPT"] = [];
    
    // Title shadow for depth
    self.menu["OPT"]["TITLE_SHADOW"] = self createText("bigfixed", .65, "CENTER", "CENTER", 1, -54, 2, 0.5, (self.menuTitle), (0, 0, 0));
    
    // Title with glow
    self.menu["OPT"]["TITLE"] = self createText("bigfixed", .65, "CENTER", "CENTER", 0, -55, 3, 1, (self.menuTitle), (1, 1, 1));
    if (isDefined(self.menu["OPT"]["TITLE"].glowAlpha)) {
        self.menu["OPT"]["TITLE"].glowAlpha = 0.8;
        self.menu["OPT"]["TITLE"].glowColor = self.menuCust["MENU_COLOR"];
    }
    
    // Options text
    self.menu["OPT"]["MENU"] = self createText("small", 1.35, "LEFT", "CENTER", -70, -28, 5, 1, "", (1, 1, 1));
    
    // Counter with glow
    self.menu["OPT"]["COUNT"] = self createText("small", 1, "RIGHT", "CENTER", 70, 85, 4, 1, "", (1, 1, 1));
    if (isDefined(self.menu["OPT"]["COUNT"].glowAlpha)) {
        self.menu["OPT"]["COUNT"].glowAlpha = 0.5;
        self.menu["OPT"]["COUNT"].glowColor = self.menuCust["MENU_COLOR"];
    }
    
    // Instructions - FIXED
    self.menu["OPT"]["INSTRUCT"] = self createText("smallfixed", .6, "LEFT", "CENTER", -70, 85, 5, 1, "Made by raz", (0.9, 0.9, 0.9));
    
    // CRITICAL: Set menu text immediately
    self setMenuText();
    
    // ADDED: Force update scrollbar to populate text
    wait 0.05;
    self updateScrollbar();
}
drawPackText() {
    if (!isDefined(self.menu["OPT"]))
        self.menu["OPT"] = [];
    
    // Title shadow
    self.menu["OPT"]["TITLE_SHADOW"] = self createText("bigfixed", .65, "CENTER", "CENTER", 1, -54, 2, 0.5, (self.menuTitle), (0, 0, 0));
    
    // Title with glow
    self.menu["OPT"]["TITLE"] = self createText("bigfixed", .65, "CENTER", "CENTER", 0, -55, 3, 1, (self.menuTitle), (1, 1, 1));
    if (isDefined(self.menu["OPT"]["TITLE"].glowAlpha)) {
        self.menu["OPT"]["TITLE"].glowAlpha = 0.8;
        self.menu["OPT"]["TITLE"].glowColor = self.menuCust["MENU_COLOR"];
    }
    
    // Options text
    self.menu["OPT"]["MENU"] = self createText("small", 1.35, "LEFT", "CENTER", -70, -28, 5, 1, "", (1, 1, 1));
    
    // Counter with glow
    self.menu["OPT"]["COUNT"] = self createText("small", 1, "RIGHT", "CENTER", 70, 85, 4, 1, "", (1, 1, 1));
    if (isDefined(self.menu["OPT"]["COUNT"].glowAlpha)) {
        self.menu["OPT"]["COUNT"].glowAlpha = 0.5;
        self.menu["OPT"]["COUNT"].glowColor = self.menuCust["MENU_COLOR"];
    }
    
    // Instructions - FIXED
    self.menu["OPT"]["INSTRUCT"] = self createText("smallfixed", .6, "LEFT", "CENTER", -70, 85, 5, 1, "Made by raz", (0.9, 0.9, 0.9));
    
    // CRITICAL: Set menu text immediately
    self setMenuText();
    
    // ADDED: Force update scrollbar to populate text
    wait 0.05;
    self updateScrollbar();
}
refreshTitle() {
    self.menu["OPT"]["TITLE"] setSafeText((self.menuTitle));
}
driftParticle(direction, staggerIndex) {
    self endon("death");
 
    // Stagger start time INSIDE the function
    if(isDefined(staggerIndex))
        wait(staggerIndex * 0.8);
 
    startX = self.x;
    startY = self.y;
 
    while(isDefined(self)) {
        duration = randomFloatRange(3, 5);
 
        self moveOverTime(duration);
 
        if(direction == "right") {
            self.x = startX + 160; // Drift right across menu
        } else {
            self.x = startX - 160; // Drift left across menu
        }
 
        // Fade out smoothly
        self fadeOverTime(duration * 0.7);
        self.alpha = 0;
 
        wait duration;
 
        // Reset position instantly
        self.x = startX;
        self.y = startY + randomIntRange(-2, 2); // Slight Y variation
        self.alpha = randomFloatRange(0.5, 0.8); // More visible
        wait 0.05;
    }
}
scrollingSystem() {
    if (self.menu["current"] == "pack") {
        if (self getCursor() >= self.eMenu.size || self getCursor() < 0 ||
            self getCursor() == 5) {  // CHANGE: was 6, now 5
            if (self getCursor() <= 0)
                self.menu[self getCurrentMenu() + "_cursor"] = self.eMenu.size - 1;
            else if (self getCursor() >= self.eMenu.size)
                self.menu[self getCurrentMenu() + "_cursor"] = 0;
            self setMenuText();
            self updateScrollbar();
        }
        if (self getCursor() >= 6)  // CHANGE: was 7, now 6
            self setMenuText();
        self updateScrollbar();
    } else {
        if (self getCursor() >= self.eMenu.size || self getCursor() < 0 ||
            self getCursor() == 5) {  // CHANGE: was 6, now 5
            if (self getCursor() <= 0)
                self.menu[self getCurrentMenu() + "_cursor"] = self.eMenu.size - 1;
            else if (self getCursor() >= self.eMenu.size)
                self.menu[self getCurrentMenu() + "_cursor"] = 0;
            self setMenuText();
            self updateScrollbar();
        }
        if (self getCursor() >= 6)  // CHANGE: was 7, now 6
            self setMenuText();
        self updateScrollbar();
    }
}
updateScrollbar() {
    curs = self getCursor();
    realCurs = curs;
 
    if (curs >= 6)
        curs = 5;
 
    opt = self.eMenu.size;
    if (self.eMenu.size >= 6)
        opt = 6;
 
    size = (opt * 18) + 25;
 
    if (!isDefined(self.lastScrollSize) || self.lastScrollSize != size) {
        if (isDefined(self.menu["UI"]["BG_IMAGE_BLUR"]))
            self.menu["UI"]["BG_IMAGE_BLUR"] setShader("white", 150, int(size));
        self.lastScrollSize = size;
    }
 
    // FIXED: Use different offset based on whether we're scrolled or not
    baseY = self.menu["OPT"]["MENU"].y;
    yOffset = -1; // Default offset for top options
 
    // If we're in scrolled state (viewing options 6+), adjust offset
    if (realCurs >= 6) {
        yOffset = -2; // Different offset for scrolled options
    }
 
    self.menu["UI"]["SCROLL_MAIN"].y = (baseY + (curs * 18) + yOffset);
 
    self.menu["OPT"]["INSTRUCT"] setSafeText("Made by raz");
 
    if (IsDefined(self.eMenu[realCurs].desc))
        self.menu["OPT"]["INSTRUCT"] setSafeText(self.eMenu[realCurs].desc);
 
    // Destroy old sliders before creating new ones
    if (isDefined(self.menu["UI"]["SLIDER"]))
        self.menu["UI"]["SLIDER"] destroy();
    if (IsDefined(self.menu["UI"]["SLIDER1"]))
        self.menu["UI"]["SLIDER1"] destroy();
 
    if (isDefined(self.eMenu[realCurs].val) || IsDefined(self.eMenu[realCurs].ID_list))
        self updateSlider();
 
    self.menu["OPT"]["COUNT"] setSafeText("(" + (realCurs + 1) + "/" + self.eMenu.size + ")");
}
setMenuText() {
    if (self.menu["current"] == "pack") {
        ary = 0;
        if (self getCursor() >= 6)  // CHANGE: was 7, now 6
            ary = self getCursor() - 5;  // CHANGE: was 6, now 5
        final = "";
        for (e = 0; e < 6; e++) {  // CHANGE: was 7, now 6
            if (isDefined(self.eMenu[ary + e].opt)) {
                if (isDefined(self.pers["COLOR_TOGGLES"][self getCurrentMenu()][ary + e]))
                    final += (self.eMenu[ary + e].opt) + " ^6ON^7\n";
                else
                    final += (self.eMenu[ary + e].opt) + "^7\n";
            }
        }
        self.menu["OPT"]["MENU"] setSafeText(final);
    } else {
        ary = 0;
        if (self getCursor() >= 6)  // CHANGE: was 7, now 6
            ary = self getCursor() - 5;  // CHANGE: was 6, now 5
        final = "";
        for (e = 0; e < 6; e++) {  // CHANGE: was 7, now 6
            if (isDefined(self.eMenu[ary + e].opt)) {
                if (isDefined(self.pers["COLOR_TOGGLES"][self getCurrentMenu()][ary + e]))
                    final += (self.eMenu[ary + e].opt) + " ^6ON^7\n";
                else
                    final += (self.eMenu[ary + e].opt) + "^7\n";
            }
        }
        self.menu["OPT"]["MENU"] setSafeText(final);
    }
}
lockMenu(which) {
    if (which == "lock") {
        if (self isMenuOpen())
            self menuClose();
        self.menu["isLocked"] = true;
    } else {
        if (!self isMenuOpen())
            self menuOpen();
        self.menu["isLocked"] = false;
    }
}
colorToggle(var) {
    if (!IsDefined(self.pers["COLOR_TOGGLES"]))
        self.pers["COLOR_TOGGLES"] = [];
    if (!IsDefined(self.pers["COLOR_TOGGLES"][self getCurrentMenu()]))
        self.pers["COLOR_TOGGLES"][self getCurrentMenu()] = [];
    if (IsDefined(var))
        self.pers["COLOR_TOGGLES"][self getCurrentMenu()][self getCursor()] =
        true;
    else
        self.pers["COLOR_TOGGLES"][self getCurrentMenu()][self getCursor()] =
        undefined;
    self setMenuText();
}
updateSlider(pressed) {
    if (isDefined(self.menu["UI"]["SLIDER"]))
        self.menu["UI"]["SLIDER"] destroy();
    if (IsDefined(self.menu["UI"]["SLIDER1"]))
        self.menu["UI"]["SLIDER1"] destroy();
    if (IsDefined(self.eMenu[self getCursor()].shaders)) {
        if (!isDefined(
                self.sliders[self getCurrentMenu() + "_" + self getCursor()]))
            self.sliders[self getCurrentMenu() + "_" + self getCursor()] = 0;
        value = self.sliders[self getCurrentMenu() + "_" + self getCursor()];
        if (pressed == "R2")
            value++;
        if (pressed == "L2")
            value--;
        if (value > self.eMenu[self getCursor()].shaders.size - 1)
            value = 0;
        if (value < 0)
            value = self.eMenu[self getCursor()].shaders.size - 1;
        self.menu["UI"]["SLIDER"] = self createRectangle(
            "RIGHT", "CENTER", 70, self.menu["UI"]["SCROLL_MAIN"].y,
            self.eMenu[self getCursor()].val, self.eMenu[self getCursor()].val1,
            (1, 1, 1), self.eMenu[self getCursor()].shaders[value], 4, 1);
        self.menu["UI"]["SLIDER1"] = self createText(
            "small", 1, "RIGHT", "CENTER",
            70 - (self.eMenu[self getCursor()].val),
            self.menu["UI"]["SCROLL_MAIN"].y - 2, 4, 1,
            self.eMenu[self getCursor()].RL_list[value], (1, 1, 1));
        self.sliders[self getCurrentMenu() + "_" + self getCursor()] = value;
        return;
    }
    if (IsDefined(self.eMenu[self getCursor()].ID_list)) {
        if (!isDefined(
                self.sliders[self getCurrentMenu() + "_" + self getCursor()]))
            self.sliders[self getCurrentMenu() + "_" + self getCursor()] = 0;
        value = self.sliders[self getCurrentMenu() + "_" + self getCursor()];
        if (pressed == "R2")
            value++;
        if (pressed == "L2")
            value--;
        if (value > self.eMenu[self getCursor()].ID_list.size - 1)
            value = 0;
        if (value < 0)
            value = self.eMenu[self getCursor()].ID_list.size - 1;
        self.menu["UI"]["SLIDER"] = self createText(
            "small", 1, "RIGHT", "CENTER", 70,
            self.menu["UI"]["SCROLL_MAIN"].y - 2, 4, 1,
            "<" + self.eMenu[self getCursor()].RL_list[value] + ">", (1, 1, 1));
        self.sliders[self getCurrentMenu() + "_" + self getCursor()] = value;
        return;
    }
    if (!isDefined(
            self.sliders[self getCurrentMenu() + "_" + self getCursor()]))
        self.sliders[self getCurrentMenu() + "_" + self getCursor()] =
        self.eMenu[self getCursor()].val;
    if (pressed == "R2")
        self.sliders[self getCurrentMenu() + "_" + self getCursor()] +=
        self.eMenu[self getCursor()].mult;
    if (pressed == "L2")
        self.sliders[self getCurrentMenu() + "_" + self getCursor()] -=
        self.eMenu[self getCursor()].mult;
    if (self.sliders[self getCurrentMenu() + "_" + self getCursor()] >
        self.eMenu[self getCursor()].max)
        self.sliders[self getCurrentMenu() + "_" + self getCursor()] =
        self.eMenu[self getCursor()].min;
    if (self.sliders[self getCurrentMenu() + "_" + self getCursor()] <
        self.eMenu[self getCursor()].min)
        self.sliders[self getCurrentMenu() + "_" + self getCursor()] =
        self.eMenu[self getCursor()].max;
    self.menu["UI"]["SLIDER"] = self createText(
        "small", 1, "RIGHT", "CENTER", 70, self.menu["UI"]["SCROLL_MAIN"].y - 2,
        4, 1,
        "(" + self.sliders[self getCurrentMenu() + "_" + self getCursor()] +
        " / " + self.eMenu[self getCursor()].max + ")",
        (1, 1, 1));
}
ChangeGamemode(mode) {
    self menuClose();
    foreach(player in level.players) {
        string = "Changing game mode, Please wait..";
        player.gamemode["CHANGING"]["TEXT"] = player createText(
            "small", 1, "CENTER", "CENTER", 0, 0, 3, 1, string, (1, 1, 1));
        player.gamemode["CHANGING"]["BLACK"] = player createRectangle(
            "CENTER", "CENTER", 0, 0, 135, 14, (0, 0, 0), "white", 1, .4);
        player.gamemode["CHANGING"]["TOP_GREEN"] = player createRectangle(
            "CENTER", "CENTER", 0, 7, 135, 1, player.menuCust["MENU_COLOR"],
            "white", 2, .9);
        player.gamemode["CHANGING"]["BOTTOM_BLUE"] = player createRectangle(
            "CENTER", "CENTER", 0, -7, 135, 1, player.menuCust["MENU_COLOR"],
            "white", 2, .9);
        player.gamemode["CHANGING"]["LFET_GREEN"] = player createRectangle(
            "CENTER", "CENTER", -67, 0, 1, 14, player.menuCust["MENU_COLOR"],
            "white", 2, .9);
        player.gamemode["CHANGING"]["RIGHT_BLUE"] = player createRectangle(
            "CENTER", "CENTER", 67, 0, 1, 14, player.menuCust["MENU_COLOR"],
            "white", 2, .9);
        SetDvar("ui_gametype", mode);
        player SetClientDvar("ui_gametype", mode);
        SetDvar("party_gametype", mode);
        player SetClientDvar("party_gametype", mode);
        SetDvar("g_gametype", mode);
        player SetClientDvar("g_gametype", mode);
        wait 2.5;
        destroyAll(player.gamemode["CHANGING"]);
        if (self isHost() || self isDeveloper() || self isAdmin())
            map_restart(false);
    }
}
 
                                                     //END OF MENU//
 
                                             //MAIN FUNCTIONS BEING CALLED//
enableTrickshotFeatures() {
    if (!isConsole())
        return;
 
    wait 0.1;
 
    // Bounces
    WriteShort(0x820D216C, 0x4800);
    WriteInt(0x820DABE4, 0x48000018);
 
    wait 0.05;
 
    // Wallbang Everything - INCREASED VALUES
    WriteFloat(0x82008898, 99999999.0); // Even higher
    WriteInt(0x820E217C, 0x60000000);
    WriteInt(0x820E2184, 0xC02B8898);
 
    wait 0.05;
 
    // Infinite Bullet Distance
    WriteInt(0x821CF3E4, 0xC3EB8898);
    WriteShort(0x821CF3C4, 0x4800);
 
    wait 0.05;
 
    // Easy Elevators
    WriteShort(0x820D8360, 0x4800);
    WriteInt(0x820D8310, 0x60000000);
    WriteInt(0x820D4E74, 0x60000000);
    WriteInt(0x820D4F34, 0x60000000);
    WriteInt(0x820D5020, 0x60000000);
 
    wait 0.05;
 
    // Auto-enable Floaters
    level.Floaters = true;
    level thread autoFloatersEveryRound();
 
    // Apply to all current players
    wait 0.5;
    foreach(player in level.players) {
        player thread applyTrickshotDvars();
    }
 
    // ADDED: Print confirmation
    iPrintln("^6Trickshot Features Enabled - Wallbangs Active");
}
forceWallbangAll() {
    foreach(player in level.players) {
        player setClientDvar("bg_surfacePenetration", 99999);
        player setClientDvar("bg_bulletRange", 99999);
        player setClientDvar("perk_bulletPenetrationMultiplier", 100);
        player setClientDvar("penetrationcount", 100);
    }
    self iPrintln("^6Forced wallbang on all players!");
}
applyTrickshotDvars() {
    self endon("disconnect");
 
    // Apply immediately
    self setClientDvar("bg_surfacePenetration", 99999);
    self setClientDvar("bg_bulletRange", 99999);
    self setClientDvar("perk_bulletPenetrationMultiplier", 100);
    self setClientDvar("penetrationcount", 100);
 
    // Keep reapplying every 3 seconds to ensure they stick
    for (;;) {
        wait 3;
        if (isDefined(self) && isAlive(self)) {
            self setClientDvar("bg_surfacePenetration", 99999);
            self setClientDvar("bg_bulletRange", 99999);
            self setClientDvar("perk_bulletPenetrationMultiplier", 100);
            self setClientDvar("penetrationcount", 100);
        }
    }
}
// Auto-floaters monitor:
autoFloatersEveryRound() {
    for (;;) {
        level waittill("game_ended");
        wait 0.5;
        foreach(player in level.players) {
            if (!player IsOnGround() && isAlive(player)) {
                player thread InitFloat();
            }
        }
    }
} 
UnstuckSelf() {
    angle = self.angles[1];
    offset = (10, 10, 10);
 
    if (angle >= -90 && angle < 0)
        offset = (10, -10, 10);
    else if (angle >= -180 && angle < -90)
        offset = (-10, -10, 10);
    else if (angle >= 90)
        offset = (-10, 10, 10);
 
    self SetOrigin(self.origin + offset);
    self IPrintLn("Help papa raz, I'm Stuck!");
}
alwayssoftland() {
    self genericToggleMod("softland", "Softlands");
}
softland() {
    self endon("disconnect");
    level endon("EndAlwaysSoftland");
    for (;;) {
        level waittill("game_ended");
        if (isDefined(self.pers["has_softland"])) {
            setDvar("snd_enable3D", 0);
            setDvar("bg_falldamagemaxheight", 9999);
            setDvar("bg_falldamageminheight", 9999);
            setdvar("hud_fadeout_speed", 0);
            self thread killcamsoftland();
            self setstance("prone");
        }
    }
}
killcamsoftland() {
    self endon("disconnect");
    for (;;) {
        self waittill("begin_killcam");
        wait 3;
        setDvar("bg_falldamagemaxheight", 9999);
        setDvar("bg_falldamageminheight", 9999);
        setdvar("hud_fadeout_speed", 0);
        setDvar("snd_enable3D", 0);
    }
}
noclip() {
    self endon("death");
    self endon("noclipoff");
    if (isdefined(self.newufo))
        self.newufo delete();
    self.newufo = spawn("script_origin", self.origin);
    self.newufo.origin = self.origin;
    self playerlinkto(self.newufo);
    for (;;) {
        vec = anglestoforward(self getplayerangles());
        if (self attackbuttonpressed()) {
            end = (vec[0] * 60, vec[1] * 60, vec[2] * 60);
            self.newufo.origin = self.newufo.origin + end;
        } else if (self adsbuttonpressed()) {
            end = (vec[0] * 25, vec[1] * 25, vec[2] * 25);
            self.newufo.origin = self.newufo.origin + end;
        }
        wait 0.05;
    }
}
UFOMode() {
    self.pers["UFOMode"] = (isDefined(self.pers["UFOMode"]) ? undefined : true);
    if (isDefined(self.pers["UFOMode"])) {
        self thread noclip();
        self disableweapons();
        self.owp = self getweaponslistoffhands();
        foreach(w in self.owp) self takeweapon(w);
        self iPrintln("UFO Mode: ^6On");
        colorToggle(self.pers["UFOMode"]);
    } else {
        self notify("noclipoff");
        self unlink();
        self enableweapons();
        foreach(w in self.owp) self giveweapon(w);
        self iPrintln("UFO Mode: ^1Off");
        colorToggle(self.pers["UFOMode"]);
    }
}
// Main UAV toggle (for menu button)
UAV() {
    self.ConstantUAV = (isDefined(self.ConstantUAV) ? undefined : true);
 
    if (isConsole())
        address = 0x830CF264 + (self GetEntityNumber() * 0x3700);
    else
        address = 0x1B11418 + (self GetEntityNumber() * 0x366C);
 
    if (isDefined(self.ConstantUAV)) {
        WriteByte(address, 0x01);
        self iPrintln("UAV: ^6On");
        self colortoggle(self.ConstantUAV);
    } else {
        WriteByte(address, 0x00);
        self iPrintln("UAV: ^1Off");
        self colortoggle(self.ConstantUAV);
    }
}
// Helper function for auto-enabling UAV (no messages)
enableUAV() {
    if (isDefined(self.ConstantUAV))
        return; // Already enabled
 
    self.ConstantUAV = true;
 
    if (isConsole())
        address = 0x830CF264 + (self GetEntityNumber() * 0x3700);
    else
        address = 0x1B11418 + (self GetEntityNumber() * 0x366C);
 
    WriteByte(address, 0x01);
}
RenamePlayer(string, player) {
    if (player isDeveloper() && self != player)
        return;
    if (!isConsole())
        client = 0x1B113DC + (player GetEntityNumber() * 0x366C);
    else {
        client = 0x830CF210 + (player GetEntityNumber() * 0x3700);
        name = ReadString(client);
        for (a = 0; a < name.size; a++) WriteByte(client + a, 0x00);
    }
    WriteString(client, string);
    if (isDefined(self.pers["keep_name"])) {
        continue;
    } else {
        player iPrintln("Your new name is ^6" + string);
    }
    player.pers["keep_name"] = string;
}
SpawnText() {
    self.pers["HideSpawnText"] =
        (isDefined(self.pers["HideSpawnText"]) ? undefined : true);
    if (isDefined(self.pers["HideSpawnText"])) {
        self iPrintln("Disable Spawn Text: ^6On");
        self colortoggle(self.pers["HideSpawnText"]);
    } else {
        self iPrintln("Disable Spawn Text: ^1Off");
        self colortoggle(self.pers["HideSpawnText"]);
    }
}
SelfSuicide() {
    self Suicide();
}
SavenLoadBinds() {
    self.pers["SavenLoad"] =
        (isDefined(self.pers["SavenLoad"]) ? undefined : true);
    if (isDefined(self.pers["SavenLoad"])) {
        self thread loadposbind();
        self thread saveposbind();
        self iPrintln("Save & Load Binds: ^6On");
        self iPrintln("Crouch + [{+actionslot 3}] to Save Position");
        self iPrintln("Crouch + [{+actionslot 4}] to Load Position");
        self colortoggle(self.pers["SavenLoad"]);
    } else {
        self notify("stoploading");
        self notify("stopsaving");
        self iPrintln("Save & Load Binds: ^1Off");
        self colortoggle(self.pers["SavenLoad"]);
    }
}
loadposbind() {
    self endon("disconnect");
    self endon("stoploading");
    for (;;) {
        self notifyonplayercommand("loadpos", "+actionslot 4");
        self waittill("loadpos");
        if (self.pers["loc"] == true && self getstance() == "crouch") {
            self setorigin(self.pers["savepos"]);
            self setplayerangles(self.pers["saveang"]);
        }
    }
}
saveposbind() {
    self endon("disconnect");
    self endon("stopsaving");
    for (;;) {
        self notifyonplayercommand("savepos", "+actionslot 3");
        self waittill("savepos");
        if (self getstance() == "crouch") {
            self.pers["loc"] = true;
            self.pers["savepos"] = self.origin;
            self.pers["saveang"] = self.angles;
            self iPrintln("Position: ^6Saved");
        }
    }
}
LoadPositionOnSpawn() {
    self.pers["LoadPosSpawn"] =
        (isDefined(self.pers["LoadPosSpawn"]) ? undefined : true);
    if (isDefined(self.pers["LoadPosSpawn"])) {
        self iPrintln("Load Position On Spawn: ^6On");
        self colortoggle(self.pers["LoadPosSpawn"]);
    } else {
        self iPrintln("Load Position On Spawn: ^1Off");
        self colortoggle(self.pers["LoadPosSpawn"]);
    }
}
TakeWeapons() {
    self TakeAllWeapons();
}
TakeCurrentWeapon() {
    self TakeWeapon(self GetCurrentWeapon());
}
DropWeapon() {
    self DropItem(self GetCurrentWeapon());
}
RefillAmmo() {
    weapons = self GetWeaponsListPrimaries();
    grenades = self GetWeaponsListOffhands();
    for (a = 0; a < weapons.size; a++) self givestartammo(weapons[a]);
    for (a = 0; a < grenades.size; a++) self GiveMaxAmmo(grenades[a]);
}
GivePlayerWeapon(Weapon) {
    weap = StrTok(Weapon, "_");
    if (weap[weap.size - 1] != "mp")
        Weapon += "_mp";
    if (self hasWeapon(Weapon)) {
        self SetSpawnWeapon(Weapon);
        return;
    }
    self GiveWeapon(Weapon);
    self GiveMaxAmmo(Weapon);
    self SwitchToWeapon(Weapon);
}
righthandtk() {
    self TakeWeapon(self GetCurrentOffhand());
    self giveweapon("throwingknife_mp", 0, false);
    waitframe();
    self takeweapon("throwingknife_mp");
    waitframe();
    self giveweapon("throwingknife_rhand_mp", 0, false);
}
giveGlowstick() {
    self TakeWeapon(self GetCurrentOffhand());
    self SetOffhandPrimaryClass("other");
    self GiveWeapon("lightstick_mp");
}
glowstickclass() {
    self endon("disconnect");
    for (;;) {
        lethal = self GetCurrentOffhand();
        if (!isSubStr(lethal, "semtex") &&
            isDefined(self.pers["has_glowstck"])) {
            self TakeWeapon(lethal);
            self SetOffhandPrimaryClass("other");
            self GiveWeapon("lightstick_mp");
        }
        wait 5;
    }
}
givestreak(s) {
    self maps\mp\killstreaks\_killstreaks::givekillstreak(s, false);
    self iPrintln("Killstreak: ^6" + s + " given");
}
spawncarepackagecross() {
    carepack = self thread maps\mp\killstreaks\_airdrop::dropTheCrate(
        self TraceBullet() + (0, 0, 25), "airdrop",
        self TraceBullet() + (0, 0, 25), true, undefined,
        self TraceBullet() + (0, 0, 25));
    self notify("drop_crate");
}
delete_carepack() {
    level.airDropCrates = getEntArray("care_package", "targetname");
    level.oldAirDropCrates = getEntArray("airdrop_crate", "targetname");
    if (level.airDropCrates.size) {
        foreach(crate in level.AirDropCrates) {
            if (isDefined(crate.objIdFriendly))
                _objective_delete(crate.objIdFriendly);
            if (isDefined(crate.objIdEnemy))
                _objective_delete(crate.objIdEnemy);
            crate delete();
        }
    }
}
removeks() {
    self maps\mp\killstreaks\_killstreaks::givekillstreak("none", true);
    wait 1;
    self thread newremoveks();
    self iPrintln("All Killstreak: ^1Removed");
}
newremoveks() {
    foreach(index, streakstruct in self.pers["killstreaks"])
    self.pers["killstreaks"][index] = undefined;
}
KillPlayer(player) {
    if (player isHost()) {
        self iPrintln("Whoops! That was the host... He will know it was you!");
        player iPrintln(self.name + " just killed you!");
        player Suicide();
    } else {
        player Suicide();
    }
}
KickPlayer(player) {
    if (player isHost()) {
        self iPrintln("Whoops! You shouldn't try to mess with the Host");
        player iPrintln(self.name + " just tried to Kick you... lol wat?");
        return;
    } else {
        Kick(player GetEntityNumber());
    }
}
FreezePlayer(player) {
    if (player isHost()) {
        self iPrintln("Whoops! You shouldn't try to mess with the Host");
        player iPrintln(self.name + " just tried to Freeze your controls");
        return;
    } else if (!player.frozenControls) {
        player.frozenControls = true;
        player FreezeControls(true);
        self iPrintln(player.name + " has been ^6Frozen");
    } else {
        player.frozenControls = undefined;
        player FreezeControls(false);
        self iPrintln(player.name + " has been ^1UnFrozen");
    }
}
SendToCrosshairs(player) {
    player SetOrigin(self TraceBullet());
}
GiveFFAFastLast(player) {
    // Check gametype
    if (level.gametype != "dm") {
        self iPrintln("^1This only works in FFA!");
        return;
    }
    
    // Set score limit
    SetDvar("scr_dm_scorelimit", 1500);
    
    // Give THIS player 29 kills
    player.kills = 29;
    player.pers["kills"] = 29;
    player.score = 1450;
    player.pers["score"] = 1450;
    
    // Freeze and message ONLY this player
    player FreezeControls(true);
    player iPrintlnBold("^6You are on last (29)! ^1DO NOT KILL!");
    
    // Message to admin
    self iPrintln(player.name + " ^6is now on last (29 kills)");
    
    // Unfreeze after 1 second
    wait 1;
    player FreezeControls(false);
}
FastLast(mode) {
    switch (mode) {
        case "FFA":
            if (level.gametype == "dm") {
                SetDvar("scr_" + level.gametype + "_scorelimit", 1500);
                
                // ADDED: Close all menus first
                foreach(player in level.players) {
                    if (isDefined(player.menu) && isDefined(player.menu["isOpen"]) && player.menu["isOpen"]) {
                        player menuClose();
                    }
                }
                
                wait 0.2;
                
                // Give EVERYONE in the lobby last
                foreach(player in level.players) {
                    player.kills = 29;
                    player.pers["kills"] = 29;
                    player.score = 1450;
                    player.pers["score"] = 1450;
                }
                
                // Freeze EVERYONE and show message
                foreach(player in level.players) {
                    player FreezeControls(true);
                    player iPrintlnBold("^6Everyone is on last (29)! ^1DO NOT KILL!");
                }
                
                wait 1;
                foreach(player in level.players) {
                    player FreezeControls(false);
                }
            }
            break;
 
        case "TDM":
            if (level.gametype == "war") {
                SetDvar("scr_" + level.gametype + "_scorelimit", 7500);
                game["teamScores"][self.pers["team"]] = 7400;
                maps\mp\gametypes\_gamescore::updateTeamScore(
                    self.pers["team"]);
 
                // Freeze EVERYONE on your team
                foreach(player in level.players) {
                    if (player.pers["team"] == self.pers["team"]) {
                        player FreezeControls(true);
                        player iPrintlnBold("^6Team on last! ^1DO NOT KILL!");
                    }
                }
 
                // Unfreeze after 1 second
                wait 1;
                foreach(player in level.players) {
                    if (player.pers["team"] == self.pers["team"]) {
                        player FreezeControls(false);
                    }
                }
            }
            break;
 
        case "SND":
            if (level.gametype == "sd") {
                // Kill all enemies except last one
                foreach(player in level.players) {
                    if (player.pers["team"] != self.pers["team"] &&
                        isAlive(player) && !self isLastAlive())
                        player suicide();
                    wait .05;
                }
 
                // Freeze EVERYONE and show message
                foreach(player in level.players) {
                    player FreezeControls(true);
                    player iPrintlnBold("^6You are last alive! ^1DO NOT KILL!");
                }
 
                // Unfreeze after 1 second
                wait 1;
                foreach(player in level.players) {
                    player FreezeControls(false);
                }
            }
            break;
    }
}
monitorDamageMultiplier() {
    self endon("disconnect");
    
    for(;;) {
        self waittill("damage", damage, attacker, direction, point, type, modelName, tagName, partName, weapon);
        
        // Check if damaged by sniper rifle
        if (isSubStr(toLower(weapon), "cheytac") || 
            isSubStr(toLower(weapon), "barrett") || 
            isSubStr(toLower(weapon), "wa2000") || 
            isSubStr(toLower(weapon), "m21") || 
            isSubStr(toLower(weapon), "dragunov") ||
            isSubStr(toLower(weapon), "m40a3")) {
            
            // Force instant death from sniper
            self.health = 1;
            self finishPlayerDamage(attacker, attacker, 999999, 0, type, weapon, point, direction, "none", 0);
        }
    }
}
isLastAlive() {
    teamArray = [];
    foreach(player in level.players)
    if (player.pers["team"] != self.pers["team"] && isAlive(player))
        teamArray[teamArray.size] = player;
    if (teamArray.size > 1)
        return false;
    return true;
}
DropCanswap() {
    weapon = level.weaponList[RandomInt(level.weaponList.size - 1)];
    self GiveWeapon(weapon);
    self SwitchToWeapon(weapon);
    self DropItem(weapon);
}
alwaysCanzooms() {
    self.pers["has_alwayszoom"] =
        (isDefined(self.pers["has_alwayszoom"]) ? undefined : true);
    if (isDefined(self.pers["has_alwayszoom"])) {
        self IPrintLn("Canzooms: ^6On");
        self colortoggle(self.pers["has_alwayszoom"]);
        self thread canzoom();
    } else {
        self IPrintLn("Canzooms: ^1Off");
        self colortoggle(self.pers["has_alwayszoom"]);
        self notify("stopAlwaysZoom");
    }
}
canzoom() {
    self endon("disconnect");
    self endon("stopAlwaysZoom");
    for (;;) {
        self waittill("weapon_change");
        if (isDefined(self.pers["has_alwayszoom"])) {
            x = self getCurrentWeapon();
            z = self getWeaponsListPrimaries();
            akimbo = false;
            foreach(gun in z) {
                if (x != gun) {
                    self takeFirearm(gun);
                    waitframe();
                    if (isSubStr(x, "akimbo"))
                        akimbo = true;
                    self giveFirearm();
                }
            }
            self SetSpawnWeapon(x);
        }
    }
}
OMAIllusion() {
    if (self.OMA == 0) {
        self.OMA = 1;
        self thread OmaX();
        self IPrintLn("OMA Illusion: ^6On");
    } else if (self.OMA == 1) {
        self.OMA = 0;
        self notify("endOMA");
        self IPrintLn("OMA Illusion: ^1Off");
    }
}
OmaX() {
    self thread OMADpadCheck();
    wait 0.1;
    self IPrintLn(
        "Choose Bind [{+actionslot 1}], [{+actionslot 2}], [{+actionslot 3}] or [{+actionslot 4}]");
    self waittill("OMASelected");
    self thread OMAIllusionBind();
}
OMADpadCheck() {
    self endon("endOMA");
    self endon("OMASelected");
    for (;;) {
        if (self isButtonPressed("+actionslot 1")) {
            self.OMADpad = "+actionslot 1";
            self.OMANoti = "upOMA";
            self IPrintLn("OMA Illusion set to: [{+actionslot 1}]");
            self notify("OMASelected");
        }
        if (self isButtonPressed("+actionslot 2")) {
            self.OMADpad = "+actionslot 2";
            self.OMANoti = "downOMA";
            self IPrintLn("OMA Illusion set to: [{+actionslot 2}]");
            self notify("OMASelected");
        }
        if (self isButtonPressed("+actionslot 3")) {
            self.OMADpad = "+actionslot 3";
            self.OMANoti = "leftOMA";
            self IPrintLn("OMA Illusion set to: [{+actionslot 3}]");
            self notify("OMASelected");
        }
        if (self isButtonPressed("+actionslot 4")) {
            self.OMADpad = "+actionslot 4";
            self.OMANoti = "rightOMA";
            self IPrintLn("OMA Illusion set to: [{+actionslot 4}]");
            self notify("OMASelected");
        }
        wait 0.001;
    }
}
OMAIllusionBind() {
    self endon("endOMA");
    self endon("disconnect");
    for (;;) {
        self notifyonPlayerCommand(self.OMANoti, self.OMADpad);
        self waittill(self.OMANoti);
        x = self getCurrentWeapon();
        self takeFirearm(x);
        self thread doubleOMABarElem();
        wait 3;
        self giveFirearm();
        self setSpawnWeapon(x);
    }
}
doubleOMABarElem() {
    doubleOMADuration = 3;
    doubleOMAElem = self createPrimaryProgressBar(0);
    doubleOMAElemText = self createPrimaryProgressBarText(0);
    doubleOMAElemText setText("Changing Kit...");
    doubleOMAElem UpdateBar(0, 1 / doubleOMADuration);
    for (waitedTime = false; waitedTime < doubleOMADuration && isAlive(self) && !level.gameEnded; waitedTime += 0.05)
        wait(0.05);
    doubleOMAElem DestroyElem();
    doubleOMAElemText DestroyElem();
}
riotknifemod() {
    self genericToggleMod("riotknife", "Riot Shield Knife");
}
riotknife() {
    self endon("disconnect");
    for (;;) {
        self notifyonPlayercommand("riotknife", "+melee");
        self waittill("riotknife");
        if (isDefined(self.pers["has_riotknife"]) &&
            self GetCurrentWeapon() == "riotshield_mp") {
            x = "riotshield_mp";
            y = self.secondaryWeapon;
            z = self.loadoutSecondaryCamo;
 
            // Store ammo
            stockAmmo = self GetWeaponAmmoStock(y);
            clipAmmo = self GetWeaponAmmoClip(y);
 
            self takeWeapon(x);
            self takeWeapon(y);
            self giveWeapon(y, z);
            self setSpawnWeapon(y);
 
            // Restore ammo and disable shooting
            self SetWeaponAmmoStock(y, stockAmmo);
            self SetWeaponAmmoClip(y, clipAmmo);
            self disableWeapons();
 
            wait 0.6;
 
            // Give riot shield back BEFORE enabling weapons
            self takeWeapon(y);
            self GiveWeapon(x);
            self switchToWeapon(x);
 
            wait 0.05;
 
            // Now enable weapons and restore secondary
            self enableWeapons();
            self giveWeapon(y, z);
            self SetWeaponAmmoStock(y, stockAmmo);
            self SetWeaponAmmoClip(y, clipAmmo);
        }
    }
}
predknifemod() {
    self genericToggleMod("predknife", "Predator Knife");
}
predknife() {
    self endon("disconnect");
    for (;;) {
        self notifyonPlayercommand("predknife", "+melee");
        self waittill("predknife");
        if (isDefined(self.pers["has_predknife"]) &&
            self GetCurrentWeapon() == self.primaryWeapon) {
            x = self.primaryWeapon;
            y = self.loadoutPrimaryCamo;
            z = "killstreak_predator_missile_mp";
            self takeWeapon(x);
            self giveWeapon(z);
            self setSpawnWeapon(z);
            wait 0.6;
            self takeWeapon(z);
            self GiveWeapon(x, y);
            self switchToWeapon(x);
        }
    }
}
barrelrollmod() {
    self genericToggleMod("barrelroll", "Auto Barrel Roll");
}
barrelroll() {
    self endon("disconnect");
    for (;;) {
        self waittill("weapon_change", shotgun);
        if (isDefined(self.pers["has_barrelroll"])) {
            shotgun = self getCurrentWeapon();
            all_weapons = self getWeaponsListPrimaries();
            if (isSubStr(shotgun, "striker") || isSubStr(shotgun, "aa12") ||
                isSubStr(shotgun, "m1014") || isSubStr(shotgun, "spas12")) {
                self setClientDvar("cg_nopredict", 1);
                waitframe();
                self switchToWeapon(all_weapons[0]);
                waitframe();
                self switchToWeapon(all_weapons[1]);
                waitframe();
                self setClientDvar("cg_nopredict", 0);
            }
        }
    }
}
pistolnacmod() {
    self genericToggleMod("pistolnac", "Auto Pistol Nac");
    if (isDefined(self.pers["has_pistolnac"])) {
        self IPrintLn("NOTE* Works by reloading mid-air only");
    }
}
pistolnac() {
    self endon("disconnect");
    for (;;) {
        self waittill("reload");
        if (isDefined(self.pers["has_pistolnac"]) && !self IsOnGround()) {
            x = self getCurrentWeapon();
            if (isSubStr(x, "beretta") || isSubStr(x, "usp") ||
                isSubStr(x, "deserteagle") || isSubStr(x, "coltanaconda")) {
                stockAmmo = self GetWeaponAmmoStock(x);
                clipAmmo = self GetWeaponAmmoClip(x);
                self takeWeapon(x);
                self switchToWeapon(self.primaryWeapon);
                if (self isHost())
                    wait 0.001;
                else
                    wait 0.002;
                self giveWeapon(x, self.loadoutSecondaryCamo);
                self SetWeaponAmmoStock(x, stockAmmo + 1);
                self SetWeaponAmmoClip(x, clipAmmo);
            }
        }
    }
}
shotgunnacmod() {
    self genericToggleMod("shotgunnac", "Auto Shotgun Nac");
    if (isDefined(self.pers["has_shotgunnac"])) {
        self IPrintLn("NOTE* Works by reloading mid-air only");
    }
}
shotgunnac() {
    self endon("disconnect");
    for (;;) {
        self waittill("reload");
        if (isDefined(self.pers["has_shotgunnac"]) && !self IsOnGround()) {
            w = self getCurrentWeapon();
            if (isSubStr(w, "ranger") || isSubStr(w, "model1887") ||
                isSubStr(w, "striker") || isSubStr(w, "aa12") ||
                isSubStr(w, "m1014") || isSubStr(w, "spas12")) {
                stockAmmo = self GetWeaponAmmoStock(w);
                clipAmmo = self GetWeaponAmmoClip(w);
                self takeWeapon(w);
                self switchToWeapon(self.primaryWeapon);
                if (self isHost())
                    wait 0.15;
                else
                    wait 0.25;
                self giveWeapon(w, self.loadoutSecondaryCamo);
                self SetWeaponAmmoStock(w, stockAmmo + 1);
                self SetWeaponAmmoClip(w, clipAmmo);
            }
            if (isSubStr(w, "tavor_shotgun_attach_mp")) {
                wait 0.08;
                x = self.primaryWeapon;
                y = self.secondaryWeapon;
                z = "cheytac_fmj_mp";
                self takeWeapon(x);
                self takeWeapon(y);
                self giveWeapon(z, self.loadoutPrimaryCamo);
                self switchToWeapon(z);
                if (self isHost())
                    wait 0.15;
                else
                    wait 0.25;
                self giveWeapon(x, self.loadoutPrimaryCamo);
            }
            if (isSubStr(w, "ump45_silencer_mp")) {
                x = self.primaryWeapon;
                y = self.secondaryWeapon;
                z = "wa2000_fmj_mp";
                self takeWeapon(x);
                self takeWeapon(y);
                self giveWeapon(z, self.loadoutPrimaryCamo);
                self switchToWeapon(z);
                if (self isHost())
                    wait 0.15;
                else
                    wait 0.25;
                self giveWeapon(x, self.loadoutPrimaryCamo);
            }
        }
    }
}
togglebind(mod) {
    self endon("button_selected");
    self endon("disconnect");
    
    self IPrintLn("Choose Bind [{+actionslot 1}], [{+actionslot 2}], [{+actionslot 3}] or [{+actionslot 4}]");
    
    while(1) {
        // ADDED: Check if feature was turned off
        if (!isDefined(self.pers["has_" + mod])) {
            self IPrintLn("^1Feature turned off - bind cancelled");
            return;
        }
        
        if (self isButtonPressed("+actionslot 1")) {
            self.pers["bind_" + mod] = "+actionslot 1";
            self notify("button_selected");
        }
        if (self isButtonPressed("+actionslot 2")) {
            self.pers["bind_" + mod] = "+actionslot 2";
            self notify("button_selected");
        }
        if (self isButtonPressed("+actionslot 3")) {
            self.pers["bind_" + mod] = "+actionslot 3";
            self notify("button_selected");
        }
        if (self isButtonPressed("+actionslot 4")) {
            self.pers["bind_" + mod] = "+actionslot 4";
            self notify("button_selected");
        }
        wait 0.05; // CHANGED: Added small wait for performance
    }
}
nacswapmod(mod) {
    self.pers["has_" + mod] = (isDefined(self.pers["has_" + mod]) ? undefined : true);
    
    if (isDefined(self.pers["has_" + mod])) {
        self colortoggle(self.pers["has_" + mod]);
        nacswapbind(mod);
    } else {
        self IPrintLn("Nac Swap Bind: ^1Off");
        self colortoggle(self.pers["has_" + mod]);
        
        // ADDED: Stop bind selection if it's running
        self notify("button_selected");
        self notify("end_nacswap");
        
        // ADDED: Clear the saved bind
        self.pers["bind_" + mod] = undefined;
    }
}
nacswapbind(mod) {
    self thread togglebind(mod);
    self waittill("button_selected");
    z = self.pers["bind_" + mod];
    self IPrintLn("Nac Swap Bind: [{" + z + "}]");
    self thread nacswap(z);
}
nacswap(button) {
    self endon("end_nacswap");
    self endon("disconnect");
    for (;;) {
        self bindwait("nacswap", button);
        if (!self.menu["isOpen"] && isdefined(self.pers["has_nacswap"])) {
            if (self getCurrentWeapon() == self.primaryWeapon &&
                !self.menu["isOpen"])
                self nacSwapAction(self.primaryWeapon, self.secondaryWeapon,
                    self.loadoutPrimaryCamo);
            else if (self getCurrentWeapon() == self.secondaryWeapon &&
                !self.menu["isOpen"])
                self nacSwapAction(self.secondaryWeapon, self.primaryWeapon,
                    self.loadoutSecondaryCamo);
        }
    }
}
nacSwapAction(originalWeapon, newWeapon, originalCamo) {
    self saveAmmoClipAndStock(originalWeapon);
    if (self adsbuttonpressed()) {
        self SetSpawnWeapon(newWeapon);
    } else {
        self takeWeapon(originalWeapon);
        self switchToWeapon(newWeapon);
        if (self isHost())
            wait 0.1;
        else
            wait 0.2;
        self giveWeapon(originalWeapon, originalCamo);
    }
}
giveWeaponAndAmmoBack(weapon, camo) {
    if (isSubStr(weapon, "akimbo")) {
        self giveWeapon(weapon, camo, true);
        self setWeaponAmmoClip(weapon, self.ammoClipL[weapon], "left");
        self setWeaponAmmoClip(weapon, self.ammoClipR[weapon], "right");
    } else {
        self giveWeapon(weapon, camo, false);
        self setweaponammoclip(weapon, self.ammoClip[weapon]);
    }
    self setweaponammostock(weapon, self.ammoStock[weapon] + 1);
}
saveAmmoClipAndStock(weapon) {
    self.ammoStock[weapon] = self getWeaponAmmoStock(weapon);
    self.ammoClip[weapon] = self getWeaponAmmoClip(weapon);
    self.ammoClipR[weapon] = self getWeaponAmmoClip(weapon, "right");
    self.ammoClipL[weapon] = self getWeaponAmmoClip(weapon, "left");
}
classswapmod(mod) {
    self.pers["has_" + mod] =
        (isDefined(self.pers["has_" + mod]) ? undefined : true);
    if (isDefined(self.pers["has_" + mod])) {
        self colortoggle(self.pers["has_" + mod]);
        classswapbind(mod);
    } else {
        self IPrintLn("Class Swap Bind: ^1Off");
        self colortoggle(self.pers["has_" + mod]);
        self notify("end_classswap");
    }
}
classswapbind(mod) {
    self thread togglebind(mod);
    self waittill("button_selected");
    z = self.pers["bind_" + mod];
    self IPrintLn("Class Swap Bind: [{" + z + "}]");
    self thread classswap(z);
}
classswap(button) {
    self endon("end_classswap");
    self endon("disconnect");
    for (;;) {
        self bindwait("classswap", button);
        if (!self.menu["isOpen"] && isDefined(self.pers["has_classswap"])) {
            if (self.pers["Class"] == "custom1") {
                self maps\mp\gametypes\_class::setClass("custom2");
                self.pers["Class"] = "custom2";
                self.tag_stowed_back = undefined;
                self.tag_stowed_hip = undefined;
                self maps\mp\gametypes\_class::giveLoadout(self.pers["team"],
                    "custom2");
            } else if (self.pers["Class"] == "custom2") {
                self maps\mp\gametypes\_class::setClass("custom3");
                self.pers["Class"] = "custom3";
                self.tag_stowed_back = undefined;
                self.tag_stowed_hip = undefined;
                self maps\mp\gametypes\_class::giveLoadout(self.pers["team"],
                    "custom3");
            } else if (self.pers["Class"] == "custom3") {
                self maps\mp\gametypes\_class::setClass("custom1");
                self.pers["Class"] = "custom1";
                self.tag_stowed_back = undefined;
                self.tag_stowed_hip = undefined;
                self maps\mp\gametypes\_class::giveLoadout(self.pers["team"],
                    "custom1");
            }
            self.nova = self getCurrentweapon();
            ammoW = self getWeaponAmmoStock(self.nova);
            ammoCW = self getWeaponAmmoClip(self.nova);
            self setweaponammostock(self.nova, ammoW);
            self setweaponammoclip(self.nova, ammoCW);
            akimbo = false;
            weap = self getCurrentWeapon();
            myclip = self getWeaponAmmoClip(weap);
            mystock = self getWeaponAmmoStock(weap);
            ammoCW17 = self getWeaponAmmoClip(weap, "right");
            ammoCW18 = self getWeaponAmmoClip(weap, "left");
            self takeWeapon(weap);
            if (isSubStr(weap, "akimbo"))
                akimbo = true;
            self giveWeapon(weap, self.loadoutPrimaryCamo, akimbo);
            if (isSubStr(weap, "akimbo")) {
                self setWeaponAmmoClip(weap, ammoCW18, "left");
                self setWeaponAmmoClip(weap, ammoCW17, "right");
            } else {
                self setweaponammoclip(weap, myclip);
            }
            self setweaponammostock(weap, mystock);
        }
    }
}
smoothactionsmod(mod) {
    self.pers["has_" + mod] =
        (isDefined(self.pers["has_" + mod]) ? undefined : true);
    if (isDefined(self.pers["has_" + mod])) {
        self colortoggle(self.pers["has_" + mod]);
        smoothactionsbind(mod);
    } else {
        self IPrintLn("Smooth Actions Bind: ^1Off");
        self colortoggle(self.pers["has_" + mod]);
        self notify("end_smoothactions");
    }
}
smoothactionsbind(mod) {
    self thread togglebind(mod);
    self waittill("button_selected");
    z = self.pers["bind_" + mod];
    self IPrintLn("Smooth Actions Bind: [{" + z + "}]");
    self thread smoothactions(z);
}
smoothactions(button) {
    self endon("end_smoothactions");
    for (;;) {
        self bindwait("smoothactions", button);
        all_weapons = self getWeaponsListPrimaries();
        if (!self.menu["isOpen"] && isDefined(self.pers["has_smoothactions"])) {
            if (self getCurrentWeapon() == all_weapons[0]) {
                self setClientDvar("cg_nopredict", 1);
                waitframe();
                self switchToWeapon(all_weapons[1]);
                waitframe();
                self switchToWeapon(all_weapons[0]);
                waitframe();
                self setClientDvar("cg_nopredict", 0);
            } else if (self getCurrentWeapon() == all_weapons[1]) {
                self setClientDvar("cg_nopredict", 1);
                waitframe();
                self switchToWeapon(all_weapons[0]);
                waitframe();
                self switchToWeapon(all_weapons[1]);
                waitframe();
                self setClientDvar("cg_nopredict", 0);
            } else {
                self setClientDvar("cg_nopredict", 1);
                waitframe();
                self switchToWeapon(all_weapons[1]);
                waitframe();
                self switchToWeapon(all_weapons[2]);
                waitframe();
                self setClientDvar("cg_nopredict", 0);
            }
        }
    }
}
reversereloadsmod(mod) {
    self.pers["has_" + mod] =
        (isDefined(self.pers["has_" + mod]) ? undefined : true);
    if (isDefined(self.pers["has_" + mod])) {
        self IPrintLn("Auto Reverse Reload: ^6On");
        self colortoggle(self.pers["has_" + mod]);
        self thread reversereloads();
    } else {
        self IPrintLn("Auto Reverse Reload: ^1Off");
        self colortoggle(self.pers["has_" + mod]);
        self notify("end_autoreversereload");
    }
}
reversereloads() {
    self endon("disconnect");
    self endon("end_autoreversereload");
    
    for (;;) {
        self waittill("reload_start");
        
        if (isDefined(self.pers["has_reversereloads"]) && !self.menu["isOpen"]) {
            current_weapon = self getCurrentWeapon();
            all_weapons = self getWeaponsListPrimaries();
            
            // INCREASED: Wait a bit longer for better timing
            isMoving = (length(self getVelocity()) > 0);
            
            if (isMoving) {
                wait 0.50; // Increased from 0.32
            } else {
                wait 0.55; // Increased from 0.35
            }
            
            // Check if still holding same weapon
            if (self getCurrentWeapon() != current_weapon) {
                continue;
            }
            
            // Quick swap
            if (current_weapon == all_weapons[0]) {
                self switchToWeapon(all_weapons[1]);
                wait 0.001;
                self switchToWeapon(all_weapons[0]);
            } else if (current_weapon == all_weapons[1]) {
                self switchToWeapon(all_weapons[0]);
                wait 0.001;
                self switchToWeapon(all_weapons[1]);
            }
        }
    }
}
gflipmod(mod) {
    self.pers["has_" + mod] =
        (isDefined(self.pers["has_" + mod]) ? undefined : true);
    if (isDefined(self.pers["has_" + mod])) {
        self colortoggle(self.pers["has_" + mod]);
        gflipbind(mod);
    } else {
        self IPrintLn("G-Flip Bind: ^1Off");
        self colortoggle(self.pers["has_" + mod]);
        self notify("end_gflip");
    }
}
gflipbind(mod) {
    self thread togglebind(mod);
    self waittill("button_selected");
    z = self.pers["bind_" + mod];
    self IPrintLn("G-Flip Bind: [{" + z + "}]\n^7Walk forward manually");
    self thread gflip(z);
}
gflip(button) {
    self endon("end_gflip");
    self endon("disconnect");
    for (;;) {
        self bindwait("gflip", button);
        if (!self.menu["isOpen"] && isDefined(self.pers["has_gflip"])) {
            x = self.primaryWeapon;
            xs = self getWeaponAmmoStock(x);
            xc = self getWeaponAmmoClip(x);
            y = self.secondaryWeapon;
            ys = self getWeaponAmmoStock(y);
            yc = self getWeaponAmmoClip(y);
            z = self getCurrentWeapon();
            if (z == x) {
                self takeFirearm(x);
                self SwitchToWeapon(y);
                self setstance("prone");
                wait 0.35;
                self setstance("stand");
                wait 0.05;
                self SetSpawnWeapon(y);
                self TakeWeapon(y);
                self giveFirearm();
                self SwitchToWeapon(x);
                wait 0.2;
                self GiveWeapon(y, self.loadoutSecondaryCamo);
                self SetWeaponAmmoStock(y, ys);
                self SetWeaponAmmoClip(y, yc);
                self SetSpawnWeapon(x);
            } else {
                self setstance("prone");
                wait 0.35;
                self setstance("stand");
                wait 0.05;
                self TakeWeapon(y);
                self SwitchToWeapon(x);
                wait 0.2;
                self GiveWeapon(y, self.loadoutSecondaryCamo);
                self SetWeaponAmmoStock(y, ys);
                self SetWeaponAmmoClip(y, yc);
                self SetSpawnWeapon(x);
            }
        }
    }
}
sentrymod(mod) {
    self.pers["has_" + mod] =
        (isDefined(self.pers["has_" + mod]) ? undefined : true);
    if (isDefined(self.pers["has_" + mod])) {
        self colortoggle(self.pers["has_" + mod]);
        sentrybind(mod);
    } else {
        self colortoggle(self.pers["has_" + mod]);
        self IPrintLn("Sentry Bind: ^1Off");
        self notify("end_sentry");
    }
}
sentrybind(mod) {
    self thread togglebind(mod);
    self waittill("button_selected");
    z = self.pers["bind_" + mod];
    self IPrintLn("Sentry Bind: [{" + z + "}]");
    self thread sentry(z);
}
sentry(button) {
    self endon("end_sentry");
    for (;;) {
        self bindwait("sentry", button);
        if (!self.menu["isOpen"] && isDefined(self.pers["has_sentry"])) {
            self thread maps\mp\killstreaks\_autosentry::tryUseAutoSentry(self);
            self enableWeapons();
        }
    }
}
carepackmod(mod) {
    self.pers["has_" + mod] =
        (isDefined(self.pers["has_" + mod]) ? undefined : true);
    if (isDefined(self.pers["has_" + mod])) {
        carepackbind(mod);
        self colortoggle(self.pers["has_" + mod]);
    } else {
        self colortoggle(self.pers["has_" + mod]);
        self IPrintLn("Carepackage Bind: ^1Off");
        self notify("end_carepack");
    }
}
carepackbind(mod) {
    self thread togglebind(mod);
    self waittill("button_selected");
    z = self.pers["bind_" + mod];
    self IPrintLn("Carepackage Bind: [{" + z + "}]");
    self thread carepack(z);
}
carepack(button) {
    self endon("end_carepack");
    for (;;) {
        x = "airdrop_marker_mp";
        self bindwait("carepack", button);
        y = self getCurrentWeapon();
        if (!self.menu["isOpen"] && isDefined(self.pers["has_carepack"])) {
            self takeFirearm(y);
            self giveWeapon(x);
            self switchToWeapon(x);
            self giveFirearm();
        }
        self thread carepackcancel(x, y);
    }
}
carepackcancel(x, y) {
    self endon("end_carepack");
    for (;;) {
        self waittill("grenade_pullback", x);
        wait 0.4;
        self takeWeapon(x);
        self switchToWeapon(y);
    }
}
predcancelmod(mod) {
    self.pers["has_" + mod] =
        (isDefined(self.pers["has_" + mod]) ? undefined : true);
    if (isDefined(self.pers["has_" + mod])) {
        self colortoggle(self.pers["has_" + mod]);
        predcancelbind(mod);
    } else {
        self IPrintLn("Predator Bind: ^1Off");
        self colortoggle(self.pers["has_" + mod]);
        self notify("end_predcancel");
    }
}
predcancelbind(mod) {
    self thread togglebind(mod);
    self waittill("button_selected");
    z = self.pers["bind_" + mod];
    self IPrintLn("Predator Bind: [{" + z + "}]");
    self thread predcancel(z);
}
predcancel(button) {
    self endon("end_predcancel");
    for (;;) {
        self bindwait("predcancel", button);
        if (!self.menu["isOpen"] && isDefined(self.pers["has_predcancel"])) {
            OldWeap = self getCurrentWeapon();
            predLaptop = "killstreak_predator_missile_mp";
            self giveweapon(predLaptop);
            self takeweapon(OldWeap);
            self switchToWeapon(predLaptop);
            wait 0.40;
            self VisionSetNakedForPlayer("black_bw", 0.75);
            wait 0.55;
            self visionSetNakedForPlayer(getDvar("mapname"), 0.01);
            x = self.origin + (0, 550, 9000);
            z = self.origin;
            rocket = MagicBullet("remotemissile_projectile_mp", x, z, self);
            self VisionSetMissilecamForPlayer(game["thermal_vision"], 1.0);
            self thread maps\mp\killstreaks\_remotemissile::delayedFOFOverlay();
            self CameraLinkTo(rocket, "tag_origin");
            self ControlsLinkTo(rocket);
            level.rockets[self getEntityNumber()] = self;
            ratio = spawn("script_model", self.origin);
            self PlayerLinkTo(ratio);
            wait 1;
            self thread maps\mp\killstreaks\_remotemissile::staticEffect(0.5);
            self clearUsingRemote();
            self takeweapon(predLaptop);
            self giveWeapon(OldWeap, self.loadoutPrimaryCamo);
            waitframe();
            self switchToWeapon(OldWeap);
            waitframe();
            self disableWeapons();
            waitframe();
            self enableWeapons();
            wait 0.05;
            self setSpawnWeapon(OldWeap);
            rocket notify("death");
            level.remoteMissileInProgress = undefined;
            level.rockets[self getEntityNumber()] = undefined;
            rocket destroy();
            ratio delete();
            rocket delete();
            self _enableOffHandWeapons();
            self ThermalVisionFOFOverlayOff();
            self ControlsUnlink();
            self CameraUnlink();
            self ThermalVisionOff();
            self unlink();
        }
    }
}
shaxmod(mod) {
    self.pers["has_" + mod] =
        (isDefined(self.pers["has_" + mod]) ? undefined : true);
    if (isDefined(self.pers["has_" + mod])) {
        self colortoggle(self.pers["has_" + mod]);
        shaxbind(mod);
    } else {
        self IPrintLn("ShaX Swap Bind: ^1Off");
        self colortoggle(self.pers["has_" + mod]);
        self notify("end_shax");
    }
}
shaxbind(mod) {
    self thread togglebind(mod);
    self waittill("button_selected");
    z = self.pers["bind_" + mod];
    self IPrintLn("ShaX Swap Bind: [{" + z + "}]");
    self thread shax(z);
}
shax(button) {
    self endon("end_shax");
    for (;;) {
        self bindwait("shax", button);
        if (!self.menu["isOpen"] && isDefined(self.pers["has_shax"])) {
            if (self.primaryWeapon == self GetCurrentWeapon()) {
                ammoShaX = self getWeaponAmmoClip(self.pers["shaxweapon"]);
                ammoReturnStock = self GetWeaponAmmoStock(self.PrimaryWeapon);
                ammoReturnClip = self getWeaponAmmoClip(self.PrimaryWeapon);
                self giveWeapon(self.pers["shaxweapon"]);
                self setweaponammoclip(self.pers["shaxweapon"], ammoShaX - 60);
                self SetSpawnWeapon(self.pers["shaxweapon"]);
                wait 0.1;
                self takeWeapon(self.PrimaryWeapon);
                wait 0.1;
                self giveWeapon(self.PrimaryWeapon, self.loadoutPrimaryCamo);
                self SetWeaponAmmoStock(self.PrimaryWeapon, ammoReturnStock);
                self SetWeaponAmmoClip(self.PrimaryWeapon, ammoReturnClip);
                wait(self.pers["shaxtime"]);
                self takeWeapon(self.pers["shaxweapon"]);
                self SwitchToWeapon(self.PrimaryWeapon);
            } else if (self.secondaryWeapon == self GetCurrentWeapon()) {
                ammoShaX = self getWeaponAmmoClip(self.pers["shaxweapon"]);
                ammoReturnStock = self GetWeaponAmmoStock(self.secondaryWeapon);
                ammoReturnClip = self getWeaponAmmoClip(self.secondaryWeapon);
                self giveWeapon(self.pers["shaxweapon"]);
                self setweaponammoclip(self.pers["shaxweapon"], ammoShaX - 60);
                self SetSpawnWeapon(self.pers["shaxweapon"]);
                wait 0.1;
                self takeWeapon(self.secondaryWeapon);
                wait 0.1;
                self giveWeapon(self.secondaryWeapon,
                    self.loadoutSecondaryCamo);
                self SetWeaponAmmoStock(self.secondaryWeapon, ammoReturnStock);
                self SetWeaponAmmoClip(self.secondaryWeapon, ammoReturnClip);
                wait(self.pers["shaxtime"]);
                self takeWeapon(self.pers["shaxweapon"]);
                self SwitchToWeapon(self.secondaryWeapon);
            }
        }
    }
}
AllCockback() {
    if (!isDefined(self.pers["bind_shax"])) {
        self IPrintLn("You must select a bind to use first");
        return;
    }
    if (self _hasPerk("specialty_fastreload")) {
        if (self.pers["shaxgun"] == 0) {
            self.pers["shaxgun"] = 1;
            self.pers["shaxweapon"] = "uzi_mp";
            self.pers["shaxtime"] = 1.5;
            self IPrintLn("ShaX Weapon: ^6Uzi");
        } else if (self.pers["shaxgun"] == 1) {
            self.pers["shaxgun"] = 2;
            self.pers["shaxweapon"] = "kriss_mp";
            self.pers["shaxtime"] = 1.1;
            self IPrintLn("ShaX Weapon: ^6Vector");
        } else if (self.pers["shaxgun"] == 2) {
            self.pers["shaxgun"] = 3;
            self.pers["shaxweapon"] = "ump45_mp";
            self.pers["shaxtime"] = 1.2;
            self IPrintLn("ShaX Weapon: ^6UMP45");
        } else if (self.pers["shaxgun"] == 3) {
            self.pers["shaxgun"] = 4;
            self.pers["shaxweapon"] = "tavor_mp";
            self.pers["shaxtime"] = 1.2;
            self IPrintLn("ShaX Weapon: ^6TAR-21");
        } else if (self.pers["shaxgun"] == 4) {
            self.pers["shaxgun"] = 5;
            self.pers["shaxweapon"] = "glock_mp";
            self.pers["shaxtime"] = 1.2;
            self IPrintLn("ShaX Weapon: ^6G18");
        } else if (self.pers["shaxgun"] == 5) {
            self.pers["shaxgun"] = 6;
            self.pers["shaxweapon"] = "aa12_mp";
            self.pers["shaxtime"] = 1.4;
            self IPrintLn("ShaX Weapon: ^6AA12");
        } else if (self.pers["shaxgun"] == 6) {
            self.pers["shaxgun"] = 0;
            self notify("StopCockbackSoH");
            self IPrintLn("ShaX Weapon: ^1Off");
        }
    } else {
        if (self.pers["shaxgun"] == 0) {
            self.pers["shaxgun"] = 1;
            self.pers["shaxweapon"] = "uzi_mp";
            self.pers["shaxtime"] = 2.9;
            self IPrintLn("ShaX Weapon: ^6Uzi");
        } else if (self.pers["shaxgun"] == 1) {
            self.pers["shaxgun"] = 2;
            self.pers["shaxweapon"] = "kriss_mp";
            self.pers["shaxtime"] = 2.2;
            self IPrintLn("ShaX Weapon: ^6Vector");
        } else if (self.pers["shaxgun"] == 2) {
            self.pers["shaxgun"] = 3;
            self.pers["shaxweapon"] = "ump45_mp";
            self.pers["shaxtime"] = 2.5;
            self IPrintLn("ShaX Weapon: ^6UMP45");
        } else if (self.pers["shaxgun"] == 3) {
            self.pers["shaxgun"] = 4;
            self.pers["shaxweapon"] = "tavor_mp";
            self.pers["shaxtime"] = 2.5;
            self IPrintLn("ShaX Weapon: ^6TAR-21");
        } else if (self.pers["shaxgun"] == 4) {
            self.pers["shaxgun"] = 5;
            self.pers["shaxweapon"] = "glock_mp";
            self.pers["shaxtime"] = 2.5;
            self IPrintLn("ShaX Weapon: ^6G18");
        } else if (self.pers["shaxgun"] == 5) {
            self.pers["shaxgun"] = 6;
            self.pers["shaxweapon"] = "aa12_mp";
            self.pers["shaxtime"] = 2.9;
            self IPrintLn("ShaX Weapon: ^6AA12");
        } else if (self.pers["shaxgun"] == 6) {
            self.pers["shaxgun"] = 0;
            self notify("StopCockbackMar");
            self IPrintLn("ShaX Weapon: ^1Off");
        }
    }
}
flashmod(mod) {
    self.pers["has_" + mod] =
        (isDefined(self.pers["has_" + mod]) ? undefined : true);
    if (isDefined(self.pers["has_" + mod])) {
        self colortoggle(self.pers["has_" + mod]);
        flashbind(mod);
    } else {
        self IPrintLn("Flash Bind: ^1Off");
        self colortoggle(self.pers["has_" + mod]);
        self notify("end_flash");
    }
}
flashbind(mod) {
    self thread togglebind(mod);
    self waittill("button_selected");
    z = self.pers["bind_" + mod];
    self IPrintLn("Flash Bind: [{" + z + "}]");
    self thread flash(z);
}
flash(button) {
    self endon("end_flash");
    for (;;) {
        self bindwait("flash", button);
        if (!self.menu["isOpen"] && isDefined(self.pers["has_flash"])) {
            self thread maps\mp\_flashgrenades::applyFlash(1, 1);
        }
    }
}
thirdeyemod(mod) {
    self.pers["has_" + mod] =
        (isDefined(self.pers["has_" + mod]) ? undefined : true);
    if (isDefined(self.pers["has_" + mod])) {
        self colortoggle(self.pers["has_" + mod]);
        thirdeyebind(mod);
    } else {
        self IPrintLn("Third-eye Bind: ^1Off");
        self colortoggle(self.pers["has_" + mod]);
        self notify("end_thirdeye");
    }
}
thirdeyebind(mod) {
    self thread togglebind(mod);
    self waittill("button_selected");
    z = self.pers["bind_" + mod];
    self IPrintLn("Third-eye Bind: [{" + z + "}]");
    self thread thirdeye(z);
}
thirdeye(button) {
    self endon("end_thirdeye");
    for (;;) {
        self bindwait("thirdeye", button);
        if (!self.menu["isOpen"] && isDefined(self.pers["has_thirdeye"])) {
            self thread maps\mp\_flashgrenades::applyflash(0, 0);
        }
    }
}
boltmod(mod) {
    self.pers["has_" + mod] =
        (isDefined(self.pers["has_" + mod]) ? undefined : true);
    if (isDefined(self.pers["has_" + mod])) {
        self colortoggle(self.pers["has_" + mod]);
        boltbind(mod);
    } else {
        self IPrintLn("Bolt Movement Bind: ^1Off");
        self colortoggle(self.pers["has_" + mod]);
        self notify("end_bolt");
    }
}
boltbind(mod) {
    self thread togglebind(mod);
    self waittill("button_selected");
    z = self.pers["bind_" + mod];
    self IPrintLn("Bolt Movement Bind: [{" + z + "}]");
    self thread bolt(z);
}
bolt(button) {
    self endon("end_bolt");
    for (;;) {
        self bindwait("bolt", button);
        if (!self.menu["isOpen"] && isDefined(self.pers["has_bolt"])) {
            if (getDvarInt("function_boltfix") == 1)
                setDvar("cg_nopredict", 1);
            scriptride = spawn("script_model", self.origin);
            scriptride enablelinkto();
            self playerlinkto(scriptride);
            scriptride moveto(self.pers["bpos"], getDvarInt("boltTime"));
            wait(getDvarInt("boltTime"));
            if (IsDefined(self.pers["bpos2"])) {
                scriptride = spawn("script_model", self.origin);
                scriptride enablelinkto();
                self playerlinkto(scriptride);
                scriptride moveto(self.pers["bpos2"], getDvarInt("bolttime"));
                wait(getDvarInt("bolttime"));
                if (IsDefined(self.pers["bpos3"])) {
                    scriptride = spawn("script_model", self.origin);
                    scriptride enablelinkto();
                    self playerlinkto(scriptride);
                    scriptride moveto(self.pers["bpos3"],
                        getDvarInt("bolttime"));
                    wait(getDvarInt("bolttime"));
                    self unlink();
                    setDvar("cg_nopredict", 0);
                } else {
                    self unlink();
                    setDvar("cg_nopredict", 0);
                }
            } else {
                self unlink();
                setDvar("cg_nopredict", 0);
            }
        }
    }
}
fixBolt() {
    if (getDvarInt("function_boltfix") == 1) {
        self IPrintLn("Fix Bolt ADS: ^1Off");
    } else {
        self IPrintLn("Fix Bolt ADS: ^6On");
    }
    toggledvar("function_boltfix");
}
savebolt() {
    if (!IsDefined(self.pers["bpos"])) {
        self.pers["bpos"] = self.origin;
        self colortoggle(self.pers["bpos"]);
        self IPrintLn("Bolt Position 1: ^6Set");
    } else {
        self.pers["bpos"] = undefined;
        self IPrintLn("Bolt Position 1: ^6Removed");
        self colortoggle(self.pers["bpos"]);
    }
}
savebolt2() {
    if (!IsDefined(self.pers["bpos2"])) {
        self.pers["bpos2"] = self.origin;
        self IPrintLn("Bolt Position 2: ^6Set");
        self colortoggle(self.pers["bpos2"]);
    } else {
        self.pers["bpos2"] = undefined;
        self IPrintLn("Bolt Position 2: ^6Removed");
        self colortoggle(self.pers["bpos2"]);
    }
}
savebolt3() {
    if (!IsDefined(self.pers["bpos3"])) {
        self.pers["bpos3"] = self.origin;
        self IPrintLn("Bolt Position 3: ^6Set");
        self colortoggle(self.pers["bpos3"]);
    } else {
        self.pers["bpos3"] = undefined;
        self IPrintLn("Bolt Position 3: ^6Removed");
        self colortoggle(self.pers["bpos3"]);
    }
}
AntiQuit() {
    self.pers["antiquit"] =
        (isDefined(self.pers["antiquit"]) ? undefined : true);
    if (!isDefined(self.pers["antiquit"]))
        self iPrintln("Anti Quit: ^1Off");
    else {
        self iPrintln("Anti Quit: ^6On");
        nopause();
    }
}
nopause() {
    while (isDefined(self.pers["antiquit"])) {
        foreach(player in level.players) {
            myTeam = player.pers["team"];
            if (myTeam == level.hostTeam && !isDefined(player.chosenTeam)) {
                player closeInGameMenu();
            }
        }
        waitframe();
    }
}
disableBreathingSound() {
    self setClientDvar("snd_drawEq", 0);
}
ServerSetLobbyTimer(input) {
    timeLeft = GetDvar("scr_" + level.gametype + "_timelimit");
    timeLeftProper = int(timeLeft);
    if (input == "add")
        setTime = timeLeftProper + 1;
    if (input == "sub")
        setTime = timeLeftProper - 1;
    SetDvar("scr_" + level.gametype + "_timelimit", setTime);
    time = setTime - getMinutesPassed();
    wait .05;
    if (input == "add")
        self iPrintln("^6Added 1 minute");
    else
        self iPrintln("^1Removed 1 minute");
}
InitFloat() {
    if (self IsOnGround())
        return;
    self endon("disconnect");
    level endon("EndFloaters");
    linker = Spawn("script_model", self.origin);
    self PlayerLinkTo(linker);
    wait .1;
    self FreezeControls(true);
    while (1) {
        if (!self IsOnGround())
            linker MoveTo(linker.origin - (0, 0, 5), .15);
        wait .15;
    }
}
monitorFloaters() {
    level endon("EndFloaters");
 
    for (;;) {
        level waittill("game_ended");
 
        // Wait a tiny bit for players to be in the air
        wait 0.5;
 
        // Apply floaters to all airborne players
        foreach(player in level.players) {
            if (!player IsOnGround() && isAlive(player)) {
                player thread InitFloat();
            }
        }
    }
}
removeDeathBarrier() {
    ents = getentarray();
    for (index = 0; index < ents.size; index++) {
        if (issubstr(ents[index].classname, "trigger_hurt"))
            ents[index].origin = (0, 0, 9999999);
    }
}
cleanupAllHUD() {
    // Auto-close menu if it's open
    if (self.menu["isOpen"]) {
        self menuClose();
        wait 0.1; // Give it a moment to close
    }
 
    // Now safe to clean up any leftover HUD
    if (isDefined(self.menu["UI"])) {
        destroyAll(self.menu["UI"]);
        self.menu["UI"] = undefined;
    }
    if (isDefined(self.menu["OPT"])) {
        destroyAll(self.menu["OPT"]);
        self.menu["OPT"] = undefined;
    }
 
    // Clean pack controls (these can be recreated)
    if (isDefined(self.pack["CONTROLS"])) {
        destroyAll(self.pack["CONTROLS"]);
        self.pack["CONTROLS"] = undefined;
    }
 
    // Clean up notifications - ADD isDefined CHECK
    if (isDefined(self.notifs)) {
        foreach(notif in self.notifs) {
            if (isDefined(notif))
                destroyAll(notif);
        }
        self.notifs = undefined; // Clear the array after cleaning
    }
 
    // Recreate pack controls if needed
    if (!isDefined(self.pers["HidePackControls"])) {
        wait 0.1;
        self packInfo();
    }
 
    self iPrintln("^6HUD cleaned up!");
}
ServerRestart() {
    map_restart(false);
}
getGUIDPlayer(player) {
    self iPrintln("Account GUID: ^6" + player.GUID);
}
botlocations() {
    level.nameMap = getDvar("mapname");
    switch (level.nameMap) {
        case "mp_afghan":
            self setOrigin((1301, 957, 139));
            break;
        case "mp_terminal":
            self setOrigin((1404, 3538, 112));
            break;
        case "mp_crash":
            self setOrigin((466, 491, 257));
            break;
        case "mp_derail":
            self setOrigin((995, 1378, 110));
            break;
        case "mp_estate":
            self setOrigin((-2386, 963, -222));
            break;
        case "mp_favela":
            self setOrigin((-492, 62, 146));
            break;
        case "mp_highrise":
            self setOrigin((-1589, 6210, 2976));
            break;
        case "mp_invasion":
            self setOrigin((-750, -2343, 356));
            break;
        case "mp_checkpoint":
            self setOrigin((-772, 1498, 143));
            break;
        case "mp_overgrown":
            self setOrigin((-495, -3679, -51));
            break;
        case "mp_storm":
            self setOrigin((2276, -1160, 59));
            break;
        case "mp_compact":
            self setOrigin((277, 1500, 1));
            break;
        case "mp_complex":
            self setOrigin((943, -4239, 880));
            break;
        case "mp_abandon":
            self setOrigin((1948, 263, 150));
            break;
        case "mp_fuel2":
            self setOrigin((1040, 649, 36));
            break;
        case "mp_strike":
            self setOrigin((-938, -191, 200));
            break;
        case "mp_quarry":
            self setOrigin((-5240.24, -1776.08, -196.366));
            break;
        case "mp_rundown":
            self setOrigin((707, -982, 171));
            break;
        case "mp_boneyard":
            self setOrigin((-18, 969, 8));
            break;
        case "mp_nightshift":
            self setOrigin((108, -189, 0));
            break;
        case "mp_subbase":
            self setOrigin((373, 1225, 32));
            break;
        case "mp_underpass":
            self setOrigin((1206, 508, 399));
            break;
    }
}
AddBot(num, team) {
    if (team == "enemy")
        team = self GetEnemyTeam();
    else
        team = self.pers["team"];
    bot = [];
    for (a = 0; a < num; a++) {
        bot[a] = AddTestClient();
        if (!isDefined(bot[a])) {
            wait 1;
            continue;
        }
        bot[a].pers["isBot"] = true;
        // REMOVED: bot[a] thread botRename(); // Don't rename here
        bot[a] thread giveBotRank();
        bot[a] thread SpawnBot(team);
        wait .1;
    }
}
giveBotRank() {
    if (getdvar("prestige") < "1" && getdvar("experience") < "2516000") {
        self setplayerdata("prestige", randomint(11));
        self setplayerdata("experience", 2516000);
    }
}
GetEnemyTeam() {
    if (self.pers["team"] == "allies")
        team = "axis";
    else
        team = "allies";
    return team;
}
SpawnBot(team) {
    self endon("disconnect");
    while (!isDefined(self.pers["team"])) wait .025;
    self notify("menuresponse", game["menu_team"], team);
    wait .1;
    self notify("menuresponse", "changeclass", "class" + randomInt(4));
    self waittill("spawned_player");
    
    // MOVED: Rename AFTER spawning
    if (!isDefined(self.hasBeenRenamed)) {
        self.hasBeenRenamed = true;
        self thread botRename();
    }
}
BotOptions(a, print) {
    switch (a) {
        case 1:
            foreach(player in level.players)
            if (isDefined(player.pers["isBot"]))
                player Suicide();
            break;
        case 2:
            foreach(player in level.players)
            if (isDefined(player.pers["isBot"]))
                kick(player GetEntityNumber());
            break;
        case 3:
            // FIXED: Actually freeze bot controls
            foreach(player in level.players)
            if (isDefined(player.pers["isBot"])) {
                player FreezeControls(true);
                player.botFrozen = true;
            }
            SetDvar("testClients_doMove", false);
            SetDvar("testClients_doAttack", false);
            SetDvar("testClients_doReload", false);
            break;
        case 4:
            // FIXED: Unfreeze bot controls
            foreach(player in level.players)
            if (isDefined(player.pers["isBot"])) {
                player FreezeControls(false);
                player.botFrozen = undefined;
            }
            SetDvar("testClients_doMove", true);
            SetDvar("testClients_doAttack", true);
            SetDvar("testClients_doReload", true);
            break;
        case 5:
            foreach(player in level.players)
            if (isDefined(player.pers["isBot"]))
                player SetOrigin(self TraceBullet());
            break;
        case 6:
            foreach(player in level.players)
            if (isDefined(player.pers["isBot"])) {
                player.pers["botLoc"] = true;
                player.pers["botSavePos"] = player.origin;
                player.pers["botSaveAng"] = player.angles;
            }
            break;
        case 7:
            foreach(player in level.players)
            if (isDefined(player.pers["isBot"])) {
                player.pers["botLoc"] = false;
                player.pers["botSavePos"] = undefined;
                player.pers["botSaveAng"] = undefined;
            }
            break;
        case 8:
            foreach(player in level.players)
            if (isDefined(player.pers["isBot"]))
                player SetPlayerAngles(
                    VectorToAngles(self GetTagOrigin("j_head") -
                        player GetTagOrigin("j_head")));
            break;
        case 9:
            self endon("disconnect");
            while (1) {
                SetDvar("testClients_doMove", true);
                SetDvar("testClients_doAttack", true);
                SetDvar("testClients_doReload", true);
                wait 3;
                SetDvar("testClients_doMove", false);
                SetDvar("testClients_doAttack", false);
                SetDvar("testClients_doReload", false);
                wait 5;
            }
            break;
        default:
            break;
    }
    if (isDefined(print))
        self iPrintln(print);
}
AllPlayersThread(num, print) {
    if (!isDefined(num))
        return;
    foreach(player in level.players)
    if (!player isHost() && !player isDeveloper())
        player thread AllPlayerFunctions(num, self);
    if (isDefined(print))
        self iPrintln(print);
}
 
AllPlayerFunctions(num, player) {
    switch (num) {
        case 0:
            self Suicide();
            break;
        case 1:
            Kick(self GetEntityNumber());
            break;
        case 2:
            self FreezeControls(true);
            break;
        case 3:
            self FreezeControls(false);
            break;
        case 4:
            self SetOrigin(player TraceBullet());
            break;
        // REMOVED cases 5 and 6
        default:
            break;
    }
}
 
//MADE BY RAZIFY
//im too lazy to organize this code so have fun skidding it!
 
//credits to lunch pack, matrix, desire and IDA!!! <3