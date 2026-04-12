int GetWaveUnit_Actions() {
	int wave = 0; //GetWaveNumber();
	if(wave <= 5) {
		return 'I123';
	} else if(wave <= 10) {
		return 'I124';
	} else if(wave <= 15) {
		return 'I125';
	} else if(wave <= 20) {
		return 'I126';
	} else {
		return 'I127';
	}
}

void Tainik_Death(unit diedunit, unit killer) {
	unit Gobllin = GoblinUnit[Jass::GetPlayerId(Jass::GetOwningPlayer(killer))];
	if (Gobllin == nil) return;
	UnitData@ ud = GetUnitData(Gobllin);
	if (ud is null) return;
	HeroGameData@ heroData = ud.heroGameData;
	float Luck = ud.totalStats.luck;
	float x = Jass::GetUnitX(diedunit);
	float y = Jass::GetUnitY(diedunit);
	float random = Jass::GetRandomReal(0, 100);
	if(random < 50 * (1 + Luck / 30.0)) {
		for(float chance = 100 + 10 * Luck, i = Jass::GetRandomReal(0, 100); i < chance; i = Jass::GetRandomReal(0, 100), chance -= 100) {
			float chance1 = 60 - Luck;
			float chance2 = 20 + Luck * 3;
			float chance3 = 20 + Luck * 2;
			float chance4 = 10 + Luck * 2;
			float chance5 = 5 + Luck;
			float overall = chance1 + chance2 + chance3 + chance4 + chance5;
			float roll = Jass::GetRandomReal(0, overall);
			if(roll < chance1) {
				Jass::CreateUnit( Jass::Player(Jass::PLAYER_NEUTRAL_PASSIVE), 'n02D', x, y, 0. );
			} else if(roll < chance1 + chance2) {
				switch(Jass::GetRandomInt(0, 5)) {
					case 0: Jass::CreateItem( 'I050', x, y ); break;
					case 1: Jass::CreateItem( 'I04Y', x, y ); break;
					case 2: Jass::CreateItem( 'I052', x, y ); break;
					case 3: Jass::CreateItem( 'I04Z', x, y ); break;
					case 4: Jass::CreateItem( 'I051', x, y ); break;
					case 5: Jass::CreateItem( 'I04X', x, y ); break;
				}
			} else if(roll < chance1 + chance2 + chance3) {
				switch(Jass::GetRandomInt(0, 4)) {
					case 0: Jass::CreateItem( 'I02T', x, y ); break;
					case 1: Jass::CreateItem( 'I036', x, y ); break;
					case 2: Jass::CreateItem( 'I09Z', x, y ); break;
					case 3: Jass::CreateItem( 'I047', x, y ); break;
					case 4: Jass::CreateItem( 'I037', x, y ); break;
				}
			} else if(roll < chance1 + chance2 + chance3 + chance4) {
				switch(Jass::GetRandomInt(0, 3)) {
					case 0: Jass::CreateItem( 'I070', x, y ); break;
					case 1: Jass::CreateItem( 'I0A3', x, y ); break;
					case 2: Jass::CreateItem( 'I048', x, y ); break;
					case 3: Jass::CreateItem( 'I0A4', x, y ); break;
				}
			} else {
				switch(Jass::GetRandomInt(0, 1)) {
					case 0: Jass::CreateItem( GetWaveUnit_Actions(), x, y ); break;
					case 1: Jass::CreateItem( 'I123', x, y ); break;
				}
			}
			if(heroData.ArchLevel > 0) {
				chance1 = 60 - Luck;
				chance2 = 30 + Luck;
				chance3 = 20 + Luck;
				chance4 = 15 + Luck * 2;
				chance5 = 8  + Luck * 3;
				overall = chance1 + chance2 + chance3 + chance4 + chance5;
				roll = Jass::GetRandomReal(0, overall);
				int OreType;
				if(roll < chance1) {
					Jass::CreateUnit( Jass::Player(Jass::PLAYER_NEUTRAL_PASSIVE), 'n02D', x, y, 0. );
				} else if(roll < chance1 + chance2) {
					OreType = 'I000';
				} else if(roll < chance1 + chance2 + chance3) {
					OreType = 'I001';
				} else if(roll < chance1 + chance2 + chance3 + chance4) {
					OreType = 'I002';
				} else {
					OreType = 'I003';
				}
				if(IsUnitEngineer(killer)) {
					Jass::CreateItem( OreType, x, y );
					Jass::CreateItem( OreType, x, y );
					Jass::CreateItem( OreType, x, y );
					Jass::CreateItem( OreType, x, y );
				} else {
					Jass::CreateItem( OreType, x, y );
				}

				chance1 = 120 - Luck * 2;
				chance2 = 25;
				chance3 = 10 + Luck / 5;
				chance4 = 4  + Luck / 10;
				chance5 = 2  + Luck / 10;
				overall = chance1 + chance2 + chance3 + chance4 + chance5;
				roll = Jass::GetRandomReal(0., overall);
				if(roll < chance1) {
					//Jass::CreateUnit( Jass::Player(Jass::PLAYER_NEUTRAL_PASSIVE), 'n02D', x, y, 0. );
				} else if(roll < chance1 + chance2) {
					switch(Jass::GetRandomInt(0, 5)) {
						case 0: Jass::CreateItem( 'I050', x, y ); break;
						case 1: Jass::CreateItem( 'I04Y', x, y ); break;
						case 2: Jass::CreateItem( 'I052', x, y ); break;
						case 3: Jass::CreateItem( 'I04Z', x, y ); break;
						case 4: Jass::CreateItem( 'I051', x, y ); break;
						case 5: Jass::CreateItem( 'I04X', x, y ); break;
					}
				} else if(roll < chance1 + chance2 + chance3) {
					Jass::CreateItem( 'I0OV', x, y );
				} else if(roll < chance1 + chance2 + chance3 + chance4) {
					//Jass::CreateItem( 'I061', x, y );
				} else {
					Jass::CreateItem( 'I0D1', x, y );
				}
			}
		}
	}
}










funcdef void DeathCallback(unit diedunit, unit killer);

// Мап: unitTypeId → callback
dictionary g_DeathHandlers;

// Глобальный триггер на все смерти
trigger g_DeathTrigger;

// Регистрация обработчика для смерти юнита
void RegisterDeathHandler(int unitTypeId, DeathCallback@ cb) {
	if (cb is null) return;
	g_DeathHandlers["" + unitTypeId] = @cb;
}

// Callback для триггера — вызывается при смерти любой единицы
void OnAnyDeath() {
	unit diedunit = Jass::GetTriggerUnit();
    unit killer = Jass::GetKillingUnit();
    int diedtypeId = Jass::GetUnitTypeId(diedunit);
    int killertypeId = Jass::GetUnitTypeId(killer);
	string key = "" + diedtypeId;
    Jass::ConsolePrint("Unit death: " + Jass::GetUnitName(diedunit) + " killed by " + Jass::GetUnitName(killer) + " (ID " + Jass::UnitId2String(diedtypeId) + ")");
	if (g_DeathHandlers.exists(key)) {
		DeathCallback@ cb = cast<DeathCallback@>(g_DeathHandlers[key]);
		if (cb !is null) {
			cb(diedunit, killer);
		}
	}
	diedunit = nil;
	killer = nil;
}

void InitDeathAbilities() {
    // Здесь можно зарегистрировать обработчики для конкретных юнитов
    // Например:
    RegisterDeathHandler('h01F', @Tainik_Death);
}

// Инициализация системы смерти (вызывать из main/init)
void InitDeathSystem() {
    g_DeathTrigger = Jass::CreateTrigger();
	for (int i = 0; i < 16; ++i) {
		Jass::TriggerRegisterPlayerUnitEvent(
			g_DeathTrigger,
			Jass::Player(i),
			Jass::EVENT_PLAYER_UNIT_DEATH,
			nil
		);
	}
	Jass::TriggerAddAction(g_DeathTrigger, @OnAnyDeath);

    InitDeathAbilities();
}
