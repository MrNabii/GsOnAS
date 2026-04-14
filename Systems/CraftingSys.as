// ═══════════════════════════════════════════════════════════════════════════
// CraftingSys.as — Система крафта
// ═══════════════════════════════════════════════════════════════════════════
// ─── Конфигурация ───
int MAX_CRAFT_INGREDIENTS = 6;  // Макс. ингредиентов в рецепте (можно менять)
dictionary ItemCraftDataMap;

// Массивы рецептов по местам крафта
array<CraftRecipe@> Recipes_1(500);    // Простая Кузница
array<CraftRecipe@> Recipes_2(500);    // Великая Кузница
array<CraftRecipe@> Recipes_3(30);     // Переплавка
array<CraftRecipe@> Recipes_4(10);     // Переплавка х10
array<CraftRecipe@> Recipes_5(20);     // Зельки
array<CraftRecipe@> Recipes_6(100);    // Ангел Кузница
array<CraftRecipe@> Recipes_7(100);    // Демон Кузница
array<CraftRecipe@> Recipes_8(15);     // FS Кузница
array<CraftRecipe@> Recipes_9(20);     // Драк Кузница
array<CraftRecipe@> Recipes_10(20);    // Станция Связи
array<CraftRecipe@> Recipes_1_1(10);   // Боеприпасы
array<CraftRecipe@> Recipes_20(30);    // Мастерская Реликвии

CraftRecipe@ Recipes_Nos;
array<string> PlaceNames(11);

// Все ItemTypeId, для которых есть хотя бы один рецепт крафта
array<int> AllCraftableItems;


// Возвращает (JASS-style) индекс (1-based) первого найденного предмета типа itemId, либо 0 если нет
int GetInventoryIndexOfItemTypeEx2(unit whichUnit, int itemId) {
    int invSize = Jass::UnitInventorySize(whichUnit);
    for (int index = 0; index < invSize; index++) {
        item indexItem = Jass::UnitItemInSlot(whichUnit, index);
        if (indexItem != nil && Jass::GetItemTypeId(indexItem) == itemId) {
            return index + 1;
        }
    }
    return 0;
}

// Возвращает true, если у юнита есть предмет типа itemId
bool UnitHasItemOfTypeEx(unit whichUnit, int itemId) {
    return GetInventoryIndexOfItemTypeEx2(whichUnit, itemId) > 0;
}

item GetItemOfTypeFromUnitEx(unit whichUnit, int itemId) {
    int index = GetInventoryIndexOfItemTypeEx2(whichUnit, itemId);
    if (index == 0) {
        return nil;
    } else {
        return Jass::UnitItemInSlot(whichUnit, index - 1);
    }
}

item UnitAddItemByIdSwapped(int itemId, unit whichHero, int ownerPlayerId = -1) {
    item lastCreatedItem = CreateRegisteredItem(itemId, Jass::GetUnitX(whichHero), Jass::GetUnitY(whichHero), ownerPlayerId);
    Jass::UnitAddItem(whichHero, lastCreatedItem);
    return lastCreatedItem;
}

// ═══════════════════════════════════════════════════════════════════════════
// ItemCraftData — данные крафта для конкретного ItemTypeId
//
// Пример получения данных:
//   ItemCraftData@ data = GetItemCraftData('I0AA');
//   if (data !is null) {
//       int n = data.GetRecipeCount();           // сколько вариантов рецептов
//       CraftRecipe@ r = data.GetRecipe(0);      // первый рецепт
//       for (int i = 0; i < r.GetIngredientCount(); i++) {
//           int id  = r.GetIngredientItemId(i);   // ItemTypeId ингредиента
//           int cnt = r.GetIngredientReqCount(i);  // необходимое количество
//       }
//       for (int i = 0; i < data.GetUsedInCount(); i++) {
//           int uid = data.GetUsedInItem(i);       // где используется
//       }
//   }
// ═══════════════════════════════════════════════════════════════════════════
class ItemCraftData {
    int ItemTypeId = 0;       // ID типа предмета
    array<int> Place;       // Где крафтится (у каждого рецепта может быть свое место крафта)   
    int BookLevel  = 0;       // Уровень крафта
    int CraftNum   = 0;       // Кол-во вариантов рецептов

    // Рецепты, ПРОИЗВОДЯЩИЕ этот предмет (может быть несколько вариантов)
    array<CraftRecipe@> Recipes;

    // Предметы, в крафте КОТОРЫХ используется этот предмет (для книжки крафтов)
    array<int> UsedInItems;
    ItemCraftData() {}

    void AddRecipe(CraftRecipe@ recipe) {
        Recipes.insertLast(recipe);
        Place.insertLast(recipe.GetPlace());
    }

    // Добавить "используется в" (без дубликатов)
    void AddUsedIn(int itemTypeId) {
        for (uint i = 0; i < UsedInItems.length(); i++)
            if (UsedInItems[i] == itemTypeId) return;
        UsedInItems.insertLast(itemTypeId);
    }

    // --- Геттеры ---
    int GetRecipeCount()          { return int(Recipes.length()); }
    CraftRecipe@ GetRecipe(int i) {
        if (i >= 0 && i < int(Recipes.length())) return Recipes[i];
        return null;
    }
    int GetPlace(int i) {
        if (i >= 0 && i < int(Place.length())) return Place[i];
        return 0;
    }
    int GetUsedInCount()          { return int(UsedInItems.length()); }
    int GetUsedInItem(int i)      {
        if (i >= 0 && i < int(UsedInItems.length())) return UsedInItems[i];
        return 0;
    }
}

// ─── Получить ItemCraftData (null если нет) ───
ItemCraftData@ GetItemCraftData(int ItemTypeID) {
    string key = "" + ItemTypeID;
    ItemCraftData@ icd;
    if (ItemCraftDataMap.get(key, @icd))
        return icd;
    return null;
}

// ─── Получить или создать ItemCraftData ───
ItemCraftData@ GetOrCreateItemCraftData(int ItemTypeID) {
    string key = "" + ItemTypeID;
    ItemCraftData@ icd;
    if (ItemCraftDataMap.get(key, @icd))
        return icd;
    @icd = ItemCraftData();
    icd.ItemTypeId = ItemTypeID;
    ItemCraftDataMap.set(key, @icd);
    return icd;
}


// ═══════════════════════════════════════════════════════════════════════════
// CraftRecipe — рецепт крафта
// ═══════════════════════════════════════════════════════════════════════════
class CraftRecipe {
    private int ResultItem        = 0;
    private int ResultItemCharges = 0;
    private array<int> ReqItems;
    private array<int> RICount;
    private int id        = 0;
    private int index     = 0;
    private int level     = 0;
    private int RecipePlace = 0;

    // Слоты инвентаря, найденные последним CheckRequirements
    private array<int> matchedSlots;

    CraftRecipe() {
        ReqItems.resize(MAX_CRAFT_INGREDIENTS);
        RICount.resize(MAX_CRAFT_INGREDIENTS);
        matchedSlots.resize(MAX_CRAFT_INGREDIENTS);
        for (int i = 0; i < MAX_CRAFT_INGREDIENTS; i++) matchedSlots[i] = -1;
    }

    // ─── Геттеры (для UI / книжки крафтов) ───
    int GetResultItem()       { return ResultItem; }
    int GetResultCharges()    { return ResultItemCharges; }
    int GetPlace()            { return RecipePlace; }
    int GetLevel()            { return level; }

    int GetIngredientCount() {
        for (int i = 0; i < MAX_CRAFT_INGREDIENTS; i++)
            if (ReqItems[i] <= 0) return i;
        return MAX_CRAFT_INGREDIENTS;
    }
    int GetIngredientItemId(int idx) {
        return (idx >= 0 && idx < MAX_CRAFT_INGREDIENTS) ? ReqItems[idx] : 0;
    }
    int GetIngredientReqCount(int idx) {
        return (idx >= 0 && idx < MAX_CRAFT_INGREDIENTS) ? RICount[idx] : 0;
    }

    // ─── Сеттеры (для регистрации рецептов — обратная совместимость) ───
    void SetItemPlace(int place) {
        RecipePlace = place;
    }

    void SetCraftLevel(int lvl) {
        level = lvl;
        ItemCraftData@ icd = GetOrCreateItemCraftData(ResultItem);
        icd.BookLevel = level;
    }

    void SetResultItem(int itemID, int charges) {
        ResultItem = itemID;
        ResultItemCharges = charges;
        ItemCraftData@ icd = GetOrCreateItemCraftData(ResultItem);
        icd.ItemTypeId = ResultItem;
        icd.BookLevel = level;
        icd.CraftNum++;
        icd.AddRecipe(@this);
    }

    bool AddRequirement(int itemID, int count) {
        for (int i = 0; i < MAX_CRAFT_INGREDIENTS; i++) {
            if (ReqItems[i] <= 0) {
                ReqItems[i] = itemID;
                RICount[i]  = count;
                // Обновить "где используется" в ItemCraftData
                ItemCraftData@ ingData = GetOrCreateItemCraftData(itemID);
                ingData.AddUsedIn(ResultItem);
                return true;
            }
        }
        return false;
    }

    // ─── Ownership: получить владельца предмета ───
    // 0 = общий, >0 = ID игрока (1-based) = личный
    int GetItemOwnership(item itm) {
        int ownerPlayerId = GetItemOwnerPlayerId(itm);
        if (ownerPlayerId > 0) {
            return ownerPlayerId;
        }
        return 0;
    }

    // ═══════════════════════════════════════════════════════════════════════
    // CheckRequirements — проверка наличия ингредиентов
    //
    // craftingPlayerId: 1-based ID игрока. 0 = без проверки владения (legacy)
    //
    // Правила владения:
    //   - Общие предметы (ownr == 0) можно использовать всегда
    //   - Личные предметы (ownr == craftingPlayerId) — только свои
    //   - Чужие предметы (ownr > 0 && ownr != craftingPlayerId) — ПРОПУСКАЮТСЯ
    // ═══════════════════════════════════════════════════════════════════════
    bool CheckRequirements(unit cUnit, int craftingPlayerId = 0) {
        int invSize = Jass::UnitInventorySize(cUnit);
        for (int k = 0; k < MAX_CRAFT_INGREDIENTS; k++) matchedSlots[k] = -1;

        // Сколько charges уже «зарезервировано» в каждом слоте
        array<int> slotChargesUsed(invSize);

            for (int i = 0; i < MAX_CRAFT_INGREDIENTS && ReqItems[i] > 0; i++) { 
            int searchFrom = 0;
            // Дубликаты: начать поиск от предыдущего совпадения
            if (i > 0 && ReqItems[i] == ReqItems[i - 1] && matchedSlots[i - 1] >= 0) {
                searchFrom = matchedSlots[i - 1];
            }

            bool found = false;
            for (int s = searchFrom; s < invSize; s++) {
                item itm = Jass::UnitItemInSlot(cUnit, s);
                if (itm == nil) continue;
                if (Jass::GetItemTypeId(itm) != ReqItems[i]) { itm = nil; continue; }

                // Проверка владения
                if (craftingPlayerId > 0) {
                    int ownr = GetItemOwnership(itm);
                    if (ownr != 0 && ownr != craftingPlayerId) { itm = nil; continue; }
                }

                int totalCharges = Jass::GetItemCharges(itm);
                int available = totalCharges - slotChargesUsed[s];

                if (RICount[i] > 0) {
                    // Предмет со charges: можно использовать один слот несколько раз
                    if (available < RICount[i]) { itm = nil; continue; }
                    slotChargesUsed[s] += RICount[i];
                } else {
                    // Предмет без charges: каждый занимает свой слот
                    if (slotChargesUsed[s] > 0) { itm = nil; continue; }
                    slotChargesUsed[s] = 1;
                }

                matchedSlots[i] = s;
                found = true;
                itm = nil;
                break;
            }
            if (!found) return false;
        }
        return true;
    }

    // ═══════════════════════════════════════════════════════════════════════
    // RemoveRequirements — удалить/уменьшить ингредиенты из инвентаря
    // ═══════════════════════════════════════════════════════════════════════
    void RemoveRequirements(unit cUnit, int craftingPlayerId = 0) {
        for (int i = 0; i < MAX_CRAFT_INGREDIENTS && ReqItems[i] > 0; i++) {
            int invSize = Jass::UnitInventorySize(cUnit);
            for (int s = 0; s < invSize; s++) {
                item itm = Jass::UnitItemInSlot(cUnit, s);
                if (itm == nil) continue;
                if (Jass::GetItemTypeId(itm) != ReqItems[i]) { itm = nil; continue; }
                if (craftingPlayerId > 0) {
                    int ownr = GetItemOwnership(itm);
                    if (ownr != 0 && ownr != craftingPlayerId) { itm = nil; continue; }
                }
                int charges = Jass::GetItemCharges(itm) - RICount[i];
                if (charges <= 0) {
                    Jass::RemoveItem(itm);
                } else {
                    Jass::SetItemCharges(itm, charges);
                }
                itm = nil;
                break;
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // CraftItem — скрафтить предмет
    // craftingPlayerId = 0: без проверки владения (legacy совместимость)
    // craftingPlayerId > 0: проверка + результат наследует ownership
    // ═══════════════════════════════════════════════════════════════════════
    void CraftItem(unit cUnit, int craftingPlayerId = 0) {
        if (!CheckRequirements(cUnit, craftingPlayerId)) {
            id = 0; index = 0;
            return;
        }
        if (ResultItem == 'I0OB') { //GetSave_Book
            id = 0; index = 0;
            return;
        }
        RemoveRequirements(cUnit, craftingPlayerId);
        if (UnitHasItemOfTypeEx(cUnit, ResultItem) &&
            Jass::GetItemCharges(GetItemOfTypeFromUnitEx(cUnit, ResultItem)) != 0) {
            Jass::SetItemCharges(
                GetItemOfTypeFromUnitEx(cUnit, ResultItem),
                Jass::GetItemCharges(GetItemOfTypeFromUnitEx(cUnit, ResultItem)) + ResultItemCharges);
        } else {
            item newItm = UnitAddItemByIdSwapped(ResultItem, cUnit, (craftingPlayerId > 0) ? craftingPlayerId : -1);
            Jass::SetItemCharges(newItm, ResultItemCharges);
            newItm = nil;
        }
        id = 0; index = 0;
    }

    // CraftItem2 — крафт БЕЗ удаления ингредиентов (legacy)
    void CraftItem2(unit cUnit, int craftingPlayerId = 0) {
        if (!CheckRequirements(cUnit, craftingPlayerId)) {
            id = 0;
            return;
        }
        if (UnitHasItemOfTypeEx(cUnit, ResultItem) &&
            Jass::GetItemCharges(GetItemOfTypeFromUnitEx(cUnit, ResultItem)) != 0) {
            Jass::SetItemCharges(
                GetItemOfTypeFromUnitEx(cUnit, ResultItem),
                Jass::GetItemCharges(GetItemOfTypeFromUnitEx(cUnit, ResultItem)) + ResultItemCharges);
        } else {
            item newItm = UnitAddItemByIdSwapped(ResultItem, cUnit, (craftingPlayerId > 0) ? craftingPlayerId : -1);
            Jass::SetItemCharges(newItm, ResultItemCharges);
            newItm = nil;
        }
        id = 0;
    }

    // CraftNos — квестовый крафт (legacy, без ownership)
    // void CraftNos(unit cUnit) {
    //     if (CheckRequirements(cUnit)) {
    //         int cv = Jass::GetItemUserData(GetItemOfTypeFromUnitEx(cUnit, 'I0GU'));
    //         if (!(Jass::GetHeroLevel(udg_Herois[cv]) >= 10 && udg_BagQuest_Completed[cv] == 0)) {
    //             return;
    //         }
    //         RemoveRequirements(cUnit);
    //         player owner = Jass::GetOwningPlayer(udg_Herois[cv]);
    //         if (Jass::GetLocalPlayer() == Jass::Player(cv - 1)) {
    //             Jass::DisplayTimedTextToPlayer(Jass::GetLocalPlayer(), 0, 0, Jass::bj_TEXT_DELAY_QUESTDONE, " ");
    //             Jass::DisplayTimedTextToPlayer(Jass::GetLocalPlayer(), 0, 0, Jass::bj_TEXT_DELAY_QUESTDONE, udg_Text_MSG[7]);
    //             Jass::StartSound(bj_questCompletedSound);
    //         }
    //         udg_Mara_unit[cv] = Jass::CreateUnit(owner, 'h02N',
    //             Jass::GetUnitX(udg_Herois[cv]), Jass::GetUnitY(udg_Herois[cv]), Jass::bj_UNIT_FACING);
    //         SetSave_Nos(Jass::Player(cv - 1), 1);
    //         udg_BagQuest_Completed[cv] = 1;
    //         Jass::DestroyEffect(Jass::AddSpecialEffectTarget(
    //             "Abilities\\Spells\\Undead\\AnimateDead\\AnimateDeadTarget.mdl",
    //             udg_Mara_unit[cv], "origin"));
    //     }
    // }

    void CheckItem(unit cUnit) {
        for (int i = 0; i < MAX_CRAFT_INGREDIENTS && ReqItems[i] > 0; i++) {
            item itm = CreateRegisteredItem(ReqItems[i], Jass::GetUnitX(cUnit), Jass::GetUnitY(cUnit));
            Jass::SetItemCharges(itm, RICount[i]);
        }
    }

    void NextItemCraft(item itm) {
        string t = "";
        for (int i = 0; i < MAX_CRAFT_INGREDIENTS && ReqItems[i] > 0; i++) {
            if (Jass::GetItemTypeId(itm) == ReqItems[i]) {
                t += Jass::GetObjectName(ResultItem);
                if (ResultItemCharges > 0) {
                    t += " x" + ResultItemCharges + " =";
                } else {
                    t += " =";
                }
                for (int k = 0; k < MAX_CRAFT_INGREDIENTS && ReqItems[k] > 0; k++) {
                    if (ReqItems[k] == 'I0MC') return;
                    t += " " + Jass::GetObjectName(ReqItems[k]);
                    if (RICount[k] > 0) {
                        t += " x" + RICount[k];
                    }
                    if (k < MAX_CRAFT_INGREDIENTS - 1 && ReqItems[k + 1] > 0) {
                        t += " +";
                    }
                }
                if (Jass::GetLocalPlayer() == Jass::GetOwningPlayer(Jass::GetTriggerUnit())) {
                    Jass::DisplayTimedTextToPlayer(Jass::GetTriggerPlayer(), 0, 0, 60.0, t);
                }
                return;
            }
        }
    }

    void ThisItemCraft(item itm) {
        if (Jass::GetItemTypeId(itm) != ResultItem) return;
        string t = Jass::GetObjectName(ResultItem);
        if (ResultItemCharges > 0) {
            t += " x" + ResultItemCharges + " =";
        } else {
            t += " =";
        }
        for (int i = 0; i < MAX_CRAFT_INGREDIENTS && ReqItems[i] > 0; i++) {
            if (ReqItems[i] == 'I0MC') return;
            t += " " + Jass::GetObjectName(ReqItems[i]);
            if (RICount[i] > 0) {
                t += " x" + RICount[i];
            }
            if (i < MAX_CRAFT_INGREDIENTS - 1 && ReqItems[i + 1] > 0) {
                t += " +";
            }
        }
        if (Jass::GetLocalPlayer() == Jass::GetOwningPlayer(Jass::GetTriggerUnit())) {
            Jass::DisplayTimedTextToPlayer(Jass::GetTriggerPlayer(), 0, 0, 60.0, t);
        }
    }
}

// Собрать список всех крафтовых предметов (вызвать после регистрации рецептов)
void BuildCraftableItemsList() {
    AllCraftableItems.resize(0);
    array<string> keys = ItemCraftDataMap.getKeys();
    for (uint i = 0; i < keys.length(); i++) {
        ItemCraftData@ icd;
        ItemCraftDataMap.get(keys[i], @icd);
        if (icd !is null && icd.GetRecipeCount() > 0) {
            AllCraftableItems.insertLast(icd.ItemTypeId);
        }
    }
}

void InitCraftingSystem_Recipes_1() {
    int i = 0;
    int j = 0;
    int k = 0;

    PlaceNames[0] = "Обычная Кузница";
    PlaceNames[1] = "Обычная Кузница (Боеприпасы)";
    PlaceNames[2] = "Великая Кузница";
    PlaceNames[3] = "Станция Связи";
    PlaceNames[4] = "Плавильная печь";
    PlaceNames[5] = "Зельеварка";
    PlaceNames[6] = "Ангельская Кузница";
    PlaceNames[7] = "Демоническая Кузница";
    PlaceNames[8] = "Драконья Кузница";
    PlaceNames[9] = "Мастерская Реликварий";

    // Recipes_1
    for (i = 0; i < 500; i++) {
        @Recipes_1[i] = CraftRecipe();
        Recipes_1[i].SetItemPlace(1);
    }
    // Recipes_1_1
    for (i = 0; i < 10; i++) {
        @Recipes_1_1[i] = CraftRecipe();
        Recipes_1_1[i].SetItemPlace(2);
    }
    // Recipes_2
    for (i = 0; i < 500; i++) {
        @Recipes_2[i] = CraftRecipe();
        Recipes_2[i].SetItemPlace(3);
    }
    // Recipes_10
    for (i = 0; i < 20; i++) {
        @Recipes_10[i] = CraftRecipe();
        Recipes_10[i].SetItemPlace(4);
    }
    // Recipes_5
    for (i = 0; i < 20; i++) {
        @Recipes_5[i] = CraftRecipe();
        Recipes_5[i].SetItemPlace(6);
    }
    // Recipes_20
    for (i = 0; i < 30; i++) {
        @Recipes_20[i] = CraftRecipe();
        Recipes_20[i].SetItemPlace(10);
    }

    // РљРІРµСЃС‚-СЂРµС†РµРїС‚ РЅРѕСЃР°
    @Recipes_Nos = CraftRecipe();
    Recipes_Nos.SetResultItem('0000', 0);
    Recipes_Nos.AddRequirement('I0I5', 0);
    Recipes_Nos.AddRequirement('I0I6', 0);
    Recipes_Nos.AddRequirement('I0I4', 0);
    Recipes_Nos.AddRequirement('I0H1', 0);
    Recipes_Nos.AddRequirement('I0GU', 0);
    Recipes_Nos.AddRequirement('I037', 2);
    Recipes_Nos.SetCraftLevel(0);

    Recipes_2[0].SetResultItem('0000', 0);

    // Recipes_10 вЂ” РЎС‚Р°РЅС†РёСЏ РЎРІСЏР·Рё
    Recipes_10[0].SetResultItem('I0NS', 0);
    Recipes_10[0].AddRequirement('I000', 50);
    Recipes_10[0].AddRequirement('I001', 40);
    Recipes_10[0].AddRequirement('I002', 30);
    Recipes_10[0].AddRequirement('I003', 10);
    Recipes_10[0].SetCraftLevel(50);

    Recipes_10[1].SetResultItem('I0NT', 0);
    Recipes_10[1].AddRequirement('I0OY', 0);
    Recipes_10[1].AddRequirement('I048', 2);
    Recipes_10[1].AddRequirement('I08W', 0);
    Recipes_10[1].AddRequirement('I08W', 0);
    Recipes_10[1].AddRequirement('I0OB', 10);
    Recipes_10[1].SetCraftLevel(50);

    // Recipes_1_1 вЂ” Р‘РѕРµРїСЂРёРїР°СЃС‹
    //РђСЂРєР°РЅРёС‚РѕРІС‹Рµ Р±РѕРµРїСЂРёРїР°СЃС‹
    i = 0;
    Recipes_1_1[i].SetResultItem('I01W', 50);
    Recipes_1_1[i].AddRequirement('I003', 10);
    Recipes_1_1[i].SetCraftLevel(0);
    i = 1;
    Recipes_1_1[i].SetResultItem('I01W', 5);
    Recipes_1_1[i].AddRequirement('I003', 1);
    Recipes_1_1[i].SetCraftLevel(0);
    //РўРѕСЂРёРµРІС‹Рµ Р±РѕРµРїСЂРёРїР°СЃС‹
    i = 2;
    Recipes_1_1[i].SetResultItem('I01V', 50);
    Recipes_1_1[i].AddRequirement('I002', 10);
    Recipes_1_1[i].SetCraftLevel(0);
    i = 3;
    Recipes_1_1[i].SetResultItem('I01V', 5);
    Recipes_1_1[i].AddRequirement('I002', 1);
    Recipes_1_1[i].SetCraftLevel(0);
    //РЎРµСЂРµР±СЂСЏРЅС‹Рµ Р±РѕРµРїСЂРёРїР°СЃС‹
    i = 4;
    Recipes_1_1[i].SetResultItem('I01U', 50);
    Recipes_1_1[i].AddRequirement('I001', 10);
    Recipes_1_1[i].SetCraftLevel(0);
    i = 5;
    Recipes_1_1[i].SetResultItem('I01U', 5);
    Recipes_1_1[i].AddRequirement('I001', 1);
    Recipes_1_1[i].SetCraftLevel(0);
    //Р–РµР»РµР·РЅС‹Рµ Р±РѕРµРїСЂРёРїР°СЃС‹
    i = 6;
    Recipes_1_1[i].SetResultItem('I01T', 50);
    Recipes_1_1[i].AddRequirement('I000', 10);
    Recipes_1_1[i].SetCraftLevel(0);
    i = 7;
    Recipes_1_1[i].SetResultItem('I01T', 5);
    Recipes_1_1[i].AddRequirement('I000', 1);
    Recipes_1_1[i].SetCraftLevel(0);

    // в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ Recipes_1 вЂ” РџСЂРѕСЃС‚Р°СЏ РљСѓР·РЅРёС†Р° в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
    // РЈСЂРѕРІРµРЅСЊ 0 вЂ” Р±Р°Р·РѕРІС‹Рµ РїСЂРµРґРјРµС‚С‹
    //РђСЂРєР°РЅРёС‚РѕРІР°СЏ СѓРґРѕС‡РєР°
    i = 1;
    Recipes_1[i].SetResultItem('I0AA', 0);
    Recipes_1[i].AddRequirement('I09H', 0);
    Recipes_1[i].AddRequirement('I00T', 20);
    Recipes_1[i].AddRequirement('I02Y', 0);
    Recipes_1[i].SetCraftLevel(0);
    //РњСѓР»СЊС‚РёСѓРґРѕС‡РєР° (Recipes_2)
    j = 1;
    Recipes_2[j].SetResultItem('I0Q4', 0);
    Recipes_2[j].AddRequirement('I0AA', 0);
    Recipes_2[j].AddRequirement('I08W', 0);
    Recipes_2[j].AddRequirement('I0OT', 3);
    Recipes_2[j].AddRequirement('I0OB', 30);
    Recipes_2[j].SetCraftLevel(0);
    //Р–РµР»РµР·РЅР°СЏ РѕРїС‚РёРєР°
    i = i + 1;
    Recipes_1[i].SetResultItem('I01J', 0);
    Recipes_1[i].AddRequirement('I01I', 0);
    Recipes_1[i].AddRequirement('I00V', 5);
    Recipes_1[i].SetCraftLevel(0);
    //РЎРµСЂРµР±СЂСЏРЅР°СЏ РѕРїС‚РёРєР°
    i = i + 1;
    Recipes_1[i].SetResultItem('I01L', 0);
    Recipes_1[i].AddRequirement('I01I', 0);
    Recipes_1[i].AddRequirement('I00W', 5);
    Recipes_1[i].SetCraftLevel(0);
    //РўРѕСЂРёРµРІР°СЏ РѕРїС‚РёРєР°
    i = i + 1;
    Recipes_1[i].SetResultItem('I01K', 0);
    Recipes_1[i].AddRequirement('I01I', 0);
    Recipes_1[i].AddRequirement('I00U', 5);
    Recipes_1[i].SetCraftLevel(0);
    //РђСЂРєР°РЅРёС‚РѕРІР°СЏ РѕРїС‚РёРєР°
    i = i + 1;
    Recipes_1[i].SetResultItem('I01M', 0);
    Recipes_1[i].AddRequirement('I01I', 0);
    Recipes_1[i].AddRequirement('I00T', 5);
    Recipes_1[i].SetCraftLevel(0);
    //РЎРµСЂРµР±СЂСЏРЅР°СЏ РїС‹Р»СЊ
    i = i + 1;
    Recipes_1[i].SetResultItem('I047', 1);
    Recipes_1[i].AddRequirement('I000', 1);
    Recipes_1[i].AddRequirement('I001', 1);
    Recipes_1[i].SetCraftLevel(0);
    //Р­СЃСЃРµРЅС†РёСЏ Р–РёР·РЅРё
    i = i + 1;
    Recipes_1[i].SetResultItem('I0D3', 0);
    Recipes_1[i].AddRequirement('I0D1', 0);
    Recipes_1[i].AddRequirement('I0D1', 0);
    Recipes_1[i].AddRequirement('I0D1', 0);
    Recipes_1[i].AddRequirement('I0D1', 0);
    Recipes_1[i].AddRequirement('I0D1', 0);
    Recipes_1[i].SetCraftLevel(0);
    //Р­СЃСЃРµРЅС†РёСЏ РћРіРЅСЏ
    i = i + 1;
    Recipes_1[i].SetResultItem('I0D4', 0);
    Recipes_1[i].AddRequirement('I0D2', 0);
    Recipes_1[i].AddRequirement('I0D2', 0);
    Recipes_1[i].AddRequirement('I0D2', 0);
    Recipes_1[i].AddRequirement('I0D2', 0);
    Recipes_1[i].AddRequirement('I0D2', 0);
    Recipes_1[i].SetCraftLevel(0);
    //РЎС‹СЂРЅС‹Р№ Р”РІРёРіР°С‚РµР»СЊ
    i = i + 1;
    Recipes_1[i].SetResultItem('I048', 1);
    Recipes_1[i].AddRequirement('I02Y', 0);
    Recipes_1[i].AddRequirement('I036', 5);
    Recipes_1[i].AddRequirement('I00V', 5);
    Recipes_1[i].SetCraftLevel(0);
    //Р“РµРЅРµСЂР°С‚РѕСЂ
    i = i + 1;
    Recipes_1[i].SetResultItem('I123', 1);
    Recipes_1[i].AddRequirement('I00V', 10);
    Recipes_1[i].AddRequirement('I048', 1);
    Recipes_1[i].AddRequirement('I01M', 0);
    Recipes_1[i].AddRequirement('I008', 10);
    Recipes_1[i].SetCraftLevel(0);
    //Р”РІРёР¶РѕРє РњРў II
    i = i + 1;
    Recipes_1[i].SetResultItem('I07H', 0);
    Recipes_1[i].AddRequirement('I048', 2);
    Recipes_1[i].AddRequirement('I00U', 20);
    Recipes_1[i].SetCraftLevel(0);
    //РќР°РіСЂРµРІР°С‚РµР»СЊРЅС‹Р№ Р±Р»РѕРє
    i = i + 1;
    Recipes_1[i].SetResultItem('I07I', 0);
    Recipes_1[i].AddRequirement('I02Y', 0);
    Recipes_1[i].AddRequirement('I06X', 0);
    Recipes_1[i].AddRequirement('I05H', 0);
    Recipes_1[i].SetCraftLevel(0);
    //Р“РёРіР°РЅС‚СЃРєР°СЏ Р»СѓРїР°
    i = i + 1;
    Recipes_1[i].SetResultItem('I07J', 0);
    Recipes_1[i].AddRequirement('I01J', 0);
    Recipes_1[i].AddRequirement('I01L', 0);
    Recipes_1[i].AddRequirement('I01K', 0);
    Recipes_1[i].AddRequirement('I01M', 0);
    Recipes_1[i].AddRequirement('I00V', 20);
    Recipes_1[i].SetCraftLevel(0);
    //РљРѕСЂРїСѓСЃ "Р‘СѓСЂРѕ"
    i = i + 1;
    Recipes_1[i].SetResultItem('I07K', 0);
    Recipes_1[i].AddRequirement('I037', 0);
    Recipes_1[i].AddRequirement('I00V', 20);
    Recipes_1[i].SetCraftLevel(0);
    //2 РїР°СЂС‹ С€Р°РіР°С‚РµР»РµР№
    i = i + 1;
    Recipes_1[i].SetResultItem('I07L', 0);
    Recipes_1[i].AddRequirement('I00A', 0);
    Recipes_1[i].AddRequirement('I00A', 0);
    Recipes_1[i].AddRequirement('I00U', 10);
    Recipes_1[i].AddRequirement('I00V', 10);
    Recipes_1[i].SetCraftLevel(0);
    //РќР°Р±РѕСЂ РґРµС‚Р°Р»РµР№
    i = i + 1;
    Recipes_1[i].SetResultItem('I07M', 0);
    Recipes_1[i].AddRequirement('I07H', 0);
    Recipes_1[i].AddRequirement('I07I', 0);
    Recipes_1[i].AddRequirement('I07J', 0);
    Recipes_1[i].AddRequirement('I07K', 0);
    Recipes_1[i].AddRequirement('I07L', 0);
    Recipes_1[i].SetCraftLevel(0);
    //Р“СЂРёР±РЅР°СЏ РЅР°СЃС‚РѕР№РєР°
    i = i + 1;
    Recipes_1[i].SetResultItem('I024', 1);
    Recipes_1[i].AddRequirement('I01X', 1);
    Recipes_1[i].AddRequirement('I007', 1);
    Recipes_1[i].SetCraftLevel(0);
    //Р“СЂРёР±РЅРѕР№ Р±СѓР»СЊРѕРЅ
    i = i + 1;
    Recipes_1[i].SetResultItem('I02T', 5);
    Recipes_1[i].AddRequirement('I024', 1);
    Recipes_1[i].AddRequirement('I004', 0);
    Recipes_1[i].SetCraftLevel(0);
    //Р“СЂРёР±РЅРѕР№ СЃРїРёСЂС‚
    i = i + 1;
    Recipes_1[i].SetResultItem('I036', 1);
    Recipes_1[i].AddRequirement('I01X', 1);
    Recipes_1[i].AddRequirement('I008', 1);
    Recipes_1[i].SetCraftLevel(0);
    //Р“СЂРёР±РЅР°СЏ СЃР°РјРѕРіРѕРЅРєР°
    i = i + 1;
    Recipes_1[i].SetResultItem('I037', 5);
    Recipes_1[i].AddRequirement('I036', 1);
    Recipes_1[i].AddRequirement('I004', 0);
    Recipes_1[i].SetCraftLevel(0);
    //РЎР»Р°Р±С‹Р№ СЌРЅРµСЂРіРµС‚РёРє
    i = i + 1;
    Recipes_1[i].SetResultItem('I06Y', 0);
    Recipes_1[i].AddRequirement('I008', 1);
    Recipes_1[i].AddRequirement('I007', 1);
    Recipes_1[i].AddRequirement('I06W', 0);
    Recipes_1[i].SetCraftLevel(0);
    //Р­РЅРµСЂРіРµС‚РёРє
    i = i + 1;
    Recipes_1[i].SetResultItem('I06Z', 0);
    Recipes_1[i].AddRequirement('I024', 1);
    Recipes_1[i].AddRequirement('I036', 1);
    Recipes_1[i].AddRequirement('I06W', 0);
    Recipes_1[i].SetCraftLevel(0);
    //РЎРёР»СЊРЅС‹Р№ СЌРЅРµСЂРіРµС‚РёРє
    i = i + 1;
    Recipes_1[i].SetResultItem('I070', 0);
    Recipes_1[i].AddRequirement('I02T', 1);
    Recipes_1[i].AddRequirement('I037', 1);
    Recipes_1[i].AddRequirement('I06W', 0);
    Recipes_1[i].SetCraftLevel(0);
    //Р СѓР±РёРЅРѕРІРѕРµ РєРѕР»РµС‡РєРѕ
    i = i + 1;
    Recipes_1[i].SetResultItem('I053', 0);
    Recipes_1[i].AddRequirement('I04Z', 1);
    Recipes_1[i].AddRequirement('I00W', 5);
    Recipes_1[i].SetCraftLevel(0);
    //Р СѓР±РёРЅРѕРІРѕРµ РєРѕР»СЊС†Рѕ
    i = i + 1;
    Recipes_1[i].SetResultItem('I055', 0);
    Recipes_1[i].AddRequirement('I053', 0);
    Recipes_1[i].AddRequirement('I00U', 5);
    Recipes_1[i].SetCraftLevel(0);
    //Р СѓР±РёРЅРѕРІС‹Р№ РїРµСЂСЃС‚РµРЅСЊ
    i = i + 1;
    Recipes_1[i].SetResultItem('I056', 0);
    Recipes_1[i].AddRequirement('I055', 0);
    Recipes_1[i].AddRequirement('I00T', 5);
    Recipes_1[i].SetCraftLevel(0);
    //РЎР°РїС„РёСЂРѕРІРѕРµ РєРѕР»РµС‡РєРѕ
    i = i + 1;
    Recipes_1[i].SetResultItem('I057', 0);
    Recipes_1[i].AddRequirement('I050', 1);
    Recipes_1[i].AddRequirement('I00W', 5);
    Recipes_1[i].SetCraftLevel(0);
    //РЎР°РїС„РёСЂРѕРІРѕРµ РєРѕР»СЊС†Рѕ
    i = i + 1;
    Recipes_1[i].SetResultItem('I054', 0);
    Recipes_1[i].AddRequirement('I057', 0);
    Recipes_1[i].AddRequirement('I00U', 5);
    Recipes_1[i].SetCraftLevel(0);
    //РЎР°РїС„РёСЂРѕРІС‹Р№ РїРµСЂСЃС‚РµРЅСЊ
    i = i + 1;
    Recipes_1[i].SetResultItem('I058', 0);
    Recipes_1[i].AddRequirement('I054', 0);
    Recipes_1[i].AddRequirement('I00T', 5);
    Recipes_1[i].SetCraftLevel(0);
    //РђР»РјР°Р·РЅРѕРµ РєРѕР»РµС‡РєРѕ
    i = i + 1;
    Recipes_1[i].SetResultItem('I05I', 0);
    Recipes_1[i].AddRequirement('I04X', 1);
    Recipes_1[i].AddRequirement('I00W', 5);
    Recipes_1[i].SetCraftLevel(0);
    //РђР»РјР°Р·РЅРѕРµ РєРѕР»СЊС†Рѕ
    i = i + 1;
    Recipes_1[i].SetResultItem('I05J', 0);
    Recipes_1[i].AddRequirement('I05I', 0);
    Recipes_1[i].AddRequirement('I00U', 5);
    Recipes_1[i].SetCraftLevel(0);
    //РђР»РјР°Р·РЅС‹Р№ РїРµСЂСЃС‚РµРЅСЊ
    i = i + 1;
    Recipes_1[i].SetResultItem('I05K', 0);
    Recipes_1[i].AddRequirement('I05J', 0);
    Recipes_1[i].AddRequirement('I00T', 5);
    Recipes_1[i].SetCraftLevel(0);
    //РђРјРµС‚РёСЃС‚РѕРІРѕРµ РєРѕР»РµС‡РєРѕ
    i = i + 1;
    Recipes_1[i].SetResultItem('I05C', 0);
    Recipes_1[i].AddRequirement('I052', 1);
    Recipes_1[i].AddRequirement('I00W', 5);
    Recipes_1[i].SetCraftLevel(0);
    //РђРјРµС‚РёСЃС‚РѕРІРѕРµ РєРѕР»СЊС†Рѕ
    i = i + 1;
    Recipes_1[i].SetResultItem('I05D', 0);
    Recipes_1[i].AddRequirement('I05C', 0);
    Recipes_1[i].AddRequirement('I00U', 5);
    Recipes_1[i].SetCraftLevel(0);
    //РђРјРµС‚РёСЃС‚РѕРІС‹Р№ РїРµСЂСЃС‚РµРЅСЊ
    i = i + 1;
    Recipes_1[i].SetResultItem('I05E', 0);
    Recipes_1[i].AddRequirement('I05D', 0);
    Recipes_1[i].AddRequirement('I00T', 5);
    Recipes_1[i].SetCraftLevel(0);
    //РўРѕРїР°Р·РѕРІРѕРµ РєРѕР»РµС‡РєРѕ
    i = i + 1;
    Recipes_1[i].SetResultItem('I05F', 0);
    Recipes_1[i].AddRequirement('I051', 1);
    Recipes_1[i].AddRequirement('I00W', 5);
    Recipes_1[i].SetCraftLevel(0);
    //РўРѕРїР°Р·РѕРІРѕРµ РєРѕР»СЊС†Рѕ
    i = i + 1;
    Recipes_1[i].SetResultItem('I05G', 0);
    Recipes_1[i].AddRequirement('I05F', 0);
    Recipes_1[i].AddRequirement('I00U', 5);
    Recipes_1[i].SetCraftLevel(0);
    //РўРѕРїР°Р·РѕРІС‹Р№ РїРµСЂСЃС‚РµРЅСЊ
    i = i + 1;
    Recipes_1[i].SetResultItem('I05H', 0);
    Recipes_1[i].AddRequirement('I05G', 0);
    Recipes_1[i].AddRequirement('I00T', 5);
    Recipes_1[i].SetCraftLevel(0);
    //РР·СѓРјСЂСѓРґРЅРѕРµ РєРѕР»РµС‡РєРѕ
    i = i + 1;
    Recipes_1[i].SetResultItem('I059', 0);
    Recipes_1[i].AddRequirement('I04Y', 1);
    Recipes_1[i].AddRequirement('I00W', 5);
    Recipes_1[i].SetCraftLevel(0);
    //РР·СѓРјСЂСѓРґРЅРѕРµ РєРѕР»СЊС†Рѕ
    i = i + 1;
    Recipes_1[i].SetResultItem('I05A', 0);
    Recipes_1[i].AddRequirement('I059', 0);
    Recipes_1[i].AddRequirement('I00U', 5);
    Recipes_1[i].SetCraftLevel(0);
    //РР·СѓРјСЂСѓРґРЅС‹Р№ РїРµСЂСЃС‚РµРЅСЊ
    i = i + 1;
    Recipes_1[i].SetResultItem('I05B', 0);
    Recipes_1[i].AddRequirement('I05A', 0);
    Recipes_1[i].AddRequirement('I00T', 5);
    Recipes_1[i].SetCraftLevel(0);
    //Р Р°РґСѓР¶РЅС‹Р№ РєР°РјРµРЅСЊ
    i = i + 1;
    Recipes_1[i].SetResultItem('I08X', 0);
    Recipes_1[i].AddRequirement('I08W', 0);
    Recipes_1[i].AddRequirement('I02Y', 0);
    Recipes_1[i].SetCraftLevel(1);
    //Р Р°РґСѓР¶РЅС‹Р№ СЃРєРµР»РµС‚
    i = i + 1;
    Recipes_1[i].SetResultItem('I08Y', 0);
    Recipes_1[i].AddRequirement('I08X', 0);
    Recipes_1[i].AddRequirement('I02I', 0);
    Recipes_1[i].AddRequirement('I02I', 0);
    Recipes_1[i].AddRequirement('I0OB', 10);
    Recipes_1[i].SetCraftLevel(1);
    //РњСѓР»СЊС‚РёС†РІРµС‚
    i = i + 1;
    Recipes_1[i].SetResultItem('I08W', 0);
    Recipes_1[i].AddRequirement('I04Z', 1);
    Recipes_1[i].AddRequirement('I050', 1);
    Recipes_1[i].AddRequirement('I04X', 1);
    Recipes_1[i].AddRequirement('I052', 1);
    Recipes_1[i].AddRequirement('I051', 1);
    Recipes_1[i].AddRequirement('I04Y', 1);
    Recipes_1[i].SetCraftLevel(0);

    // РЈСЂРѕРІРµРЅСЊ 1 вЂ” РђСЂР°С…РЅРёРґСЃРєРёРµ РїСЂРµРґРјРµС‚С‹
    //Р‘СЂРѕРЅРµР¶РёР»РµС‚ СЃ Р»Р°РїРѕР№ Р°СЂР°С…РЅРёРґР°
    i = i + 1;
    Recipes_1[i].SetResultItem('I00Q', 0);
    Recipes_1[i].AddRequirement('I00O', 0);
    Recipes_1[i].AddRequirement('I009', 0);
    Recipes_1[i].AddRequirement('I00H', 0);
    Recipes_1[i].AddRequirement('I00L', 0);
    Recipes_1[i].SetCraftLevel(1);
    //Р‘СЂРѕРЅРµР¶РёР»РµС‚ СЃ РіРѕР»РѕРІРѕР№ Р°СЂР°С…РЅРёРґР°
    i = i + 1;
    Recipes_1[i].SetResultItem('I00R', 0);
    Recipes_1[i].AddRequirement('I00N', 0);
    Recipes_1[i].AddRequirement('I009', 0);
    Recipes_1[i].AddRequirement('I00J', 0);
    Recipes_1[i].AddRequirement('I00M', 0);
    Recipes_1[i].SetCraftLevel(1);
    //Р‘СЂРѕРЅРµР¶РёР»РµС‚ СЃ РєР»РµС€РЅРµР№ Р°СЂР°С…РЅРёРґР°
    i = i + 1;
    Recipes_1[i].SetResultItem('I00S', 0);
    Recipes_1[i].AddRequirement('I00P', 0);
    Recipes_1[i].AddRequirement('I009', 0);
    Recipes_1[i].AddRequirement('I00I', 0);
    Recipes_1[i].AddRequirement('I00K', 0);
    Recipes_1[i].SetCraftLevel(1);
    //РђСЂР°С…РЅРёРґСЃРєРёРµ РїРµСЂС‡Р°С‚РєРё
    i = i + 1;
    Recipes_1[i].SetResultItem('I01Z', 0);
    Recipes_1[i].AddRequirement('I00P', 0);
    Recipes_1[i].AddRequirement('I00B', 0);
    Recipes_1[i].AddRequirement('I0O8', 7);
    Recipes_1[i].SetCraftLevel(1);
    //РђСЂР°С…РЅРёРґСЃРєРёРµ СЃР°РїРѕРіРё
    i = i + 1;
    Recipes_1[i].SetResultItem('I020', 0);
    Recipes_1[i].AddRequirement('I00O', 0);
    Recipes_1[i].AddRequirement('I00A', 0);
    Recipes_1[i].AddRequirement('I0O8', 7);
    Recipes_1[i].SetCraftLevel(1);
    //РђСЂР°С…РЅРёРґСЃРєРёР№ С€Р»РµРј
    i = i + 1;
    Recipes_1[i].SetResultItem('I021', 0);
    Recipes_1[i].AddRequirement('I00N', 0);
    Recipes_1[i].AddRequirement('I004', 0);
    Recipes_1[i].AddRequirement('I0O8', 7);
    Recipes_1[i].SetCraftLevel(1);
    //РђРјСѓР»РµС‚ РёР· РіРѕР»РѕРІС‹ Р°СЂР°С…РЅРёРґР°
    i = i + 1;
    Recipes_1[i].SetResultItem('I0OJ', 0);
    Recipes_1[i].AddRequirement('I00N', 0);
    Recipes_1[i].AddRequirement('I0OG', 0);
    Recipes_1[i].AddRequirement('I08W', 0);
    Recipes_1[i].SetCraftLevel(1);
    //РљРѕР»СЊС†Рѕ РёР· РєР»РµС€РЅРё Р°СЂР°С…РЅРёРґР°
    i = i + 1;
    Recipes_1[i].SetResultItem('I0OK', 0);
    Recipes_1[i].AddRequirement('I00P', 0);
    Recipes_1[i].AddRequirement('I0OH', 0);
    Recipes_1[i].AddRequirement('I0OB', 10);
    Recipes_1[i].SetCraftLevel(1);
    //РўР°Р»РёСЃРјР°РЅ РёР· Р»Р°РїС‹ Р°СЂР°С…РЅРёРґР°
    i = i + 1;
    Recipes_1[i].SetResultItem('I0OL', 0);
    Recipes_1[i].AddRequirement('I00O', 0);
    Recipes_1[i].AddRequirement('I0OI', 0);
    Recipes_1[i].AddRequirement('I0D1', 0);
    Recipes_1[i].AddRequirement('I0D1', 0);
    Recipes_1[i].SetCraftLevel(1);
    //РђСЂР°С…РЅРёРґСЃРєРёР№ РґРѕСЃРїРµС…
    i = i + 1;
    Recipes_1[i].SetResultItem('I023', 0);
    Recipes_1[i].AddRequirement('I00Q', 0);
    Recipes_1[i].AddRequirement('I0O8', 7);
    Recipes_1[i].AddRequirement('I0OB', 10);
    Recipes_1[i].SetCraftLevel(1);
    //РљР°РјРµРЅРЅС‹Р№ РґРѕСЃРїРµС…
    i = i + 1;
    Recipes_1[i].SetResultItem('I0CT', 0);
    Recipes_1[i].AddRequirement('I00S', 0);
    Recipes_1[i].AddRequirement('I0O8', 7);
    Recipes_1[i].AddRequirement('I0OB', 10);
    Recipes_1[i].SetCraftLevel(1);
    //Р”РѕСЃРїРµС… РџР°СѓС‡СЊРµРіРѕ Р–СЂРµС†Р°
    i = i + 1;
    Recipes_1[i].SetResultItem('I0GA', 0);
    Recipes_1[i].AddRequirement('I00R', 0);
    Recipes_1[i].AddRequirement('I0O8', 7);
    Recipes_1[i].AddRequirement('I0OB', 10);
    Recipes_1[i].SetCraftLevel(1);
    //Р РµР»РёРєРІР°СЂРёР№ РђСЂР°С…РЅРёРґРѕРІ(1) (Recipes_2)
    j = j + 1;
    Recipes_2[j].SetResultItem('I0OP', 0);
    Recipes_2[j].AddRequirement('I0OJ', 0);
    Recipes_2[j].AddRequirement('I0OK', 0);
    Recipes_2[j].AddRequirement('I0OL', 0);
    Recipes_2[j].AddRequirement('I0O9', 2);
    Recipes_2[j].SetCraftLevel(1);
    //РЎРµС‚ РђСЂР°С…РЅРёРґР° (Recipes_2)
    j = j + 1;
    Recipes_2[j].SetResultItem('I022', 0);
    Recipes_2[j].AddRequirement('I01Z', 0);
    Recipes_2[j].AddRequirement('I020', 0);
    Recipes_2[j].AddRequirement('I021', 0);
    Recipes_2[j].AddRequirement('I0O9', 2);
    Recipes_2[j].SetCraftLevel(1);

    // РЈСЂРѕРІРµРЅСЊ 2
    //РљРѕР»СЊС†Рѕ СЂР°Р±РѕРІР»Р°РґРµР»СЊС†Р°
    i = i + 1;
    Recipes_1[i].SetResultItem('I0P0', 0);
    Recipes_1[i].AddRequirement('I0OK', 0);
    Recipes_1[i].AddRequirement('I0OY', 0);
    Recipes_1[i].AddRequirement('I00T', 20);
    Recipes_1[i].AddRequirement('I0OA', 7);
    Recipes_1[i].SetCraftLevel(2);
    //Р РµР»РёРєРІР°СЂРёР№ РђСЂР°С…РЅРёРґРѕРІ(2) (Recipes_20)
    Recipes_20[0].SetResultItem('I0P1', 0);
    Recipes_20[0].AddRequirement('I0OP', 0);
    Recipes_20[0].AddRequirement('I0P0', 0);
    Recipes_20[0].SetCraftLevel(2);
    //Р РµР»РёРєРІР°СЂРёР№ Р Р°Р±РѕРІР»Р°РґРµР»СЊС†Р°(2) (Recipes_20)
    Recipes_20[1].SetResultItem('I0P2', 0);
    Recipes_20[1].AddRequirement('I0OP', 0);
    Recipes_20[1].AddRequirement('I0P0', 0);
    Recipes_20[1].SetCraftLevel(2);
    //Р“СЂРѕР·РЅС‹Р№ РђСЂР°С…РЅРёРґСЃРєРёР№ РґРѕСЃРїРµС… (Recipes_2)
    j = j + 1;
    Recipes_2[j].SetResultItem('I0OM', 0);
    Recipes_2[j].AddRequirement('I023', 0);
    Recipes_2[j].AddRequirement('I0OE', 2);
    Recipes_2[j].SetCraftLevel(2);
    //Р“СЂРѕР·РЅС‹Р№ РљР°РјРµРЅРЅС‹Р№ РґРѕСЃРїРµС… (Recipes_2)
    j = j + 1;
    Recipes_2[j].SetResultItem('I0ON', 0);
    Recipes_2[j].AddRequirement('I0CT', 0);
    Recipes_2[j].AddRequirement('I0OE', 2);
    Recipes_2[j].SetCraftLevel(2);
    //Р“СЂРѕР·РЅС‹Р№ Р”РѕСЃРїРµС… РџР°СѓС‡СЊРµРіРѕ Р–СЂРµС†Р° (Recipes_2)
    j = j + 1;
    Recipes_2[j].SetResultItem('I0OO', 0);
    Recipes_2[j].AddRequirement('I0GA', 0);
    Recipes_2[j].AddRequirement('I0OE', 2);
    Recipes_2[j].SetCraftLevel(2);
    //РђСЂР°С…РЅРёРґСЃРєРёР№ РєР°СЃС‚РµС‚
    i = i + 1;
    Recipes_1[i].SetResultItem('I0FF', 0);
    Recipes_1[i].AddRequirement('I00P', 0);
    Recipes_1[i].AddRequirement('I02P', 0);
    Recipes_1[i].AddRequirement('I0OA', 7);
    Recipes_1[i].SetCraftLevel(2);
    //РЎРµС‚ Р Р°Р±РѕРІР»Р°РґРµР»СЊС†Р° (Recipes_2)
    j = j + 1;
    Recipes_2[j].SetResultItem('I02S', 0);
    Recipes_2[j].AddRequirement('I02R', 0);
    Recipes_2[j].AddRequirement('I0OY', 0);
    Recipes_2[j].AddRequirement('I02P', 0);
    Recipes_2[j].AddRequirement('I0OE', 2);
    Recipes_2[j].SetCraftLevel(2);
    //Р—Р°Р¶РёРіР°Р»РєР°
    i = i + 1;
    Recipes_1[i].SetResultItem('I0BB', 0);
    Recipes_1[i].AddRequirement('I02R', 0);
    Recipes_1[i].AddRequirement('I0OZ', 0);
    Recipes_1[i].AddRequirement('I0OB', 10);
    Recipes_1[i].SetCraftLevel(2);
    //Р‘СѓРј-РЎС‚РёРє Рђ-2
    i = i + 1;
    Recipes_1[i].SetResultItem('I0BC', 0);
    Recipes_1[i].AddRequirement('I0OZ', 0);
    Recipes_1[i].AddRequirement('I0OY', 0);
    Recipes_1[i].AddRequirement('I01N', 0);
    Recipes_1[i].AddRequirement('I0OB', 10);
    Recipes_1[i].SetCraftLevel(2);
    //РњРµРґ-РџСЂРѕС‚РµР·
    i = i + 1;
    Recipes_1[i].SetResultItem('I0BG', 0);
    Recipes_1[i].AddRequirement('I0OF', 0);
    Recipes_1[i].AddRequirement('I01O', 0);
    Recipes_1[i].AddRequirement('I02P', 0);
    Recipes_1[i].AddRequirement('I0OB', 10);
    Recipes_1[i].SetCraftLevel(2);
    //РњСѓР»СЊС‚РёРєРёСЂРєР°
    i = i + 1;
    Recipes_1[i].SetResultItem('I0P3', 0);
    Recipes_1[i].AddRequirement('I02Q', 0);
    Recipes_1[i].AddRequirement('I08W', 0);
    Recipes_1[i].AddRequirement('I08W', 0);
    Recipes_1[i].AddRequirement('I0OB', 10);
    Recipes_1[i].SetCraftLevel(2);
    //РџРѕС‚РЅР°СЏ РіСЂР°РЅР°С‚Р°
    i = i + 1;
    Recipes_1[i].SetResultItem('I02W', 0);
    Recipes_1[i].AddRequirement('I02Y', 0);
    Recipes_1[i].AddRequirement('I00O', 0);
    Recipes_1[i].AddRequirement('I0OZ', 0);
    Recipes_1[i].AddRequirement('I0OB', 10);
    Recipes_1[i].SetCraftLevel(2);
    //РљРѕР»СЋС‡РёР№ С€Р»РµРј
    i = i + 1;
    Recipes_1[i].SetResultItem('I0P4', 0);
    Recipes_1[i].AddRequirement('I0OF', 0);
    Recipes_1[i].AddRequirement('I0OY', 0);
    Recipes_1[i].AddRequirement('I01B', 0);
    Recipes_1[i].AddRequirement('I0OB', 10);
    Recipes_1[i].SetCraftLevel(2);
    //РЎРЅР°Р№РїРµСЂРєР° "РЎРєРѕСЂРїРёРѕРЅ"
    i = i + 1;
    Recipes_1[i].SetResultItem('I0P5', 0);
    Recipes_1[i].AddRequirement('I0OF', 0);
    Recipes_1[i].AddRequirement('I02P', 0);
    Recipes_1[i].AddRequirement('I01P', 0);
    Recipes_1[i].AddRequirement('I0OB', 10);
    Recipes_1[i].SetCraftLevel(2);
    //Р СѓС‡РЅРѕР№ Р°РєСЃРµР»РµСЂР°С‚РѕСЂ
    i = i + 1;
    Recipes_1[i].SetResultItem('I04H', 0);
    Recipes_1[i].AddRequirement('I0OF', 0);
    Recipes_1[i].AddRequirement('I02P', 0);
    Recipes_1[i].AddRequirement('I01R', 0);
    Recipes_1[i].AddRequirement('I0OB', 10);
    Recipes_1[i].SetCraftLevel(2);
    //Р›Р°РјРїР° РёР· С‡РµСЂРµРїР°
    i = i + 1;
    Recipes_1[i].SetResultItem('I0FG', 0);
    Recipes_1[i].AddRequirement('I00N', 0);
    Recipes_1[i].AddRequirement('I02R', 0);
    Recipes_1[i].AddRequirement('I01B', 0);
    Recipes_1[i].AddRequirement('I0OB', 10);
    Recipes_1[i].SetCraftLevel(2);
    //РЎРІСЏС‰РµРЅРЅС‹Р№ СЃРІРµС‚
    i = i + 1;
    Recipes_1[i].SetResultItem('I0GX', 0);
    Recipes_1[i].AddRequirement('I0FG', 0);
    Recipes_1[i].AddRequirement('I0D3', 0);
    Recipes_1[i].AddRequirement('I0OV', 0);
    Recipes_1[i].AddRequirement('I0OA', 7);
    Recipes_1[i].SetCraftLevel(2);
    //РџРµСЂС‡Р°С‚РєР° Р’Р»Р°СЃС‚Рё
    i = i + 1;
    Recipes_1[i].SetResultItem('I0BE', 0);
    Recipes_1[i].AddRequirement('I02P', 0);
    Recipes_1[i].AddRequirement('I01Z', 0);
    Recipes_1[i].AddRequirement('I05K', 0);
    Recipes_1[i].AddRequirement('I05E', 0);
    Recipes_1[i].AddRequirement('I0OA', 7);
    Recipes_1[i].SetCraftLevel(2);

    // РЈСЂРѕРІРµРЅСЊ 3
    //РђРјСѓР»РµС‚ РЎС‚СЂР°Р¶Р° (Recipes_2)
    j = j + 1;
    Recipes_2[j].SetResultItem('I0P7', 0);
    Recipes_2[j].AddRequirement('I0OJ', 0);
    Recipes_2[j].AddRequirement('I00X', 0);
    Recipes_2[j].AddRequirement('I0FG', 0);
    Recipes_2[j].AddRequirement('I0OT', 7);
    Recipes_2[j].SetCraftLevel(3);
    //Р РµР»РёРєРІР°СЂРёР№ РђСЂР°С…РЅРёРґРѕРІ(3) (Recipes_20)
    Recipes_20[2].SetResultItem('I0PC', 0);
    Recipes_20[2].AddRequirement('I0P1', 0);
    Recipes_20[2].AddRequirement('I0P7', 0);
    Recipes_20[2].SetCraftLevel(3);
    Recipes_20[3].SetResultItem('I0PC', 0);
    Recipes_20[3].AddRequirement('I0P2', 0);
    Recipes_20[3].AddRequirement('I0P7', 0);
    Recipes_20[3].SetCraftLevel(3);
    Recipes_20[4].SetResultItem('I0PD', 0);
    Recipes_20[4].AddRequirement('I0P1', 0);
    Recipes_20[4].AddRequirement('I0P7', 0);
    Recipes_20[4].SetCraftLevel(3);
    Recipes_20[5].SetResultItem('I0PD', 0);
    Recipes_20[5].AddRequirement('I0P2', 0);
    Recipes_20[5].AddRequirement('I0P7', 0);
    Recipes_20[5].SetCraftLevel(3);
    Recipes_20[6].SetResultItem('I0PE', 0);
    Recipes_20[6].AddRequirement('I0P1', 0);
    Recipes_20[6].AddRequirement('I0P7', 0);
    Recipes_20[6].SetCraftLevel(3);
    Recipes_20[7].SetResultItem('I0PE', 0);
    Recipes_20[7].AddRequirement('I0P2', 0);
    Recipes_20[7].AddRequirement('I0P7', 0);
    Recipes_20[7].SetCraftLevel(3);
    //РЎРµС‚ РЎС‚СЂР°Р¶Р° (Recipes_2)
    j = j + 1;
    Recipes_2[j].SetResultItem('I011', 0);
    Recipes_2[j].AddRequirement('I0P6', 0);
    Recipes_2[j].AddRequirement('I00Z', 0);
    Recipes_2[j].AddRequirement('I00X', 0);
    Recipes_2[j].AddRequirement('I010', 0);
    Recipes_2[j].AddRequirement('I0OU', 2);
    Recipes_2[j].SetCraftLevel(3);
    //Р‘СЂРѕРЅСЏ РҐСЂР°РЅРёС‚РµР»СЏ (Recipes_2)
    j = j + 1;
    Recipes_2[j].SetResultItem('I0P8', 0);
    Recipes_2[j].AddRequirement('I00Z', 0);
    Recipes_2[j].AddRequirement('I00X', 0);
    Recipes_2[j].AddRequirement('I0O0', 20);
    Recipes_2[j].AddRequirement('I0OT', 7);
    Recipes_2[j].SetCraftLevel(3);
    //РЎС‚Р°С‚РёС‡РµСЃРєРёР№ Р±СЂР°СЃР»РµС‚ (Recipes_2)
    j = j + 1;
    Recipes_2[j].SetResultItem('I0P9', 0);
    Recipes_2[j].AddRequirement('I0P6', 0);
    Recipes_2[j].AddRequirement('I0OY', 0);
    Recipes_2[j].AddRequirement('I0O4', 20);
    Recipes_2[j].AddRequirement('I0OT', 7);
    Recipes_2[j].SetCraftLevel(3);
    //РЎР°РїРѕРіРё РїСЂРёР·СЂР°РєР° (Recipes_2)
    j = j + 1;
    Recipes_2[j].SetResultItem('I0PA', 0);
    Recipes_2[j].AddRequirement('I010', 0);
    Recipes_2[j].AddRequirement('I020', 0);
    Recipes_2[j].AddRequirement('I0OD', 20);
    Recipes_2[j].AddRequirement('I0OT', 7);
    Recipes_2[j].SetCraftLevel(3);
    //Р’РѕСЃРєРѕРІРѕР№ РґРѕСЃРїРµС… (Recipes_2)
    j = j + 1;
    Recipes_2[j].SetResultItem('I0PB', 0);
    Recipes_2[j].AddRequirement('I00Z', 0);
    Recipes_2[j].AddRequirement('I02R', 0);
    Recipes_2[j].AddRequirement('I0O0', 20);
    Recipes_2[j].AddRequirement('I0OT', 7);
    Recipes_2[j].SetCraftLevel(3);
    //РЈСЃРёР»РёС‚РµР»СЊ (Recipes_2)
    j = j + 1;
    Recipes_2[j].SetResultItem('I032', 0);
    Recipes_2[j].AddRequirement('I0P6', 0);
    Recipes_2[j].AddRequirement('I0FF', 0);
    Recipes_2[j].AddRequirement('I0NW', 20);
    Recipes_2[j].AddRequirement('I0OT', 7);
    Recipes_2[j].SetCraftLevel(3);
    //РћР±РѕРіРѕС‰С‘РЅРЅС‹Р№ РђСЂР°С…РЅРёРґСЃРєРёР№ СЃРїР»Р°РІ (Recipes_5)
    k = k + 1;
    Recipes_5[k].SetResultItem('I0OC', 0);
    Recipes_5[k].AddRequirement('I00O', 0);
    Recipes_5[k].AddRequirement('I0OB', 30);
    Recipes_5[k].AddRequirement('I0NW', 10);
    Recipes_5[k].AddRequirement('I0O0', 10);
    Recipes_5[k].AddRequirement('I0OD', 10);
    Recipes_5[k].AddRequirement('I0O4', 10);
    Recipes_5[k].SetCraftLevel(3);
    k = k + 1;
    Recipes_5[k].SetResultItem('I0OC', 0);
    Recipes_5[k].AddRequirement('I00N', 0);
    Recipes_5[k].AddRequirement('I0OB', 30);
    Recipes_5[k].AddRequirement('I0NW', 10);
    Recipes_5[k].AddRequirement('I0O0', 10);
    Recipes_5[k].AddRequirement('I0OD', 10);
    Recipes_5[k].AddRequirement('I0O4', 10);
    Recipes_5[k].SetCraftLevel(3);
    k = k + 1;
    Recipes_5[k].SetResultItem('I0OC', 0);
    Recipes_5[k].AddRequirement('I00P', 0);
    Recipes_5[k].AddRequirement('I0OB', 30);
    Recipes_5[k].AddRequirement('I0NW', 10);
    Recipes_5[k].AddRequirement('I0O0', 10);
    Recipes_5[k].AddRequirement('I0OD', 10);
    Recipes_5[k].AddRequirement('I0O4', 10);
    Recipes_5[k].SetCraftLevel(3);
    //Р—РµР»СЊРµ Р·Р°С‰РёС‚С‹ (Recipes_5)
    k = k + 1;
    Recipes_5[k].SetResultItem('I076', 0);
    Recipes_5[k].AddRequirement('I0OV', 0);
    Recipes_5[k].AddRequirement('I0O0', 10);
    Recipes_5[k].AddRequirement('I051', 5);
    Recipes_5[k].SetCraftLevel(3);
    //Р—РµР»СЊРµ Р»РѕРІРєРѕСЃС‚Рё (Recipes_5)
    k = k + 1;
    Recipes_5[k].SetResultItem('I077', 0);
    Recipes_5[k].AddRequirement('I0OV', 0);
    Recipes_5[k].AddRequirement('I0O4', 10);
    Recipes_5[k].AddRequirement('I04X', 5);
    Recipes_5[k].SetCraftLevel(3);
    //Р—РµР»СЊРµ СЃРєРѕСЂРѕСЃС‚Рё (Recipes_5)
    k = k + 1;
    Recipes_5[k].SetResultItem('I0PF', 0);
    Recipes_5[k].AddRequirement('I0OV', 0);
    Recipes_5[k].AddRequirement('I0O4', 10);
    Recipes_5[k].AddRequirement('I052', 5);
    Recipes_5[k].SetCraftLevel(3);
    //Р—РµР»СЊРµ Р¶РёР·РЅРё (Recipes_5)
    k = k + 1;
    Recipes_5[k].SetResultItem('I0PG', 0);
    Recipes_5[k].AddRequirement('I0OV', 0);
    Recipes_5[k].AddRequirement('I0OD', 10);
    Recipes_5[k].AddRequirement('I04Z', 5);
    Recipes_5[k].SetCraftLevel(3);
    //Р—РµР»СЊРµ РёРЅС‚РµР»Р»РµРєС‚Р° (Recipes_5)
    k = k + 1;
    Recipes_5[k].SetResultItem('I072', 0);
    Recipes_5[k].AddRequirement('I0OV', 0);
    Recipes_5[k].AddRequirement('I0NW', 10);
    Recipes_5[k].AddRequirement('I050', 5);
    Recipes_5[k].SetCraftLevel(3);
    //Р—РµР»СЊРµ СѓСЂРѕРЅР° (Recipes_5)
    k = k + 1;
    Recipes_5[k].SetResultItem('I078', 0);
    Recipes_5[k].AddRequirement('I0OV', 0);
    Recipes_5[k].AddRequirement('I0OD', 10);
    Recipes_5[k].AddRequirement('I052', 5);
    Recipes_5[k].SetCraftLevel(3);
    //Р—РµР»СЊРµ СЃРёР»С‹ (Recipes_5)
    k = k + 1;
    Recipes_5[k].SetResultItem('I073', 0);
    Recipes_5[k].AddRequirement('I0OV', 0);
    Recipes_5[k].AddRequirement('I0O0', 10);
    Recipes_5[k].AddRequirement('I04Z', 5);
    Recipes_5[k].SetCraftLevel(3);
    //Р—РµР»СЊРµ РјР°РіРёРё (Recipes_5)
    k = k + 1;
    Recipes_5[k].SetResultItem('I0LA', 0);
    Recipes_5[k].AddRequirement('I0OV', 0);
    Recipes_5[k].AddRequirement('I0NW', 10);
    Recipes_5[k].AddRequirement('I04X', 5);
    Recipes_5[k].SetCraftLevel(3);
    //РљР°СЂР°С‚РµР»СЊ (Recipes_2)
    j = j + 1;
    Recipes_2[j].SetResultItem('I08Z', 0);
    Recipes_2[j].AddRequirement('I03V', 0);
    Recipes_2[j].AddRequirement('I029', 0);
    Recipes_2[j].AddRequirement('I097', 0);
    Recipes_2[j].AddRequirement('I0OC', 0);
    Recipes_2[j].AddRequirement('I076', 0);
    Recipes_2[j].AddRequirement('I0OU', 2);
    Recipes_2[j].SetCraftLevel(3);
    //Р‘РµР·РјРѕР»РІРЅС‹Р№ РїР°Р»Р°С‡ (Recipes_2)
    j = j + 1;
    Recipes_2[j].SetResultItem('I090', 0);
    Recipes_2[j].AddRequirement('I03W', 0);
    Recipes_2[j].AddRequirement('I029', 0);
    Recipes_2[j].AddRequirement('I098', 0);
    Recipes_2[j].AddRequirement('I0OC', 0);
    Recipes_2[j].AddRequirement('I077', 0);
    Recipes_2[j].AddRequirement('I0OU', 2);
    Recipes_2[j].SetCraftLevel(3);
    //Р›СЋС‚С‹Р№ (Recipes_2)
    j = j + 1;
    Recipes_2[j].SetResultItem('I091', 0);
    Recipes_2[j].AddRequirement('I041', 0);
    Recipes_2[j].AddRequirement('I029', 0);
    Recipes_2[j].AddRequirement('I099', 0);
    Recipes_2[j].AddRequirement('I0OC', 0);
    Recipes_2[j].AddRequirement('I0PF', 0);
    Recipes_2[j].AddRequirement('I0OU', 2);
    Recipes_2[j].SetCraftLevel(3);
    //HealPack-3000 (Recipes_2)
    j = j + 1;
    Recipes_2[j].SetResultItem('I092', 0);
    Recipes_2[j].AddRequirement('I03Z', 0);
    Recipes_2[j].AddRequirement('I029', 0);
    Recipes_2[j].AddRequirement('I09A', 0);
    Recipes_2[j].AddRequirement('I0OC', 0);
    Recipes_2[j].AddRequirement('I0PG', 0);
    Recipes_2[j].AddRequirement('I0OU', 2);
    Recipes_2[j].SetCraftLevel(3);
    //РўРµС…-РџСЂРѕС‚РµР· (Recipes_2)
    j = j + 1;
    Recipes_2[j].SetResultItem('I093', 0);
    Recipes_2[j].AddRequirement('I03Y', 0);
    Recipes_2[j].AddRequirement('I029', 0);
    Recipes_2[j].AddRequirement('I09B', 0);
    Recipes_2[j].AddRequirement('I0OC', 0);
    Recipes_2[j].AddRequirement('I072', 0);
    Recipes_2[j].AddRequirement('I0OU', 2);
    Recipes_2[j].SetCraftLevel(3);
    //Р‘СѓРјРµСЂ (Recipes_2)
    j = j + 1;
    Recipes_2[j].SetResultItem('I094', 0);
    Recipes_2[j].AddRequirement('I040', 0);
    Recipes_2[j].AddRequirement('I029', 0);
    Recipes_2[j].AddRequirement('I09C', 0);
    Recipes_2[j].AddRequirement('I0OC', 0);
    Recipes_2[j].AddRequirement('I078', 0);
    Recipes_2[j].AddRequirement('I0OU', 2);
    Recipes_2[j].SetCraftLevel(3);
    //Mr. РџР»Р°РјРµРЅСЊ (Recipes_2)
    j = j + 1;
    Recipes_2[j].SetResultItem('I095', 0);
    Recipes_2[j].AddRequirement('I042', 0);
    Recipes_2[j].AddRequirement('I029', 0);
    Recipes_2[j].AddRequirement('I09D', 0);
    Recipes_2[j].AddRequirement('I0OC', 0);
    Recipes_2[j].AddRequirement('I073', 0);
    Recipes_2[j].AddRequirement('I0OU', 2);
    Recipes_2[j].SetCraftLevel(3);
    //Р‘РѕР»СЊС€РѕР№ РЎСЌРј (Recipes_2)
    j = j + 1;
    Recipes_2[j].SetResultItem('I096', 0);
    Recipes_2[j].AddRequirement('I03X', 0);
    Recipes_2[j].AddRequirement('I029', 0);
    Recipes_2[j].AddRequirement('I09E', 0);
    Recipes_2[j].AddRequirement('I0OC', 0);
    Recipes_2[j].AddRequirement('I0LA', 0);
    Recipes_2[j].AddRequirement('I0OU', 2);
    Recipes_2[j].SetCraftLevel(3);

    // РЈСЂРѕРІРµРЅСЊ 4
    //РњР°РіРёС‡РµСЃРєРѕРµ СѓР»СЊС‚СЂР°-РіРѕСЂСЋС‡РµРµ
    i = i + 1;
    Recipes_1[i].SetResultItem('I03C', 0);
    Recipes_1[i].AddRequirement('I03C', 0);
    Recipes_1[i].AddRequirement('I0OV', 0);
    Recipes_1[i].AddRequirement('I0NX', 10);
    Recipes_1[i].SetCraftLevel(4);
    //РўРѕСЂРёРµРІС‹Р№ РЅРµР№СЂРѕ-РіРµРЅРµСЂР°С‚РѕСЂ
    i = i + 1;
    Recipes_1[i].SetResultItem('I03D', 0);
    Recipes_1[i].AddRequirement('I03A', 0);
    Recipes_1[i].AddRequirement('I048', 1);
    Recipes_1[i].AddRequirement('I0O5', 10);
    Recipes_1[i].AddRequirement('I00U', 10);
    Recipes_1[i].SetCraftLevel(4);
    //Р”РѕСЃРїРµС… РёР· С‚РѕСЂРёРµРІРѕР№ РіСѓСЃРµРЅРёС†С‹
    i = i + 1;
    Recipes_1[i].SetResultItem('I03E', 0);
    Recipes_1[i].AddRequirement('I03B', 0);
    Recipes_1[i].AddRequirement('I02H', 0);
    Recipes_1[i].AddRequirement('I0OQ', 10);
    Recipes_1[i].AddRequirement('I00U', 10);
    Recipes_1[i].SetCraftLevel(4);
    //РђСЂРєР°РЅРёС‚РѕРІС‹Р№ РєРѕРІС€-С€Р»РµРј
    i = i + 1;
    Recipes_1[i].SetResultItem('I0PN', 0);
    Recipes_1[i].AddRequirement('I0PI', 0);
    Recipes_1[i].AddRequirement('I01B', 0);
    Recipes_1[i].AddRequirement('I00T', 10);
    Recipes_1[i].SetCraftLevel(4);
    //РўРѕСЂРёРµРІР°СЏ С†РёСЂРєСѓР»СЏСЂРЅР°СЏ РїРёР»Р° (Recipes_2)
    j = j + 1;
    Recipes_2[j].SetResultItem('I03K', 0);
    Recipes_2[j].AddRequirement('I03D', 0);
    Recipes_2[j].AddRequirement('I00X', 0);
    Recipes_2[j].AddRequirement('I0NX', 10);
    Recipes_2[j].AddRequirement('I0D1', 0);
    Recipes_2[j].AddRequirement('I0D1', 0);
    Recipes_2[j].AddRequirement('I0Q2', 7);
    Recipes_2[j].SetCraftLevel(4);
    //Р­РєР·РѕСЃРєРµР»РµС‚ РљРЈРЎ-500rmk (Recipes_2)
    j = j + 1;
    Recipes_2[j].SetResultItem('I03L', 0);
    Recipes_2[j].AddRequirement('I03C', 0);
    Recipes_2[j].AddRequirement('I03D', 0);
    Recipes_2[j].AddRequirement('I03E', 0);
    Recipes_2[j].AddRequirement('I0PN', 0);
    Recipes_2[j].AddRequirement('I0Q3', 2);
    Recipes_2[j].SetCraftLevel(4);
    //РўР°Р»РёСЃРјР°РЅ РєРѕРЅСЃС‚СЂСѓРєС‚РѕСЂР° (Recipes_2)
    j = j + 1;
    Recipes_2[j].SetResultItem('I0PO', 0);
    Recipes_2[j].AddRequirement('I0OL', 0);
    Recipes_2[j].AddRequirement('I0PI', 0);
    Recipes_2[j].AddRequirement('I07R', 0);
    Recipes_2[j].AddRequirement('I0D3', 0);
    Recipes_2[j].AddRequirement('I0Q2', 7);
    Recipes_2[j].SetCraftLevel(4);
    //Р РµР»РёРєРІРёРё СѓСЂРѕРІРЅСЏ 4 (Recipes_20)
    Recipes_20[8].SetResultItem('I0PP', 0);
    Recipes_20[8].AddRequirement('I0PC', 0);
    Recipes_20[8].AddRequirement('I0PO', 0);
    Recipes_20[8].SetCraftLevel(4);
    Recipes_20[9].SetResultItem('I0PP', 0);
    Recipes_20[9].AddRequirement('I0PD', 0);
    Recipes_20[9].AddRequirement('I0PO', 0);
    Recipes_20[9].SetCraftLevel(4);
    Recipes_20[10].SetResultItem('I0PP', 0);
    Recipes_20[10].AddRequirement('I0PE', 0);
    Recipes_20[10].AddRequirement('I0PO', 0);
    Recipes_20[10].SetCraftLevel(4);
    Recipes_20[11].SetResultItem('I0PQ', 0);
    Recipes_20[11].AddRequirement('I0PC', 0);
    Recipes_20[11].AddRequirement('I0PO', 0);
    Recipes_20[11].SetCraftLevel(4);
    Recipes_20[12].SetResultItem('I0PQ', 0);
    Recipes_20[12].AddRequirement('I0PD', 0);
    Recipes_20[12].AddRequirement('I0PO', 0);
    Recipes_20[12].SetCraftLevel(4);
    Recipes_20[13].SetResultItem('I0PQ', 0);
    Recipes_20[13].AddRequirement('I0PE', 0);
    Recipes_20[13].AddRequirement('I0PO', 0);
    Recipes_20[13].SetCraftLevel(4);
    Recipes_20[14].SetResultItem('I0PR', 0);
    Recipes_20[14].AddRequirement('I0PC', 0);
    Recipes_20[14].AddRequirement('I0PO', 0);
    Recipes_20[14].SetCraftLevel(4);
    Recipes_20[15].SetResultItem('I0PR', 0);
    Recipes_20[15].AddRequirement('I0PD', 0);
    Recipes_20[15].AddRequirement('I0PO', 0);
    Recipes_20[15].SetCraftLevel(4);
    Recipes_20[16].SetResultItem('I0PR', 0);
    Recipes_20[16].AddRequirement('I0PE', 0);
    Recipes_20[16].AddRequirement('I0PO', 0);
    Recipes_20[16].SetCraftLevel(4);
    Recipes_20[17].SetResultItem('I0PS', 0);
    Recipes_20[17].AddRequirement('I0PC', 0);
    Recipes_20[17].AddRequirement('I0PO', 0);
    Recipes_20[17].SetCraftLevel(4);
    Recipes_20[18].SetResultItem('I0PS', 0);
    Recipes_20[18].AddRequirement('I0PD', 0);
    Recipes_20[18].AddRequirement('I0PO', 0);
    Recipes_20[18].SetCraftLevel(4);
    Recipes_20[19].SetResultItem('I0PS', 0);
    Recipes_20[19].AddRequirement('I0PE', 0);
    Recipes_20[19].AddRequirement('I0PO', 0);
    Recipes_20[19].SetCraftLevel(4);
    //РљРёСЃР»РѕС‚РЅР°СЏ РіСЂР°РЅР°С‚Р° (Recipes_2)
    j = j + 1;
    Recipes_2[j].SetResultItem('I0BN', 0);
    Recipes_2[j].AddRequirement('I03C', 0);
    Recipes_2[j].AddRequirement('I01S', 0);
    Recipes_2[j].AddRequirement('I0D1', 0);
    Recipes_2[j].AddRequirement('I0D1', 0);
    Recipes_2[j].AddRequirement('I0D1', 0);
    Recipes_2[j].AddRequirement('I0Q2', 7);
    Recipes_2[j].SetCraftLevel(4);
    //РҐРёРј-РєРѕСЃС‚СЋРј (Recipes_2)
    j = j + 1;
    Recipes_2[j].SetResultItem('I0BO', 0);
    Recipes_2[j].AddRequirement('I03E', 0);
    Recipes_2[j].AddRequirement('I0BE', 0);
    Recipes_2[j].AddRequirement('I0D3', 0);
    Recipes_2[j].AddRequirement('I0PG', 0);
    Recipes_2[j].AddRequirement('I0Q3', 2);
    Recipes_2[j].SetCraftLevel(4);
    //Р“СѓСЃРµРЅРёС‡РЅС‹Рµ СЃР°РїРѕРіРё (Recipes_2)
    j = j + 1;
    Recipes_2[j].SetResultItem('I0BQ', 0);
    Recipes_2[j].AddRequirement('I03B', 0);
    Recipes_2[j].AddRequirement('I07L', 0);
    Recipes_2[j].AddRequirement('I0OY', 0);
    Recipes_2[j].AddRequirement('I0D3', 0);
    Recipes_2[j].AddRequirement('I0Q3', 2);
    Recipes_2[j].SetCraftLevel(4);
    //Р¦РІРµС‚РЅРѕРµ РѕРіРЅРёРІРѕ
    i = i + 1;
    Recipes_1[i].SetResultItem('I063', 0);
    Recipes_1[i].AddRequirement('I0BB', 0);
    Recipes_1[i].AddRequirement('I0PM', 0);
    Recipes_1[i].AddRequirement('I03C', 0);
    Recipes_1[i].AddRequirement('I062', 3);
    Recipes_1[i].AddRequirement('I0O5', 10);
    Recipes_1[i].SetCraftLevel(4);
    //РћСЃРєРѕР»РѕС‡РЅС‹Р№ РјРёРЅРѕСѓРєР»Р°РґС‡РёРє
    i = i + 1;
    Recipes_1[i].SetResultItem('I0BL', 0);
    Recipes_1[i].AddRequirement('I02W', 0);
    Recipes_1[i].AddRequirement('I00Y', 0);
    Recipes_1[i].AddRequirement('I03D', 0);
    Recipes_1[i].AddRequirement('I062', 3);
    Recipes_1[i].AddRequirement('I0OQ', 10);
    Recipes_1[i].SetCraftLevel(4);
    //Р­Р»РµРєС‚СЂРѕРџСѓР»РµРјРµС‚
    i = i + 1;
    Recipes_1[i].SetResultItem('I04I', 0);
    Recipes_1[i].AddRequirement('I04H', 0);
    Recipes_1[i].AddRequirement('I0PJ', 0);
    Recipes_1[i].AddRequirement('I0P6', 0);
    Recipes_1[i].AddRequirement('I062', 3);
    Recipes_1[i].AddRequirement('I0NX', 10);
    Recipes_1[i].SetCraftLevel(4);
    //Р’РёРІР°СЂРёР№
    i = i + 1;
    Recipes_1[i].SetResultItem('I0G9', 0);
    Recipes_1[i].AddRequirement('I0P3', 0);
    Recipes_1[i].AddRequirement('I0PL', 0);
    Recipes_1[i].AddRequirement('I03D', 0);
    Recipes_1[i].AddRequirement('I062', 3);
    Recipes_1[i].AddRequirement('I0OQ', 10);
    Recipes_1[i].SetCraftLevel(4);
    //Р’РѕСЂС‡СѓРЅ
    i = i + 1;
    Recipes_1[i].SetResultItem('I0GC', 0);
    Recipes_1[i].AddRequirement('I0BC', 0);
    Recipes_1[i].AddRequirement('I00Y', 0);
    Recipes_1[i].AddRequirement('I03C', 0);
    Recipes_1[i].AddRequirement('I062', 3);
    Recipes_1[i].SetCraftLevel(4);
    //РЁРёРїРѕРІР°РЅРЅС‹Р№ РґРѕСЃРїРµС…
    i = i + 1;
    Recipes_1[i].SetResultItem('I0BP', 0);
    Recipes_1[i].AddRequirement('I0P4', 0);
    Recipes_1[i].AddRequirement('I0PK', 0);
    Recipes_1[i].AddRequirement('I03E', 0);
    Recipes_1[i].AddRequirement('I062', 3);
    Recipes_1[i].SetCraftLevel(4);
    //РџР»Р°Р·РјРѕРєРѕР°РіСѓР»СЏС‚РѕСЂ
    i = i + 1;
    Recipes_1[i].SetResultItem('I0PT', 0);
    Recipes_1[i].AddRequirement('I0BG', 0);
    Recipes_1[i].AddRequirement('I00Y', 0);
    Recipes_1[i].AddRequirement('I0P6', 0);
    Recipes_1[i].AddRequirement('I062', 3);
    Recipes_1[i].AddRequirement('I0O5', 10);
    Recipes_1[i].SetCraftLevel(4);
    //Р‘СЂРѕРЅРµР±РѕР№РЅР°СЏ СЃРЅР°Р№РїРµСЂРєР°
    i = i + 1;
    Recipes_1[i].SetResultItem('I06N', 0);
    Recipes_1[i].AddRequirement('I0P5', 0);
    Recipes_1[i].AddRequirement('I0PJ', 0);
    Recipes_1[i].AddRequirement('I010', 0);
    Recipes_1[i].AddRequirement('I062', 3);
    Recipes_1[i].AddRequirement('I0NX', 10);
    Recipes_1[i].SetCraftLevel(4);
    //Р—Р°Р¶РёРіР°Р»РєР° v2
    i = i + 1;
    Recipes_1[i].SetResultItem('I0PU', 0);
    Recipes_1[i].AddRequirement('I0BB', 0);
    Recipes_1[i].AddRequirement('I0PM', 0);
    Recipes_1[i].AddRequirement('I0P6', 0);
    Recipes_1[i].AddRequirement('I062', 3);
    Recipes_1[i].AddRequirement('I0NX', 10);
    Recipes_1[i].SetCraftLevel(4);
    //Р‘СѓРј-РЎС‚РёРє Рђ-2 v2
    i = i + 1;
    Recipes_1[i].SetResultItem('I0PV', 0);
    Recipes_1[i].AddRequirement('I0BC', 0);
    Recipes_1[i].AddRequirement('I00Y', 0);
    Recipes_1[i].AddRequirement('I03C', 0);
    Recipes_1[i].AddRequirement('I062', 3);
    Recipes_1[i].AddRequirement('I0OQ', 10);
    Recipes_1[i].SetCraftLevel(4);
    //РњРµРґ-РџСЂРѕС‚РµР· v2
    i = i + 1;
    Recipes_1[i].SetResultItem('I0PW', 0);
    Recipes_1[i].AddRequirement('I0BG', 0);
    Recipes_1[i].AddRequirement('I00Y', 0);
    Recipes_1[i].AddRequirement('I03E', 0);
    Recipes_1[i].AddRequirement('I062', 3);
    Recipes_1[i].SetCraftLevel(4);
    //РњСѓР»СЊС‚РёРєРёСЂРєР° v2
    i = i + 1;
    Recipes_1[i].SetResultItem('I0PX', 0);
    Recipes_1[i].AddRequirement('I0P3', 0);
    Recipes_1[i].AddRequirement('I0PL', 0);
    Recipes_1[i].AddRequirement('I02Q', 0);
    Recipes_1[i].AddRequirement('I062', 3);
    Recipes_1[i].AddRequirement('I0O5', 10);
    Recipes_1[i].SetCraftLevel(4);
    //РџРѕС‚РЅР°СЏ РіСЂР°РЅР°С‚Р° v2
    i = i + 1;
    Recipes_1[i].SetResultItem('I0PY', 0);
    Recipes_1[i].AddRequirement('I02W', 0);
    Recipes_1[i].AddRequirement('I00Y', 0);
    Recipes_1[i].AddRequirement('I0PN', 0);
    Recipes_1[i].AddRequirement('I062', 3);
    Recipes_1[i].AddRequirement('I0NX', 10);
    Recipes_1[i].SetCraftLevel(4);
    //РљРѕР»СЋС‡РёР№ С€Р»РµРј v2
    i = i + 1;
    Recipes_1[i].SetResultItem('I0PZ', 0);
    Recipes_1[i].AddRequirement('I0P4', 0);
    Recipes_1[i].AddRequirement('I0PK', 0);
    Recipes_1[i].AddRequirement('I0PN', 0);
    Recipes_1[i].AddRequirement('I062', 3);
    Recipes_1[i].AddRequirement('I0OQ', 10);
    Recipes_1[i].SetCraftLevel(4);
    //РЎРЅР°Р№РїРµСЂРєР° "РЎРєРѕСЂРїРёРѕРЅ" v2
    i = i + 1;
    Recipes_1[i].SetResultItem('I0Q0', 0);
    Recipes_1[i].AddRequirement('I0P5', 0);
    Recipes_1[i].AddRequirement('I0PJ', 0);
    Recipes_1[i].AddRequirement('I0P6', 0);
    Recipes_1[i].AddRequirement('I062', 3);
    Recipes_1[i].AddRequirement('I0O5', 10);
    Recipes_1[i].SetCraftLevel(4);
    //Р СѓС‡РЅРѕР№ Р°РєСЃРµР»РµСЂР°С‚РѕСЂ v2
    i = i + 1;
    Recipes_1[i].SetResultItem('I0Q1', 0);
    Recipes_1[i].AddRequirement('I04H', 0);
    Recipes_1[i].AddRequirement('I0PJ', 0);
    Recipes_1[i].AddRequirement('I03D', 0);
    Recipes_1[i].AddRequirement('I062', 3);
    Recipes_1[i].SetCraftLevel(4);
}

// в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
// Р’РµР»РёРєР°СЏ РљСѓР·РЅРёС†Р° вЂ” С‚РµР»Рѕ С†РµР»РёРєРѕРј Р·Р°РєРѕРјРјРµРЅС‚РёСЂРѕРІР°РЅРѕ РІ РѕСЂРёРіРёРЅР°Р»Рµ.
void InitCraftingSystem_Recipes_2() {
    // Р’СЃРµ СЂРµС†РµРїС‚С‹ Р’РµР»РёРєРѕР№ РљСѓР·РЅРёС†С‹ РёРЅРёС†РёР°Р»РёР·РёСЂСѓСЋС‚СЃСЏ РІРЅСѓС‚СЂРё
    // InitCraftingSystem_Recipes_1() С‡РµСЂРµР· РїРµСЂРµРјРµРЅРЅСѓСЋ j.
}

// в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
// РџРµСЂРµРїР»Р°РІРєР° (Recipes_3) Рё РџРµСЂРµРїР»Р°РІРєР° С…10 (Recipes_4)
void InitCraftingSystem_Recipes_3() {
    int i = 0;

    for (i = 0; i < 30; i++) {
        @Recipes_3[i] = CraftRecipe();
        Recipes_3[i].SetItemPlace(5);
    }
    for (i = 0; i < 5; i++) {
        @Recipes_4[i] = CraftRecipe();
    }

    //РљРѕС‚Р»РµС‚РєРё "РћР±Р¶РѕСЂРєР°"
    i = 0;
    Recipes_3[i].SetResultItem('I0A3', 1);
    Recipes_3[i].AddRequirement('I0A1', 1);
    Recipes_3[i].AddRequirement('I0A2', 1);
    Recipes_3[i].SetCraftLevel(0);
    //РџРѕС‚СЂСЏСЃРЅР°СЏ Р¶СЂР°С‡РєР° (4 РІР°СЂРёР°РЅС‚Р°)
    i = 1;
    Recipes_3[i].SetResultItem('I0A4', 1);
    Recipes_3[i].AddRequirement('I09V', 1);
    Recipes_3[i].AddRequirement('I09Z', 1);
    Recipes_3[i].SetCraftLevel(0);
    i = 2;
    Recipes_3[i].SetResultItem('I0A4', 1);
    Recipes_3[i].AddRequirement('I09R', 1);
    Recipes_3[i].AddRequirement('I09Z', 1);
    Recipes_3[i].SetCraftLevel(0);
    i = 3;
    Recipes_3[i].SetResultItem('I0A4', 1);
    Recipes_3[i].AddRequirement('I09S', 1);
    Recipes_3[i].AddRequirement('I09Z', 1);
    Recipes_3[i].SetCraftLevel(0);
    i = 4;
    Recipes_3[i].SetResultItem('I0A4', 1);
    Recipes_3[i].AddRequirement('I09W', 1);
    Recipes_3[i].AddRequirement('I09Z', 1);
    Recipes_3[i].SetCraftLevel(0);
    //РџРѕС‚СЂСЏСЃРЅР°СЏ РѕС‚Р±РёРІРЅР°СЏ
    i = 5;
    Recipes_3[i].SetResultItem('I0A5', 1);
    Recipes_3[i].AddRequirement('I0AC', 1);
    Recipes_3[i].AddRequirement('I09Z', 1);
    Recipes_3[i].SetCraftLevel(0);
    i = 6;
    Recipes_3[i].SetResultItem('I0A5', 1);
    Recipes_3[i].AddRequirement('I0A1', 1);
    Recipes_3[i].AddRequirement('I09Z', 1);
    Recipes_3[i].SetCraftLevel(0);
    //РџРѕС‚СЂСЏСЃРЅС‹Р№ СЃР°Р»Р°С‚
    i = 7;
    Recipes_3[i].SetResultItem('I0A6', 1);
    Recipes_3[i].AddRequirement('I09X', 1);
    Recipes_3[i].AddRequirement('I09Z', 1);
    Recipes_3[i].SetCraftLevel(0);
    i = 8;
    Recipes_3[i].SetResultItem('I0A6', 1);
    Recipes_3[i].AddRequirement('I0A2', 1);
    Recipes_3[i].AddRequirement('I09Z', 1);
    Recipes_3[i].SetCraftLevel(0);
    //РЎР°Р»Р°С‚ "Р—РµР»С‘РЅС‹Р№"
    i = 9;
    Recipes_3[i].SetResultItem('I0AK', 1);
    Recipes_3[i].AddRequirement('I01X', 1);
    Recipes_3[i].AddRequirement('I09K', 1);
    Recipes_3[i].SetCraftLevel(0);
    i = 10;
    Recipes_3[i].SetResultItem('I0AK', 1);
    Recipes_3[i].AddRequirement('I0A2', 1);
    Recipes_3[i].AddRequirement('I09X', 1);
    Recipes_3[i].SetCraftLevel(0);
    //РЎРµРєСЂРµС‚РЅР°СЏ РІРєСѓСЃРЅСЏС€РєР°
    i = 11;
    Recipes_3[i].SetResultItem('I0KV', 1);
    Recipes_3[i].AddRequirement('I0FV', 1);
    Recipes_3[i].AddRequirement('I09Z', 1);
    Recipes_3[i].SetCraftLevel(0);
    //Р–Р°СЂРµРЅРЅРѕРµ РјСЏСЃРѕ
    i = 12;
    Recipes_3[i].SetResultItem('I0AC', 1);
    Recipes_3[i].AddRequirement('I0AB', 1);
    Recipes_3[i].SetCraftLevel(0);
    //РЎР»РёС‚РєРё РјРµС‚Р°Р»Р»РѕРІ
    i = 13;
    Recipes_3[i].SetResultItem('I00T', 1);
    Recipes_3[i].AddRequirement('I003', 1);
    Recipes_3[i].SetCraftLevel(0);
    //РђСЂРєР°РЅРёС‚ С…10 (Recipes_4)
    Recipes_4[0].SetResultItem('I00T', 10);
    Recipes_4[0].AddRequirement('I003', 10);
    Recipes_4[0].SetCraftLevel(0);
    i = 14;
    Recipes_3[i].SetResultItem('I00U', 1);
    Recipes_3[i].AddRequirement('I002', 1);
    Recipes_3[i].SetCraftLevel(0);
    //РўРѕСЂРёР№ С…10 (Recipes_4)
    Recipes_4[1].SetResultItem('I00U', 10);
    Recipes_4[1].AddRequirement('I002', 10);
    Recipes_4[1].SetCraftLevel(0);
    i = 15;
    Recipes_3[i].SetResultItem('I00V', 1);
    Recipes_3[i].AddRequirement('I000', 1);
    Recipes_3[i].SetCraftLevel(0);
    //Р–РµР»РµР·Рѕ С…10 (Recipes_4)
    Recipes_4[2].SetResultItem('I00V', 10);
    Recipes_4[2].AddRequirement('I000', 10);
    Recipes_4[2].SetCraftLevel(0);
    i = 16;
    Recipes_3[i].SetResultItem('I00W', 1);
    Recipes_3[i].AddRequirement('I001', 1);
    Recipes_3[i].SetCraftLevel(0);
    //РЎРµСЂРµР±СЂРѕ С…10 (Recipes_4)
    Recipes_4[3].SetResultItem('I00W', 10);
    Recipes_4[3].AddRequirement('I001', 10);
    Recipes_4[3].SetCraftLevel(0);
    //Р”РµРјРѕРЅРёС‡РµСЃРєРёР№ СЃР»РёС‚РѕРє
    i = 17;
    Recipes_3[i].SetResultItem('I062', 1);
    Recipes_3[i].AddRequirement('I061', 1);
    Recipes_3[i].SetCraftLevel(0);
    //Р”РµРјРѕРЅРёС‚ С…10 (Recipes_4)
    Recipes_4[4].SetResultItem('I062', 10);
    Recipes_4[4].AddRequirement('I061', 10);
    Recipes_4[4].SetCraftLevel(0);
    //Р С‹Р±РЅС‹Рµ Р±Р»СЋРґР°
    i = 18;
    Recipes_3[i].SetResultItem('I09R', 1);
    Recipes_3[i].AddRequirement('I09P', 1);
    Recipes_3[i].SetCraftLevel(0);
    i = 19;
    Recipes_3[i].SetResultItem('I09S', 1);
    Recipes_3[i].AddRequirement('I09I', 1);
    Recipes_3[i].SetCraftLevel(0);
    i = 20;
    Recipes_3[i].SetResultItem('I09V', 1);
    Recipes_3[i].AddRequirement('I09L', 1);
    Recipes_3[i].SetCraftLevel(0);
    i = 21;
    Recipes_3[i].SetResultItem('I09W', 1);
    Recipes_3[i].AddRequirement('I09Q', 1);
    Recipes_3[i].SetCraftLevel(0);
    i = 22;
    Recipes_3[i].SetResultItem('I09X', 1);
    Recipes_3[i].AddRequirement('I09K', 1);
    Recipes_3[i].SetCraftLevel(0);
    i = 23;
    Recipes_3[i].SetResultItem('I09Y', 1);
    Recipes_3[i].AddRequirement('I09O', 1);
    Recipes_3[i].SetCraftLevel(0);
    i = 24;
    Recipes_3[i].SetResultItem('I0A1', 1);
    Recipes_3[i].AddRequirement('I0A0', 1);
    Recipes_3[i].SetCraftLevel(0);
    i = 25;
    Recipes_3[i].SetResultItem('I0A2', 1);
    Recipes_3[i].AddRequirement('I01X', 1);
    Recipes_3[i].SetCraftLevel(0);
    //РњСѓР»СЊС‚РёСЃС‚Р°Р»СЊ
    i = i + 1;
    Recipes_3[i].SetResultItem('I0OB', 1);
    Recipes_3[i].AddRequirement('I00V', 1);
    Recipes_3[i].AddRequirement('I00W', 1);
    Recipes_3[i].AddRequirement('I00U', 1);
    Recipes_3[i].AddRequirement('I00T', 1);
    Recipes_3[i].SetCraftLevel(31);
}

// в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
// РџРµСЂРµРїР»Р°РІРєР° С…10 вЂ” РёРЅРёС†РёР°Р»РёР·РёСЂСѓРµС‚СЃСЏ РІРЅСѓС‚СЂРё InitCraftingSystem_Recipes_3().
void InitCraftingSystem_Recipes_4() {
}

// в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
// Р—РµР»СЊСЏ вЂ” РёРЅРёС†РёР°Р»РёР·РёСЂСѓСЋС‚СЃСЏ РІРЅСѓС‚СЂРё InitCraftingSystem_Recipes_1().
void InitCraftingSystem_Recipes_5() {
}

// в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
// РђРЅРіРµР»СЊСЃРєР°СЏ РљСѓР·РЅРёС†Р° вЂ” СЂРµС†РµРїС‚С‹ Р·Р°РєРѕРјРјРµРЅС‚РёСЂРѕРІР°РЅС‹ РІ РѕСЂРёРіРёРЅР°Р»Рµ.
void InitCraftingSystem_Recipes_6() {
    for (int i = 0; i < 100; i++) {
        @Recipes_6[i] = CraftRecipe();
        Recipes_6[i].SetItemPlace(7);
    }
    // TODO: СЂР°СЃРєРѕРјРјРµРЅС‚РёСЂРѕРІР°С‚СЊ СЂРµС†РµРїС‚С‹ РёР· 2-CraftingSys.j (InitCraftingSystem_Recipes_6)
}

// в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
// Р”РµРјРѕРЅРёС‡РµСЃРєР°СЏ РљСѓР·РЅРёС†Р° вЂ” СЂРµС†РµРїС‚С‹ Р·Р°РєРѕРјРјРµРЅС‚РёСЂРѕРІР°РЅС‹ РІ РѕСЂРёРіРёРЅР°Р»Рµ.
void InitCraftingSystem_Recipes_7() {
    for (int i = 0; i < 100; i++) {
        @Recipes_7[i] = CraftRecipe();
        Recipes_7[i].SetItemPlace(8);
    }
    // TODO: СЂР°СЃРєРѕРјРјРµРЅС‚РёСЂРѕРІР°С‚СЊ СЂРµС†РµРїС‚С‹ РёР· 2-CraftingSys.j (InitCraftingSystem_Recipes_7)
}

// в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
// FS РљСѓР·РЅРёС†Р° вЂ” РЅРµС‚ С„СѓРЅРєС†РёРё РёРЅРёС†РёР°Р»РёР·Р°С†РёРё РІ РѕСЂРёРіРёРЅР°Р»Рµ.
void InitCraftingSystem_Recipes_8() {
    for (int i = 0; i < 15; i++) {
        @Recipes_8[i] = CraftRecipe();
        Recipes_8[i].SetItemPlace(0); // place РЅРµ Р·Р°РґР°РЅ РІ РѕСЂРёРіРёРЅР°Р»Рµ
    }
}

// в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
// Р”СЂР°РєРѕРЅСЊСЏ РљСѓР·РЅРёС†Р° вЂ” СЂРµС†РµРїС‚С‹ Р·Р°РєРѕРјРјРµРЅС‚РёСЂРѕРІР°РЅС‹ РІ РѕСЂРёРіРёРЅР°Р»Рµ.
void InitCraftingSystem_Recipes_9() {
    for (int i = 0; i < 20; i++) {
        @Recipes_9[i] = CraftRecipe();
        Recipes_9[i].SetItemPlace(9);
    }
    // TODO: СЂР°СЃРєРѕРјРјРµРЅС‚РёСЂРѕРІР°С‚СЊ СЂРµС†РµРїС‚С‹ РёР· 2-CraftingSys.j (InitCraftingSystem_Recipes_9)
}

// в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
// Р’С‹Р·С‹РІР°РµС‚СЃСЏ РёР· РѕСЃРЅРѕРІРЅРѕР№ РёРЅРёС†РёР°Р»РёР·Р°С†РёРё РєР°СЂС‚С‹.
void InitCraftingSystem() {
    InitCraftingSystem_Recipes_1();
    InitCraftingSystem_Recipes_3();
    InitCraftingSystem_Recipes_6();
    InitCraftingSystem_Recipes_7();
    InitCraftingSystem_Recipes_8();
    InitCraftingSystem_Recipes_9();
    BuildCraftableItemsList();
}
