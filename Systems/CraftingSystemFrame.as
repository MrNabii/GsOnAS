// ═══════════════════════════════════════════════════════════════════════════
// CraftingSystemFrame.as — UI фрейм для системы крафта
// ═══════════════════════════════════════════════════════════════════════════

// ─── Менеджер больших панелей (единая система фреймов) ───
// При открытии одной панели — предыдущая закрывается, не наслаиваясь.
// Чтобы подключить другую панель:
//   CF_RegisterPanel(MY_PANEL_ID, @MyPanelHideForPlayer);
//   CF_OpenPanel(playerId, MY_PANEL_ID);



array<int> CF_ActivePanelId(12);
funcdef void PanelCloseCallback(int pid);
array<PanelCloseCallback@> CF_PanelClosers(16);

void CF_RegisterPanel(int panelId, PanelCloseCallback@ closer) {
    if (panelId >= 0 && panelId < 16)
        @CF_PanelClosers[panelId] = closer;
}

void CF_CloseActivePanel(int pid) {
    if (pid < 0 || pid >= 12) return;

    int activePanelId = CF_ActivePanelId[pid];
    if (activePanelId > 0 && activePanelId < 16) {
        if (CF_PanelClosers[activePanelId] !is null)
            CF_PanelClosers[activePanelId](pid);
    }
    CF_ActivePanelId[pid] = 0;
}

// Открыть панель. Если та же панель уже открыта — toggle off.
void CF_OpenPanel(int pid, int panelId) {
    if (pid < 0 || pid >= 12) return;

    if (CF_ActivePanelId[pid] == panelId) {
        CF_CloseActivePanel(pid);
        return;
    }
    CF_CloseActivePanel(pid);
    CF_ActivePanelId[pid] = panelId;
}


// ═══════════════════════════════════════════════════════════════════════════
// Константы крафт-браузера
// ═══════════════════════════════════════════════════════════════════════════
int CRAFT_PANEL_ID = 1;

// Размеры сетки
int CB_GRID_COLS = 5;
int CB_GRID_ROWS = 10;
float CB_CELL_SIZE = 0.028;
float CB_CELL_GAP  = 0.003;

// Позиция (правая сторона экрана)
float CB_GRID_ORIGIN_X = 0.46;
float CB_GRID_ORIGIN_Y = 0.535;

// Детальная панель (слева от сетки)
float CB_DETAIL_W = 0.16;
float CB_DETAIL_H = 0.32;

// Used-In секция внизу детальной панели
int CB_USEDIN_COLS = 7;
int CB_USEDIN_ROWS = 4;


// ═══════════════════════════════════════════════════════════════════════════
// Per-player state
// ═══════════════════════════════════════════════════════════════════════════
array<bool> CB_IsOpen(12);
array<int> CB_SelectedItemTypeId(12);
array<int> CB_GridPage(12);
array<int> CB_RecipePage(12);
array<int> CB_UsedInPage(12);
array<int> CB_FilterPlace(12);    // 0 = все места, >0 = конкретное место


// ═══════════════════════════════════════════════════════════════════════════
// Frame handles
// ═══════════════════════════════════════════════════════════════════════════

// --- Сетка (справа) ---

framehandle CB_GridBackdrop;
array<framehandle> CB_GridBtns;       // BUTTON (кликабельные)
framehandle CB_GridTitle;
framehandle CB_GridPageText;
framehandle CB_GridPrevBtn;
framehandle CB_GridNextBtn;
framehandle CB_CloseBtn;
framehandle CB_OpenBtn;
framehandle CB_OpenText;

// --- Детальная панель (слева) ---
framehandle CB_DetailBackdrop;
framehandle CB_DetailTitle;           // Название предмета
framehandle CB_DetailDesc;            // Описание предмета

// Секция рецепта
framehandle CB_RecipeLabel;           // "Рецепт X/N"
framehandle CB_RecipePrevBtn;
framehandle CB_RecipeNextBtn;
array<framehandle> CB_RecipeIcons;    // Иконки ингредиентов
array<framehandle> CB_RecipeCountTexts; // "xN" под иконками
framehandle CB_ResultIcon;            // Иконка результата
framehandle CB_ResultText;            // "xN" под результатом

// Секция "Где используется"
framehandle CB_UsedInLabel;
array<framehandle> CB_UsedInBtns;
framehandle CB_UsedInPageText;
framehandle CB_UsedInPrevBtn;
framehandle CB_UsedInNextBtn;

// HT для маппинга frame → data
hashtable CB_HT = Jass::InitHashtable();

// Отфильтрованный список крафтовых предметов
array<int> CB_FilteredItems;

int CB_FrameCtx = 5000;  // Уникальный счётчик createContext


// ═══════════════════════════════════════════════════════════════════════════
// Вспомогательные функции
// ═══════════════════════════════════════════════════════════════════════════

void CB_RebuildFilteredItems(int filterPlace) {
    CB_FilteredItems.resize(0);
    for (uint i = 0; i < AllCraftableItems.length(); i++) {
        if (filterPlace <= 0) {
            CB_FilteredItems.insertLast(AllCraftableItems[i]);
        } else {
            ItemCraftData@ icd = GetItemCraftData(AllCraftableItems[i]);
            if (icd !is null)
                CB_FilteredItems.insertLast(AllCraftableItems[i]);
        }
    }
}

string CB_GetItemIcon(int itemTypeId) {
    return Jass::GetBaseItemStringFieldById(itemTypeId, Jass::ConvertItemStringField('iico'));
}

string CB_GetItemName(int itemTypeId) {
    return Jass::GetBaseItemStringFieldById(itemTypeId, Jass::ITEM_SF_NAME);
}

string CB_GetItemDescription(int itemTypeId) {
    return Jass::GetBaseItemStringFieldById(itemTypeId, Jass::ConvertItemStringField('utub'));
}

// --- Создание фрейм-элементов ---
framehandle CB_CreateButton(framehandle parent, float size) {
    framehandle btn = Jass::CreateFrameByType("SIMPLEBUTTON", "CB_Btn", parent, "", CB_FrameCtx);
    CB_FrameCtx++;
    Jass::ClearFrameAllPoints(btn);
    Jass::SetFrameSize(btn, size, size);
    Jass::SetFramePriority(btn, 2);
    return btn;
}

framehandle CB_CreateText(framehandle parent, float fontSize, string text) {
    framehandle txt = Jass::CreateFrameByType("SIMPLETEXT", "CB_Txt", parent, "", CB_FrameCtx);
    CB_FrameCtx++;
    Jass::ClearFrameAllPoints(txt);
    Jass::SetFrameFont(txt, "Fonts\\FRIZQT__.TTF", fontSize, 0);
    Jass::SetFrameText(txt, text);
    Jass::ShowFrame(txt, true);
    Jass::SetFrameTextAlignment(txt, Jass::TEXT_JUSTIFY_CENTER, Jass::TEXT_JUSTIFY_CENTER);
    return txt;
}

framehandle CB_GetTooltip(int frame_int) {
    return Jass::GetFrameByName("CB_TooltipTitle", frame_int);
}

framehandle CB_CreateTooltip(framehandle simple_btn, int frame_int) {
    framehandle tooltipBox;
    framehandle tooltipTitle;
    framehandle tooltipDesc;

    // background
    tooltipBox = Jass::CreateFrameByType("SIMPLEFRAME", "CB_TooltipBox", simple_btn, "", frame_int);
    Jass::ClearFrameAllPoints(tooltipBox);
    Jass::SetFrameTextureEx(tooltipBox, 0, "UI\\Widgets\\ToolTips\\Human\\human-tooltip-background", false, "UI\\Widgets\\ToolTips\\Human\\human-tooltip-border", Jass::BORDER_FLAG_ALL);
    Jass::ShowFrame(tooltipBox, false);
    Jass::SetFramePriority(tooltipBox, 12);

    // title (название баффа)
    tooltipTitle = Jass::CreateFrameByType("SIMPLETEXT", "CB_TooltipTitle", tooltipBox, "", frame_int);
    Jass::ClearFrameAllPoints(tooltipTitle);
    Jass::SetFrameParent(tooltipTitle, tooltipBox);
    Jass::SetFrameFont(tooltipTitle, "Fonts\\FRIZQT__.TTF", 0.010, 0);
    Jass::SetFrameRelativePoint(tooltipTitle, Jass::FRAMEPOINT_BOTTOM, simple_btn, Jass::FRAMEPOINT_TOP, 0, 0.005);
    Jass::SetFrameSize(tooltipTitle, 0.13, 0.0);
    Jass::SetFrameTextAlignment(tooltipTitle, Jass::TEXT_JUSTIFY_CENTER, Jass::TEXT_JUSTIFY_LEFT);
    Jass::SetFramePriority(tooltipTitle, 13);
    Jass::SetFrameText(tooltipTitle, "Name");
    Jass::ShowFrame(tooltipTitle, true);

    Jass::SetFrameRelativePoint(tooltipBox, Jass::FRAMEPOINT_BOTTOMRIGHT, tooltipTitle, Jass::FRAMEPOINT_BOTTOMRIGHT, 0.007, -0.005);
    Jass::SetFrameRelativePoint(tooltipBox, Jass::FRAMEPOINT_TOPLEFT, tooltipTitle, Jass::FRAMEPOINT_TOPLEFT, -0.007, 0.005);
    Jass::SetFrameTooltip(simple_btn, tooltipBox);
    Jass::SetFramePriority(tooltipBox, 13);

    return tooltipTitle;
}

// ═══════════════════════════════════════════════════════════════════════════
// Обновление UI
// ═══════════════════════════════════════════════════════════════════════════

// --- Обновить сетку крафтов для игрока ---
void CB_UpdateGrid(int pid) {
    int itemsPerPage = CB_GRID_COLS * CB_GRID_ROWS;
    int page = CB_GridPage[pid];
    int totalItems = int(CB_FilteredItems.length());
    int totalPages = (totalItems + itemsPerPage - 1) / itemsPerPage;
    if (totalPages < 1) totalPages = 1;
    if (page >= totalPages) { page = totalPages - 1; CB_GridPage[pid] = page; }
    if (page < 0) { page = 0; CB_GridPage[pid] = 0; }

    int startIdx = page * itemsPerPage;

    if (true) {
        for (int i = 0; i < itemsPerPage; i++) {
            int dataIdx = startIdx + i;
            if (dataIdx < totalItems) {
                int itemId = CB_FilteredItems[dataIdx];
                if(Jass::GetLocalPlayer() == Jass::Player(pid)) {
                    Jass::SetFrameTexture(CB_GridBtns[i], CB_GetItemIcon(itemId), 1, true);
                    Jass::ShowFrame(CB_GridBtns[i], true);
                    Jass::SetFrameText(CB_GetTooltip(i), CB_GetItemName(itemId));
                }
                Jass::SaveInteger(CB_HT, Jass::GetHandleId(CB_GridBtns[i]), 'itid', itemId);
            } else {
                if(Jass::GetLocalPlayer() == Jass::Player(pid))
                    Jass::ShowFrame(CB_GridBtns[i], false);
            }
        }
        if (Jass::GetLocalPlayer() == Jass::Player(pid))
            Jass::SetFrameText(CB_GridPageText, Jass::I2S(page + 1) + "/" + Jass::I2S(totalPages));
    }
}

// --- Обновить детальную панель ---
void CB_UpdateDetail(int pid) {
    int itemId = CB_SelectedItemTypeId[pid];

    if (itemId <= 0) {
        if (Jass::GetLocalPlayer() == Jass::Player(pid))
            Jass::ShowFrame(CB_DetailBackdrop, false);
        return;
    }

    ItemCraftData@ icd = GetItemCraftData(itemId);
    int recipeIdx = CB_RecipePage[pid];
    int usedInPage = CB_UsedInPage[pid];

    if (true) {
        if(Jass::GetLocalPlayer() == Jass::Player(pid))
            Jass::ShowFrame(CB_DetailBackdrop, true);

        // Название и описание
        if(Jass::GetLocalPlayer() == Jass::Player(pid))
            Jass::SetFrameText(CB_DetailTitle, "|cffffcc00" + CB_GetItemName(itemId) + "|r");
        if(Jass::GetLocalPlayer() == Jass::Player(pid))
            Jass::SetFrameText(CB_DetailDesc, CB_GetItemDescription(itemId));

        // ─── Рецепт ───
        int recipeCount = 0;
        if (icd !is null) recipeCount = icd.GetRecipeCount();
        if (recipeIdx >= recipeCount) { recipeIdx = 0; CB_RecipePage[pid] = 0; }

        if (recipeCount > 0) {
            CraftRecipe@ recipe = icd.GetRecipe(recipeIdx);
            if(Jass::GetLocalPlayer() == Jass::Player(pid))
                Jass::SetFrameText(CB_RecipeLabel,
                    "|cffffcc00 " + PlaceNames[recipe.GetPlace()-1] + " " + Jass::I2S(recipeIdx + 1) + "/" + Jass::I2S(recipeCount) + "|r");
            if(Jass::GetLocalPlayer() == Jass::Player(pid))
                Jass::ShowFrame(CB_RecipePrevBtn, recipeCount > 1);
            if(Jass::GetLocalPlayer() == Jass::Player(pid))
                Jass::ShowFrame(CB_RecipeNextBtn, recipeCount > 1);

            int ingCount = recipe.GetIngredientCount();
            for (int i = 0; i < MAX_CRAFT_INGREDIENTS; i++) {
                if (i < ingCount) {
                    int ingId = recipe.GetIngredientItemId(i);
                    int ingCnt = recipe.GetIngredientReqCount(i);
                    if(Jass::GetLocalPlayer() == Jass::Player(pid))
                        Jass::SetFrameTexture(CB_RecipeIcons[i], CB_GetItemIcon(ingId), 1, true);
                    if(Jass::GetLocalPlayer() == Jass::Player(pid))
                        Jass::ShowFrame(CB_RecipeIcons[i], true);
                    if(Jass::GetLocalPlayer() == Jass::Player(pid))
                        Jass::SetFrameText(CB_GetTooltip(100+i), CB_GetItemName(ingId));
                    Jass::SaveInteger(CB_HT, Jass::GetHandleId(CB_RecipeIcons[i]), 'itid', ingId);
                    if(Jass::GetLocalPlayer() == Jass::Player(pid))
                        Jass::SetFrameText(CB_RecipeCountTexts[i], "");
                    if (ingCnt > 0)
                        if(Jass::GetLocalPlayer() == Jass::Player(pid))
                            Jass::SetFrameText(CB_RecipeCountTexts[i], "|cffFFFFFFx" + Jass::I2S(ingCnt) + "|r");
                        
                } else {
                    if(Jass::GetLocalPlayer() == Jass::Player(pid))
                        Jass::ShowFrame(CB_RecipeIcons[i], false);
                    if(Jass::GetLocalPlayer() == Jass::Player(pid))
                        Jass::SetFrameText(CB_RecipeCountTexts[i], "");
                }
            }

            // Результат
            if(Jass::GetLocalPlayer() == Jass::Player(pid))
                Jass::SetFrameTexture(CB_ResultIcon, CB_GetItemIcon(itemId), 1, true);
            if(Jass::GetLocalPlayer() == Jass::Player(pid))
                Jass::ShowFrame(CB_ResultIcon, true);
            int rch = recipe.GetResultCharges();
            if(Jass::GetLocalPlayer() == Jass::Player(pid))
                Jass::SetFrameText(CB_ResultText, "");
            if (rch > 0)
                if(Jass::GetLocalPlayer() == Jass::Player(pid))
                    Jass::SetFrameText(CB_ResultText, "|cff00ff00x" + Jass::I2S(rch) + "|r");
        } else {
            if(Jass::GetLocalPlayer() == Jass::Player(pid))
                Jass::SetFrameText(CB_RecipeLabel, "|cff888888Нет рецепта|r");
            if(Jass::GetLocalPlayer() == Jass::Player(pid))
                Jass::ShowFrame(CB_RecipePrevBtn, false);
            if(Jass::GetLocalPlayer() == Jass::Player(pid))
                Jass::ShowFrame(CB_RecipeNextBtn, false);
            for (int i = 0; i < MAX_CRAFT_INGREDIENTS; i++) {
                if(Jass::GetLocalPlayer() == Jass::Player(pid))
                    Jass::ShowFrame(CB_RecipeIcons[i], false);
                if(Jass::GetLocalPlayer() == Jass::Player(pid))
                    Jass::SetFrameText(CB_RecipeCountTexts[i], "");
            }
            if(Jass::GetLocalPlayer() == Jass::Player(pid))
                Jass::ShowFrame(CB_ResultIcon, false);
            if(Jass::GetLocalPlayer() == Jass::Player(pid))
                Jass::SetFrameText(CB_ResultText, "");
        }

        // ─── Где используется ───
        int usedInTotal = 0;
        if (icd !is null) usedInTotal = icd.GetUsedInCount();
        int usedInPerPage = CB_USEDIN_COLS * CB_USEDIN_ROWS;
        int usedInPages = (usedInTotal + usedInPerPage - 1) / usedInPerPage;
        if (usedInPages < 1) usedInPages = 1;
        if (usedInPage >= usedInPages) { usedInPage = 0; CB_UsedInPage[pid] = 0; }

        int usedInStart = usedInPage * usedInPerPage;

        if (usedInTotal > 0) {
            if(Jass::GetLocalPlayer() == Jass::Player(pid))
                Jass::SetFrameText(CB_UsedInLabel, "|cffffcc00Используется в:|r");
        } else {
            if(Jass::GetLocalPlayer() == Jass::Player(pid))
                Jass::SetFrameText(CB_UsedInLabel, "");
        }

        for (int i = 0; i < usedInPerPage; i++) {
            int dIdx = usedInStart + i;
            if (dIdx < usedInTotal && icd !is null) {
                int uid = icd.GetUsedInItem(dIdx);
                if(Jass::GetLocalPlayer() == Jass::Player(pid)) {
                    Jass::SetFrameTexture(CB_UsedInBtns[i], CB_GetItemIcon(uid), 1, true);
                    Jass::ShowFrame(CB_UsedInBtns[i], true);
                    Jass::SetFrameText(CB_GetTooltip(200+i), CB_GetItemName(uid));
                }
                Jass::SaveInteger(CB_HT, Jass::GetHandleId(CB_UsedInBtns[i]), 'itid', uid);
            } else {
                if(Jass::GetLocalPlayer() == Jass::Player(pid))
                    Jass::ShowFrame(CB_UsedInBtns[i], false);
            }
        }

        if(Jass::GetLocalPlayer() == Jass::Player(pid)) {
            Jass::ShowFrame(CB_UsedInPrevBtn, usedInPages > 1);
            Jass::ShowFrame(CB_UsedInNextBtn, usedInPages > 1);
            Jass::SetFrameText(CB_UsedInPageText,
                Jass::I2S(usedInPage + 1) + "/" + Jass::I2S(usedInPages));
        }
    }
}


// ═══════════════════════════════════════════════════════════════════════════
// Открытие / Закрытие
// ═══════════════════════════════════════════════════════════════════════════

void CB_Show(int pid) {
    CB_IsOpen[pid] = true;
    CB_GridPage[pid] = 0;
    CB_RecipePage[pid] = 0;
    CB_UsedInPage[pid] = 0;
    CB_SelectedItemTypeId[pid] = 0;
    CB_RebuildFilteredItems(CB_FilterPlace[pid]);
    CB_UpdateGrid(pid);
    if (Jass::GetLocalPlayer() == Jass::Player(pid)) {
        Jass::ShowFrame(CB_GridBackdrop, true);
        Jass::ShowFrame(CB_DetailBackdrop, false);
    }
}

void CB_Hide(int pid) {
    CB_IsOpen[pid] = false;
    CB_SelectedItemTypeId[pid] = 0;
    if (Jass::GetLocalPlayer() == Jass::Player(pid)) {
        Jass::ShowFrame(CB_GridBackdrop, false);
        Jass::ShowFrame(CB_DetailBackdrop, false);
    }
}

// Закрыть для ВСЕХ игроков (для менеджера панелей)
void CB_HideAll() {
    for (int p = 0; p < 12; p++) CB_Hide(p);
}

// ─── Публичная функция: открыть браузер крафтов ───
// pid:         ID игрока (0-based)
void OpenCraftBrowser(int pid, int filterPlace = 0) {
    CF_OpenPanel(pid, CRAFT_PANEL_ID);
    if (CF_ActivePanelId[pid] != CRAFT_PANEL_ID) return;

    CB_FilterPlace[pid] = filterPlace;
    CB_Show(pid);
}

// ─── Публичная функция: закрыть браузер крафтов ───
void CloseCraftBrowser(int pid) {
    CB_Hide(pid);
    if (CF_ActivePanelId[pid] == CRAFT_PANEL_ID) CF_ActivePanelId[pid] = 0;
}


// ═══════════════════════════════════════════════════════════════════════════
// Инициализация фреймов
// ═══════════════════════════════════════════════════════════════════════════

void InitCraftingSystemFrame() {
    int itemsPerPage = CB_GRID_COLS * CB_GRID_ROWS;
    CB_GridBtns.resize(itemsPerPage);
    CB_RecipeIcons.resize(MAX_CRAFT_INGREDIENTS);
    CB_RecipeCountTexts.resize(MAX_CRAFT_INGREDIENTS);
    int usedInPerPage = CB_USEDIN_COLS * CB_USEDIN_ROWS;
    CB_UsedInBtns.resize(usedInPerPage);

    framehandle gameUI = Jass::GetOriginFrame(Jass::ORIGIN_FRAME_GAME_UI, 0);

    // ═══════ Фон сетки (справа) ═══════
    float gridW = CB_GRID_COLS * (CB_CELL_SIZE + CB_CELL_GAP) + 0.020;
    float gridH = CB_GRID_ROWS * (CB_CELL_SIZE + CB_CELL_GAP) + 0.060;

    trigger openBtnTrg = Jass::CreateTrigger();
    // open button
    CB_OpenBtn = Jass::CreateFrameByType("SIMPLEBUTTON", "OpenMainBookButton", gameUI, "", 0);
    string str = "CustomUI\\Selectors\\ClickableButton";
    Jass::ClearFrameAllPoints(CB_OpenBtn);
    Jass::SetFrameTexture(CB_OpenBtn, str, 0, true);
    Jass::SetFrameTexture(CB_OpenBtn, str, 1, true);
    Jass::SetFrameTexture(CB_OpenBtn, str, 2, true);
    Jass::SetFrameSize(CB_OpenBtn, 0.05, 0.025);
    Jass::SetFramePriority(CB_OpenBtn, 6);
    Jass::ShowFrame(CB_OpenBtn, true);
    Jass::SetFrameAbsolutePoint(CB_OpenBtn, Jass::FRAMEPOINT_BOTTOMLEFT, 0.0, 0.15);

    CB_OpenText = Jass::CreateFrameByType("SIMPLETEXT", "OpenMainBookText", CB_OpenBtn, "", 0);
    Jass::ClearFrameAllPoints(CB_OpenText);
    Jass::SetFrameBlendMode(CB_OpenText, 0, Jass::BLEND_MODE_BLEND);
    Jass::SetFrameFont(CB_OpenText, "Fonts\\FRIZQT__.TTF", 0.0115, 0);
    Jass::SetFrameTextAlignment(CB_OpenText, Jass::TEXT_JUSTIFY_CENTER, Jass::TEXT_JUSTIFY_MIDDLE);
    Jass::SetFrameTextColour(CB_OpenText, 0xFF806050);
    Jass::SetFrameParent(CB_OpenText, CB_OpenBtn);
    Jass::SetFrameText(CB_OpenText, "Книжка");
    Jass::SetFrameRelativePoint(CB_OpenText, Jass::FRAMEPOINT_CENTER, CB_OpenBtn, Jass::FRAMEPOINT_CENTER, 0.0, 0.0);
    Jass::ShowFrame(CB_OpenText, true);
    Jass::TriggerRegisterFrameEvent(openBtnTrg, CB_OpenBtn, Jass::FRAMEEVENT_CONTROL_CLICK);


    CB_GridBackdrop = Jass::CreateFrameByType("SIMPLEFRAME", "CB_GridBG", gameUI, "", CB_FrameCtx);
    CB_FrameCtx++;
    Jass::ClearFrameAllPoints(CB_GridBackdrop);
    Jass::SetFrameSize(CB_GridBackdrop, gridW, gridH);
    Jass::SetFrameAbsolutePoint(CB_GridBackdrop, Jass::FRAMEPOINT_TOPRIGHT, 0.79, CB_GRID_ORIGIN_Y);
    Jass::SetFrameTextureEx(CB_GridBackdrop, 0,
        "UI\\Widgets\\EscMenu\\Orc\\orc-options-menu-background", false, "UI\\Widgets\\EscMenu\\Orc\\orc-options-menu-border", Jass::BORDER_FLAG_ALL);
    Jass::SetFramePriority(CB_GridBackdrop, 0);
    Jass::ShowFrame(CB_GridBackdrop, false);

    // Заголовок
    CB_GridTitle = CB_CreateText(CB_GridBackdrop, 0.013, "|cffffcc00Книга Крафтов|r");
    Jass::SetFrameRelativePoint(CB_GridTitle, Jass::FRAMEPOINT_TOP,
        CB_GridBackdrop, Jass::FRAMEPOINT_TOP, 0, -0.008);
    Jass::SetFrameSize(CB_GridTitle, gridW - 0.04, 0.018);

    // Кнопка закрытия [X]
    CB_CloseBtn = CB_CreateButton(CB_GridBackdrop, 0.018);
    Jass::SetFrameRelativePoint(CB_CloseBtn, Jass::FRAMEPOINT_TOPRIGHT,
        CB_GridBackdrop, Jass::FRAMEPOINT_TOPRIGHT, -0.003, -0.003); 
    Jass::SetFrameTexture(CB_CloseBtn, "ReplaceableTextures\\CommandButtons\\BTNCancel.blp", 1, true);
    framehandle tooltip = CB_CreateTooltip(CB_CloseBtn, 1000);
    Jass::SetFrameText(tooltip, "Закрыть");

    // ═══════ Кнопки сетки ═══════
    trigger gridClickTrg  = Jass::CreateTrigger();

    for (int i = 0; i < itemsPerPage; i++) {
        int col = Jass::MathIntegerModulo(i, CB_GRID_COLS);
        int row = i / CB_GRID_COLS;
        float bx = 0.010 + col * (CB_CELL_SIZE + CB_CELL_GAP);
        float by = -0.030 - row * (CB_CELL_SIZE + CB_CELL_GAP);

        CB_GridBtns[i] = CB_CreateButton(CB_GridBackdrop, CB_CELL_SIZE);
        Jass::SetFrameRelativePoint(CB_GridBtns[i], Jass::FRAMEPOINT_TOPLEFT,
            CB_GridBackdrop, Jass::FRAMEPOINT_TOPLEFT, bx, by);
        Jass::SetFrameTexture(CB_GridBtns[i], "ReplaceableTextures\\CommandButtons\\BTNPatrol.blp", 1, true);
        Jass::ShowFrame(CB_GridBtns[i], false);
        tooltip = CB_CreateTooltip(CB_GridBtns[i], i);
        Jass::SetFrameText(tooltip, "Название предмета");


        Jass::TriggerRegisterFrameEvent(gridClickTrg, CB_GridBtns[i], Jass::FRAMEEVENT_CONTROL_CLICK);
    }

    // Навигация по страницам сетки
    float navOffY = -0.030 - CB_GRID_ROWS * (CB_CELL_SIZE + CB_CELL_GAP) - 0.008;

    CB_GridPrevBtn = CB_CreateButton(CB_GridBackdrop, 0.020);
    Jass::SetFrameRelativePoint(CB_GridPrevBtn, Jass::FRAMEPOINT_CENTER,
        CB_GridBackdrop, Jass::FRAMEPOINT_TOP, -0.03, navOffY);
    Jass::SetFrameTexture(CB_GridPrevBtn, "ReplaceableTextures\\CommandButtons\\BTNReplay-SpeedDown.blp", 1, true);
    tooltip = CB_CreateTooltip(CB_GridPrevBtn, 1001);
        Jass::SetFrameText(tooltip, "Предыдущая страница");

    CB_GridPageText = CB_CreateText(CB_GridBackdrop, 0.011, "1/1");
    Jass::SetFrameRelativePoint(CB_GridPageText, Jass::FRAMEPOINT_CENTER,
        CB_GridBackdrop, Jass::FRAMEPOINT_TOP, 0, navOffY);
    Jass::SetFrameSize(CB_GridPageText, 0.05, 0.015);

    CB_GridNextBtn = CB_CreateButton(CB_GridBackdrop, 0.020);
    Jass::SetFrameRelativePoint(CB_GridNextBtn, Jass::FRAMEPOINT_CENTER,
        CB_GridBackdrop, Jass::FRAMEPOINT_TOP, 0.03, navOffY);
    Jass::SetFrameTexture(CB_GridNextBtn, "ReplaceableTextures\\CommandButtons\\BTNReplay-SpeedUp.blp", 1, true);
    tooltip = CB_CreateTooltip(CB_GridNextBtn, 1002);
        Jass::SetFrameText(tooltip, "Следующая страница");


    // ═══════ Детальная панель (слева от сетки) ═══════
    CB_DetailBackdrop = Jass::CreateFrameByType("SIMPLEFRAME", "CB_DetailBG", gameUI, "", CB_FrameCtx);
    CB_FrameCtx++;
    Jass::ClearFrameAllPoints(CB_DetailBackdrop);
    Jass::SetFrameSize(CB_DetailBackdrop, gridW+0.0045, gridH);
    Jass::SetFrameRelativePoint(CB_DetailBackdrop, Jass::FRAMEPOINT_TOPRIGHT,
        CB_GridBackdrop, Jass::FRAMEPOINT_TOPLEFT, -0.001, 0);
    Jass::SetFrameTextureEx(CB_DetailBackdrop, 0,
        "UI\\Widgets\\EscMenu\\Orc\\orc-options-menu-background", false, "UI\\Widgets\\EscMenu\\Orc\\orc-options-menu-border", Jass::BORDER_FLAG_ALL);
    Jass::SetFramePriority(CB_DetailBackdrop, 0);
    Jass::ShowFrame(CB_DetailBackdrop, false);

    // Название предмета
    CB_DetailTitle = CB_CreateText(CB_DetailBackdrop, 0.011, "");
    Jass::SetFrameRelativePoint(CB_DetailTitle, Jass::FRAMEPOINT_TOP,
        CB_DetailBackdrop, Jass::FRAMEPOINT_TOP, 0, -0.006);
    Jass::SetFrameSize(CB_DetailTitle, gridW - 0.02, 0.01);

    // Описание предмета
    CB_DetailDesc = CB_CreateText(CB_DetailBackdrop, 0.009, "");
    Jass::SetFrameRelativePoint(CB_DetailDesc, Jass::FRAMEPOINT_TOPLEFT,
        CB_DetailTitle, Jass::FRAMEPOINT_BOTTOMLEFT, 0, -0.006);
    Jass::SetFrameSize(CB_DetailDesc, gridW - 0.02, 0.20);
    Jass::SetFrameTextAlignment(CB_DetailDesc, Jass::TEXT_JUSTIFY_TOP, Jass::TEXT_JUSTIFY_LEFT);


    // ═══════ Секция рецепта ═══════
    float recipeOffY = -0.21;

    CB_RecipeLabel = CB_CreateText(CB_DetailBackdrop, 0.011, "");
    Jass::SetFrameRelativePoint(CB_RecipeLabel, Jass::FRAMEPOINT_TOP,
        CB_DetailBackdrop, Jass::FRAMEPOINT_TOP, 0, recipeOffY);
    Jass::SetFrameSize(CB_RecipeLabel, gridW * 0.5, 0.015);

    // Стрелки рецептов
    CB_RecipePrevBtn = CB_CreateButton(CB_DetailBackdrop, 0.016);
    Jass::SetFrameRelativePoint(CB_RecipePrevBtn, Jass::FRAMEPOINT_RIGHT,
        CB_RecipeLabel, Jass::FRAMEPOINT_LEFT, -0.0002, 0);
    Jass::SetFrameTexture(CB_RecipePrevBtn, "ReplaceableTextures\\CommandButtons\\BTNReplay-SpeedDown.blp", 1, true);
    Jass::ShowFrame(CB_RecipePrevBtn, false);
    tooltip = CB_CreateTooltip(CB_RecipePrevBtn, 1003);
        Jass::SetFrameText(tooltip, "Предыдущая страница");

    CB_RecipeNextBtn = CB_CreateButton(CB_DetailBackdrop, 0.016);
    Jass::SetFrameRelativePoint(CB_RecipeNextBtn, Jass::FRAMEPOINT_LEFT,
        CB_RecipeLabel, Jass::FRAMEPOINT_RIGHT, 0.0002, 0);
    Jass::SetFrameTexture(CB_RecipeNextBtn, "ReplaceableTextures\\CommandButtons\\BTNReplay-SpeedUp.blp", 1, true);
    Jass::ShowFrame(CB_RecipeNextBtn, false);
    tooltip = CB_CreateTooltip(CB_RecipeNextBtn, 1004);
        Jass::SetFrameText(tooltip, "Следующая страница");

    float ingIconSize = 0.024;
    float ingGap = 0.0002;
    float ingRowOffY = recipeOffY - 0.020;
    float ingTotalW = MAX_CRAFT_INGREDIENTS * (ingIconSize + ingGap) + ingGap + ingIconSize;
    float ingStartX = (gridW + 0.0035 - ingTotalW) / 2.0;

    for (int i = 0; i < MAX_CRAFT_INGREDIENTS; i++) {
        float ix = ingStartX + i * (ingIconSize + ingGap);

        // Иконка ингредиента (BACKDROP — не кликабельный, но регистрируем hover)
        CB_RecipeIcons[i] = Jass::CreateFrameByType("SIMPLEBUTTON", "CB_RecBtn", CB_DetailBackdrop, "", CB_FrameCtx);
        CB_FrameCtx++;
        Jass::ClearFrameAllPoints(CB_RecipeIcons[i]);
        Jass::SetFrameSize(CB_RecipeIcons[i], ingIconSize, ingIconSize);
        Jass::SetFrameRelativePoint(CB_RecipeIcons[i], Jass::FRAMEPOINT_TOPLEFT,
            CB_DetailBackdrop, Jass::FRAMEPOINT_TOPLEFT, ix, ingRowOffY);
        Jass::SetFrameTexture(CB_RecipeIcons[i], "ReplaceableTextures\\CommandButtons\\BTNPatrol.blp", 1, true);
        Jass::ShowFrame(CB_RecipeIcons[i], false);
        tooltip = CB_CreateTooltip(CB_RecipeIcons[i], 100+i);
        Jass::SetFrameText(tooltip, "Название предмета");

        Jass::TriggerRegisterFrameEvent(gridClickTrg,   CB_RecipeIcons[i], Jass::FRAMEEVENT_CONTROL_CLICK);

        // Текст "xN" под иконкой
        CB_RecipeCountTexts[i] = CB_CreateText(CB_DetailBackdrop, 0.008, "");
        Jass::SetFrameRelativePoint(CB_RecipeCountTexts[i], Jass::FRAMEPOINT_TOP,
            CB_RecipeIcons[i], Jass::FRAMEPOINT_BOTTOM, 0, -0.00);
        Jass::SetFrameSize(CB_RecipeCountTexts[i], ingIconSize, 0.012);
    }

    // Иконка результата
    CB_ResultIcon = Jass::CreateFrameByType("SIMPLEFRAME", "CB_ResIco", CB_DetailBackdrop, "", CB_FrameCtx);
    CB_FrameCtx++;
    Jass::ClearFrameAllPoints(CB_ResultIcon);
    Jass::SetFrameSize(CB_ResultIcon, ingIconSize, ingIconSize);
    Jass::SetFrameRelativePoint(CB_ResultIcon, Jass::FRAMEPOINT_LEFT,
        CB_RecipeIcons[MAX_CRAFT_INGREDIENTS - 1], Jass::FRAMEPOINT_RIGHT, 0.002, 0);
    Jass::ShowFrame(CB_ResultIcon, false);

    CB_ResultText = CB_CreateText(CB_DetailBackdrop, 0.008, "");
    Jass::SetFrameRelativePoint(CB_ResultText, Jass::FRAMEPOINT_TOP,
        CB_ResultIcon, Jass::FRAMEPOINT_BOTTOM, 0, -0.001);
    Jass::SetFrameSize(CB_ResultText, ingIconSize, 0.012);


    // ═══════ Секция "Где используется" ═══════
    float usedInOffY = -0.035 + ingRowOffY - ingIconSize;

    CB_UsedInLabel = CB_CreateText(CB_DetailBackdrop, 0.010, "");
    Jass::SetFrameRelativePoint(CB_UsedInLabel, Jass::FRAMEPOINT_TOPLEFT,
        CB_DetailBackdrop, Jass::FRAMEPOINT_TOPLEFT, 0.010, usedInOffY);
    Jass::SetFrameSize(CB_UsedInLabel, CB_DETAIL_W - 0.02, 0.015);
    Jass::SetFrameTextAlignment(CB_UsedInLabel, Jass::TEXT_JUSTIFY_CENTER, Jass::TEXT_JUSTIFY_LEFT);

    float uiIconSize = 0.024;
    float uiGap = 0.0002;

    trigger usedInClickTrg = Jass::CreateTrigger();

    for (int i = 0; i < usedInPerPage; i++) {
        int col = Jass::MathIntegerModulo(i, CB_USEDIN_COLS);
        int row = i / CB_USEDIN_COLS;
        float ux = 0.005 + col * (uiIconSize + uiGap);
        float uy = usedInOffY - 0.018 - row * (uiIconSize + uiGap);

        CB_UsedInBtns[i] = CB_CreateButton(CB_DetailBackdrop, uiIconSize);
        Jass::SetFrameRelativePoint(CB_UsedInBtns[i], Jass::FRAMEPOINT_TOPLEFT,
            CB_DetailBackdrop, Jass::FRAMEPOINT_TOPLEFT, ux, uy);
        Jass::ShowFrame(CB_UsedInBtns[i], false);
        tooltip = CB_CreateTooltip(CB_UsedInBtns[i], 200+i);
        Jass::SetFrameText(tooltip, "Название предмета");

        Jass::TriggerRegisterFrameEvent(usedInClickTrg, CB_UsedInBtns[i], Jass::FRAMEEVENT_CONTROL_CLICK);
    }

    // Used-In навигация
    float uiNavOffY = usedInOffY - 0.018 - CB_USEDIN_ROWS * (uiIconSize + uiGap) - 0.005;

    CB_UsedInPrevBtn = CB_CreateButton(CB_DetailBackdrop, 0.016);
    Jass::SetFrameRelativePoint(CB_UsedInPrevBtn, Jass::FRAMEPOINT_TOPLEFT,
        CB_DetailBackdrop, Jass::FRAMEPOINT_TOPLEFT, gridW * 0.25, uiNavOffY);
    Jass::SetFrameTexture(CB_UsedInPrevBtn, "ReplaceableTextures\\CommandButtons\\BTNReplay-SpeedDown.blp", 1, true);
    Jass::ShowFrame(CB_UsedInPrevBtn, false);
    tooltip = CB_CreateTooltip(CB_UsedInPrevBtn, 1006);
        Jass::SetFrameText(tooltip, "Предыдущая страница");

    CB_UsedInPageText = CB_CreateText(CB_DetailBackdrop, 0.009, "1/1");
    Jass::SetFrameRelativePoint(CB_UsedInPageText, Jass::FRAMEPOINT_TOPLEFT,
        CB_DetailBackdrop, Jass::FRAMEPOINT_TOPLEFT, gridW * 0.4, uiNavOffY);
    Jass::SetFrameSize(CB_UsedInPageText, 0.05, 0.015);

    CB_UsedInNextBtn = CB_CreateButton(CB_DetailBackdrop, 0.016);
    Jass::SetFrameRelativePoint(CB_UsedInNextBtn, Jass::FRAMEPOINT_TOPLEFT,
        CB_DetailBackdrop, Jass::FRAMEPOINT_TOPLEFT, gridW * 0.6, uiNavOffY);
    Jass::SetFrameTexture(CB_UsedInNextBtn, "ReplaceableTextures\\CommandButtons\\BTNReplay-SpeedUp.blp", 1, true);
    Jass::ShowFrame(CB_UsedInNextBtn, false);
    tooltip = CB_CreateTooltip(CB_UsedInNextBtn, 1007);
        Jass::SetFrameText(tooltip, "Следующая страница");
    

    // ═══════════════════════════════════════════════════════════════════════
    // Trigger Actions
    // ═══════════════════════════════════════════════════════════════════════
    Jass::TriggerAddAction(openBtnTrg, function() {
        int pid = Jass::GetPlayerId(Jass::GetTriggerPlayer());
        OpenCraftBrowser(pid);
    });

    // --- Grid click → выбрать предмет ---
    Jass::TriggerAddAction(gridClickTrg, function() {
        player p = Jass::GetTriggerPlayer();
        int pid = Jass::GetPlayerId(p);
        framehandle f = Jass::GetTriggerFrame();
        int itemId = Jass::LoadInteger(CB_HT, Jass::GetHandleId(f), 'itid');
        if (itemId > 0) {
            CB_SelectedItemTypeId[pid] = itemId;
            CB_RecipePage[pid] = 0;
            CB_UsedInPage[pid] = 0;
            CB_UpdateDetail(pid);
        }
    });

    // --- Close button ---
    trigger closeTrg = Jass::CreateTrigger();
    Jass::TriggerRegisterFrameEvent(closeTrg, CB_CloseBtn, Jass::FRAMEEVENT_CONTROL_CLICK);
    Jass::TriggerAddAction(closeTrg, function() {
        int pid = Jass::GetPlayerId(Jass::GetTriggerPlayer());
        CB_Hide(pid);
        if (CF_ActivePanelId[pid] == CRAFT_PANEL_ID) CF_ActivePanelId[pid] = 0;
    });

    // --- Grid page prev ---
    trigger gridPrevTrg = Jass::CreateTrigger();
    Jass::TriggerRegisterFrameEvent(gridPrevTrg, CB_GridPrevBtn, Jass::FRAMEEVENT_CONTROL_CLICK);
    Jass::TriggerAddAction(gridPrevTrg, function() {
        int pid = Jass::GetPlayerId(Jass::GetTriggerPlayer());
        if (CB_GridPage[pid] > 0) {
            CB_GridPage[pid]--;
            CB_UpdateGrid(pid);
        }
    });

    // --- Grid page next ---
    trigger gridNextTrg = Jass::CreateTrigger();
    Jass::TriggerRegisterFrameEvent(gridNextTrg, CB_GridNextBtn, Jass::FRAMEEVENT_CONTROL_CLICK);
    Jass::TriggerAddAction(gridNextTrg, function() {
        int pid = Jass::GetPlayerId(Jass::GetTriggerPlayer());
        int ipp = CB_GRID_COLS * CB_GRID_ROWS;
        int tp = (int(CB_FilteredItems.length()) + ipp - 1) / ipp;
        if (CB_GridPage[pid] < tp - 1) {
            CB_GridPage[pid]++;
            CB_UpdateGrid(pid);
        }
    });

    // --- Recipe prev ---
    trigger recipePrevTrg = Jass::CreateTrigger();
    Jass::TriggerRegisterFrameEvent(recipePrevTrg, CB_RecipePrevBtn, Jass::FRAMEEVENT_CONTROL_CLICK);
    Jass::TriggerAddAction(recipePrevTrg, function() {
        int pid = Jass::GetPlayerId(Jass::GetTriggerPlayer());
        if (CB_RecipePage[pid] > 0) {
            CB_RecipePage[pid]--;
            CB_UpdateDetail(pid);
        }
    });

    // --- Recipe next ---
    trigger recipeNextTrg = Jass::CreateTrigger();
    Jass::TriggerRegisterFrameEvent(recipeNextTrg, CB_RecipeNextBtn, Jass::FRAMEEVENT_CONTROL_CLICK);
    Jass::TriggerAddAction(recipeNextTrg, function() {
        int pid = Jass::GetPlayerId(Jass::GetTriggerPlayer());
        int itemId = CB_SelectedItemTypeId[pid];
        ItemCraftData@ icd = GetItemCraftData(itemId);
        if (icd !is null && CB_RecipePage[pid] < icd.GetRecipeCount() - 1) {
            CB_RecipePage[pid]++;
            CB_UpdateDetail(pid);
        }
    });

    // --- Used-In click → перейти к выбранному предмету ---
    Jass::TriggerAddAction(usedInClickTrg, function() {
        int pid = Jass::GetPlayerId(Jass::GetTriggerPlayer());
        framehandle f = Jass::GetTriggerFrame();
        int itemId = Jass::LoadInteger(CB_HT, Jass::GetHandleId(f), 'itid');
        if (itemId > 0) {
            CB_SelectedItemTypeId[pid] = itemId;
            CB_RecipePage[pid] = 0;
            CB_UsedInPage[pid] = 0;
            CB_UpdateDetail(pid);
        }
    });

    // --- Used-In page prev ---
    trigger uiPrevTrg = Jass::CreateTrigger();
    Jass::TriggerRegisterFrameEvent(uiPrevTrg, CB_UsedInPrevBtn, Jass::FRAMEEVENT_CONTROL_CLICK);
    Jass::TriggerAddAction(uiPrevTrg, function() {
        int pid = Jass::GetPlayerId(Jass::GetTriggerPlayer());
        if (CB_UsedInPage[pid] > 0) {
            CB_UsedInPage[pid]--;
            CB_UpdateDetail(pid);
        }
    });

    // --- Used-In page next ---
    trigger uiNextTrg = Jass::CreateTrigger();
    Jass::TriggerRegisterFrameEvent(uiNextTrg, CB_UsedInNextBtn, Jass::FRAMEEVENT_CONTROL_CLICK);
    Jass::TriggerAddAction(uiNextTrg, function() {
        int pid = Jass::GetPlayerId(Jass::GetTriggerPlayer());
        int itemId = CB_SelectedItemTypeId[pid];
        ItemCraftData@ icd = GetItemCraftData(itemId);
        if (icd !is null) {
            int uipp = CB_USEDIN_COLS * CB_USEDIN_ROWS;
            int tp = (icd.GetUsedInCount() + uipp - 1) / uipp;
            if (CB_UsedInPage[pid] < tp - 1) {
                CB_UsedInPage[pid]++;
                CB_UpdateDetail(pid);
            }
        }
    });

    // Регистрация в менеджере панелей
    CF_RegisterPanel(CRAFT_PANEL_ID, @CB_Hide);
}
