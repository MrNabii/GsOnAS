
//import ..\\Heroes\\HeroHelpers.as
//import ..\\Heroes\\HeroPiro.as
//import ..\\Heroes\\HeroStalker.as
//import ..\\Heroes\\HeroSniper.as
//import ..\\Heroes\\HeroRoket.as
//import ..\\Heroes\\HeroPodr.as
//import ..\\Heroes\\HeroMedic.as
//import ..\\Heroes\\HeroPulik.as
//import ..\\Heroes\\HeroEngineer.as

#include "..\\Heroes\\HeroHelpers.as"
#include "..\\Heroes\\HeroPiro.as"
#include "..\\Heroes\\HeroStalker.as"
#include "..\\Heroes\\HeroSniper.as"
#include "..\\Heroes\\HeroRoket.as"
#include "..\\Heroes\\HeroPodr.as"
#include "..\\Heroes\\HeroMedic.as"
#include "..\\Heroes\\HeroPulik.as"
#include "..\\Heroes\\HeroEngineer.as"


void A004_Active(unit caster, int abilityId, int abilityLevel, unit target, float targX, float targY, ability abil) {
    Debug("A004_Active", "A004 casted by " + Jass::GetUnitName(caster));
}

void InitSkillAbilities() {
	Debug("InitSkillAbilities", "Registering hero ability handlers");
    RegisterAbilityCastHandler('A004', @A004_Active);
	Debug("InitSkillAbilities", "Init Piro skills");
    Piro::InitPiroSkills();
	Debug("InitSkillAbilities", "Init Stalker skills");
    Stalker::InitStalkerSkills();
	Debug("InitSkillAbilities", "Init Sniper skills");
    Sniper::InitSniperSkills();
	Debug("InitSkillAbilities", "Init Roket skills");
    Roket::InitRoketSkills();
	Debug("InitSkillAbilities", "Init Podr skills");
    Podr::InitPodrSkills();
	Debug("InitSkillAbilities", "Init Medic skills");
    Medic::InitMedicSkills();
	Debug("InitSkillAbilities", "Init Pulik skills");
    Pulik::InitPulikSkills();
	Debug("InitSkillAbilities", "Init Engineer skills");
    Engineer::InitEngineerSkills();
	Debug("InitSkillAbilities", "All hero handlers registered");
    //RegisterAbilityCastHandler('A0A2', @A0A2_Active);
    //RegisterAbilityCastHandler('A0AL', @A0AL_Active);
    //RegisterAbilityCastHandler('A0BC', @A0BC_Active);   
    //RegisterAbilityCastHandler('A0B1', @A0B1_Active);
    //RegisterAbilityCastHandler('A0B4', @A0B4_Active);
    //RegisterAbilityCastHandler('A047', @A047_Active);
    //RegisterAbilityCastHandler('A0IM', @A0IM_Active);
	//RegisterAbilityCastHandler('A006', @A006_Active);
	//RegisterAbilityCastHandler('A0QH', @A0QH_Active);
	//RegisterAbilityCastHandler('A0SU', @A0SU_Active);
	//RegisterAbilityCastHandler('A07T', @A07T_Active);
	//RegisterAbilityCastHandler('A20F', @A20F_Active);
	//RegisterAbilityCastHandler('A0SR', @A0SR_Active);
	//RegisterAbilityCastHandler('A0SV', @A0SV_Active);
	//RegisterAbilityCastHandler('A07I', @A07I_Active);
	//RegisterAbilityCastHandler('A182', @A182_Active);
	//RegisterAbilityCastHandler('A08F', @A08F_Active);
	//RegisterAbilityCastHandler('A0AN', @A0AN_Active);
	//RegisterAbilityCastHandler('A08G', @A08G_Active);
	//RegisterAbilityCastHandler('A09W', @A09W_Active);
	//RegisterAbilityCastHandler('A09X', @A09X_Active);
	//RegisterAbilityCastHandler('A0AK', @A0AK_Active);
}




funcdef void AbilityCastCallback(unit caster, int abilityId, int abilityLevel, unit target, float targX, float targY, ability abil);

// Мап: abilityId → callback
dictionary g_AbilityCastHandlers;

// Глобальный триггер на все касты
trigger g_AbilityCastTrigger;

// Регистрация обработчика для способности
void RegisterAbilityCastHandler(int abilityId, AbilityCastCallback@ cb) {
	if (cb is null) return;
	Debug("RegisterAbilityCastHandler", "abilityId=" + Jass::I2S(abilityId));
	g_AbilityCastHandlers["" + abilityId] = @cb;
}

// Callback для триггера — вызывается при касте любой способности
void OnAnyAbilityCast() {
	unit caster = Jass::GetTriggerUnit();
	int abilId = Jass::GetSpellAbilityId();
	int abilLvl = Jass::GetUnitAbilityLevel(caster, abilId);
	unit target = Jass::GetSpellTargetUnit();
	float targX = Jass::GetSpellTargetX();
	float targY = Jass::GetSpellTargetY();
	ability abil = Jass::GetSpellAbility();
	string key = "" + abilId;
    Debug("OnAnyAbilityCast", "Ability cast: " + Jass::GetUnitName(caster) + " casted ability ID " + key);
	if (g_AbilityCastHandlers.exists(key)) {
		AbilityCastCallback@ cb = cast<AbilityCastCallback@>(g_AbilityCastHandlers[key]);
		if (cb !is null) {
			cb(caster, abilId, abilLvl, target, targX, targY, abil);
		}
	}
	caster = nil;
	target = nil;
	abil = nil;
}

// Инициализация системы кастов (вызывать из main/init)
void InitAbilityCastSystem() {
    g_AbilityCastTrigger = Jass::CreateTrigger();
	for (int i = 0; i < 16; ++i) {
		player p = Jass::Player(i);
		Jass::TriggerRegisterPlayerUnitEvent(
			g_AbilityCastTrigger,
			p,
			Jass::EVENT_PLAYER_UNIT_SPELL_CAST,
			nil
		);
	}
	Jass::TriggerAddAction(g_AbilityCastTrigger, @OnAnyAbilityCast);

    InitSkillAbilities();
	Debug("InitAbilityCastSystem", "Ability cast trigger initialized");
}

// Инициализация всех скилловых обработчиков    
