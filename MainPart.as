rect mapInitialPlayableArea;

#include "OnSpawnAction.as"
#include "Cheats.as"

array<int> MapVersion(100);
bool TestDebugMode = true;
force PlayerForces;
force EnemiesForce;
int ALLIANCE_ALLIED = 2;

int CAMERA_MARGIN_LEFT   = 0;
int CAMERA_MARGIN_RIGHT  = 1;
int CAMERA_MARGIN_TOP    = 2;
int CAMERA_MARGIN_BOTTOM = 3;



void SetPlayerAllianceStateAlly(player sourcePlayer, player otherPlayer, bool flag){
    Jass::SetPlayerAlliance(sourcePlayer, otherPlayer, Jass::ALLIANCE_PASSIVE,       flag);
    Jass::SetPlayerAlliance(sourcePlayer, otherPlayer, Jass::ALLIANCE_HELP_REQUEST,  flag);
    Jass::SetPlayerAlliance(sourcePlayer, otherPlayer, Jass::ALLIANCE_HELP_RESPONSE, flag);
    Jass::SetPlayerAlliance(sourcePlayer, otherPlayer, Jass::ALLIANCE_SHARED_XP,     flag);
    Jass::SetPlayerAlliance(sourcePlayer, otherPlayer, Jass::ALLIANCE_SHARED_SPELLS, flag);
}

void SetPlayerAllianceState(player sourcePlayer, player otherPlayer, int allianceState ){
    if (sourcePlayer == otherPlayer) 
        return;

    if (allianceState == ALLIANCE_ALLIED){
        SetPlayerAllianceStateAlly(        sourcePlayer, otherPlayer, true  );
        Jass::SetPlayerAlliance(sourcePlayer, otherPlayer, Jass::ALLIANCE_SHARED_VISION, false);
        Jass::SetPlayerAlliance(sourcePlayer, otherPlayer, Jass::ALLIANCE_SHARED_CONTROL, false);
        Jass::SetPlayerAlliance(sourcePlayer, otherPlayer, Jass::ALLIANCE_SHARED_ADVANCED_CONTROL, false);
    }
}

void GameStart() {
    Jass::DestroyTimer(Jass::GetExpiredTimer());
    fogmodifier fogm;
    MapVersion[0] = 300;
    MapVersion[1] = 310;
    mapInitialPlayableArea = Jass::Rect(Jass::GetCameraBoundMinX()-Jass::GetCameraMargin(CAMERA_MARGIN_LEFT), Jass::GetCameraBoundMinY()-Jass::GetCameraMargin(CAMERA_MARGIN_BOTTOM), Jass::GetCameraBoundMaxX()+Jass::GetCameraMargin(CAMERA_MARGIN_RIGHT), Jass::GetCameraBoundMaxY()+Jass::GetCameraMargin(CAMERA_MARGIN_TOP));
    if(TestDebugMode) Jass::ConsoleEnable(true);
    PlayerForces = Jass::CreateForce();
    EnemiesForce = Jass::CreateForce();
    for(uint i = 0; i <= 9; i++){
        if ((Jass::GetPlayerController(Jass::Player(i)) == Jass::MAP_CONTROL_USER and Jass::GetPlayerSlotState(Jass::Player(i)) == Jass::PLAYER_SLOT_STATE_PLAYING)) {
            Jass::ForceAddPlayer(PlayerForces, Jass::Player(i));
        }
    }
    Jass::ForceAddPlayer(EnemiesForce, Jass::Player(10));
    Jass::ForceAddPlayer(EnemiesForce, Jass::Player(11));
    Jass::ForceAddPlayer(EnemiesForce, Jass::Player(13));
    Jass::SetBuffBaseRealArrayFieldById('BHad', Jass::ABILITY_RLF_ARMOR_BONUS_HAD1, 0, 0);
    Jass::SetBuffBaseRealArrayFieldById('BUim', Jass::ABILITY_RLF_DAMAGE_DEALT_UIM3, 0, 0.);
    Jass::SetBuffBaseRealArrayFieldById('BNht', Jass::ABILITY_RLF_DATA_FIELD_A, 0, 0.);
    Jass::SetMapFlag(Jass::MAP_LOCK_RESOURCE_TRADING, true);
    fogm = Jass::CreateFogModifierRect(Jass::Player(10), Jass::FOG_OF_WAR_VISIBLE, mapInitialPlayableArea, true, false);
    Jass::FogModifierStart(fogm);
    fogm = Jass::CreateFogModifierRect(Jass::Player(11), Jass::FOG_OF_WAR_VISIBLE, mapInitialPlayableArea, true, false);
    Jass::FogModifierStart(fogm);
    Jass::ForForce(PlayerForces, function() {
        fogmodifier fogm;
        fogm = Jass::CreateFogModifierRect(Jass::GetEnumPlayer(), Jass::FOG_OF_WAR_VISIBLE, Jass::GetWorldBounds(), false, false);
        Jass::FogModifierStart(fogm);
        Jass::FogModifierStop(fogm);
        fogm = nil;
    });
    fogm = nil;
    Jass::SetCreepCampFilterState(false);
    Jass::EnableMinimapFilterButtons(true, false);

    SetPlayerAllianceState( Jass::Player(10), Jass::Player(13), ALLIANCE_ALLIED );
    SetPlayerAllianceState( Jass::Player(11), Jass::Player(13), ALLIANCE_ALLIED );
    SetPlayerAllianceState( Jass::Player(13), Jass::Player(10), ALLIANCE_ALLIED );
    SetPlayerAllianceState( Jass::Player(13), Jass::Player(11), ALLIANCE_ALLIED );
    
    Jass::SetTimeOfDayScale( 0.00 );
    Jass::SetFloatGameState(Jass::GAME_STATE_TIME_OF_DAY, 0.00);

    Jass::SuspendTimeOfDay(true);
    Jass::CameraSetSmoothingFactor(1.);
    InitBaseStats();
    InitItemTemplates();
    InitItemTriggers();
    InitSpawnTrigger();
    InitDamageSystem();
    if(TestDebugMode) InitCheats();
    Jass::CreateItem('I02I', 0.f, 0.f);
    Jass::ConsolePrint("GameStartCompleted");
}

void MainPart() {
    Jass::TimerStart(Jass::CreateTimer(), 0.02, false, @GameStart ) ;
}