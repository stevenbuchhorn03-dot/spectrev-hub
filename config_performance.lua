-- =============================================================================
-- PERFORMANCE CONFIGURATION
-- =============================================================================
-- This file centralizes CPU/network optimization toggles and anti-spam timings.
-- It is loaded after `config.lua` and overrides defaults when needed.
--
-- İlk giriş / getInventory’de saniye+ süre: çoğunlukla MySQL (uzak host, büyük `items` LONGTEXT,
-- tablo kilidi). `devix_inventory` için (identifier,type) PK olmalı; oxmysql `ensure` sırası
-- envanterden önce; sunucuda slow_query_log ile doğrula. Lua tarafı tek SQL ile player+quickslots+clothes
-- birleştirerek RTT sayısını düşürür (sv_db + BuildInventoryResponse).

-- Merge repeated inventory refresh requests into one server callback.
-- 0 = disabled (every refresh request is processed immediately).
Config.InventoryRefreshDebounceMs = 700

-- For shared second panels (trunk/stash/glovebox/locker/loot):
-- send a lightweight grid patch to other viewers instead of full getInventory.
Config.SecondPanelPeerGridPatch = true

-- For useItem flows (ammo, etc.):
-- when only player inventory needs refresh, send a lightweight snapshot.
-- If a second panel is open, code may still fallback to full refresh.
Config.UseItemLightInventoryRefresh = true

-- ItemList'te `skipServerUseItem = true` olan eşyalar: NUI useItem client callback'inden sonra
-- `DEVIX_INV_EVT("server:useItem")` (klasör adı + :server:useItem) tetiklenmez (ox: tamamen client kalan eşyalar; ehliyet/QB usable için kullanma).

-- Drop <-> player transfer:
-- false = skip full post-transfer snapshot (recommended for lower CPU).
-- true  = always force full snapshot after drop transfer.
Config.FullSnapshotAfterDropTransfer = false

-- Debounce framework-side client sync payloads (QB/QBX SetPlayerData/items).
Config.FrameworkSyncDebounceMs = 350

-- useItem anti-spam for the same player+item+slot combination.
-- weapon_* is intentionally excluded to keep weapon equip responsive.
Config.UseItemSpamCooldownMs = 650

-- Global anti-spam across all non-weapon useItem actions per player.
Config.UseItemGlobalCooldownMs = 750
-- Hard in-flight window for useItem (item fark etmeksizin kaynak oyuncu bazli). 0 = kapali.
Config.UseItemInFlightWindowMs = 350
-- useItem rate limit (source basina saniyede max islem). 0 = kapali.
Config.UseItemMaxPerSecond = 3

-- Extra anti-spam for items that usually do not consume amount
-- (e.g. GPS/tablet toggles). 0 = disabled.
Config.UseItemNoConsumeCooldownMs = 900

-- setQuickSlot event anti-spam (drag/drop flood protection).
Config.QuickSlotSetCooldownMs = 700

-- transferBetweenInventories anti-spam per player.
Config.ServerTransferSpamCooldownMs = 500
-- transferBetweenInventories rate limit (source basina saniyede max islem). 0 = kapali.
Config.ServerTransferMaxPerSecond = 4

-- Ox_inventory benzeri: transfer grid'inde yalnızca kayıtlı eşya adları (GetSharedItemInfo / ItemList).
-- false = eski davranış (bilinmeyen adlar da sanitize ile geçer; özel script eşyaları kırılmaz).
-- true  = kayıtsız isimde tüm transfer reddedilir (güvenlik sıkılaştırma).
Config.TransferRequireRegisteredItems = true

-- ox_inventory: kapatınca / unload — devix write-queue için NUI kapanışında oyuncu + ikinci panel grid flush.
-- false = yalnızca SaveInterval thread + playerDropped (daha az SQL).
Config.FlushInventoryWritesOnNuiClose = false

-- Grid SQL yazım debounce (ms). Bellek (_gridCache) anlık; bu süre write-queue flush periyodu.
Config.SaveInterval = 3500

-- Periyodik güvenlik yazımı (dakika). ox_inventory'deki AutosaveInterval gibi davranır.
-- Her N dakikada bir tüm aktif oyuncuların envanterini zorla DB'ye flush eder.
-- Normal akışta SaveInterval yeterlidir; bu thread yalnızca bug/kaçırılmış QueueWrite için güvence sağlar.
Config.AutosaveInterval = 10

-- Durability persistence throttle while shooting.
-- Grid cache is updated immediately; DB writes are interval-limited.
Config.WeaponDurabilitySaveInterval = 2500

-- Minimum interval for durability-triggered inventory refresh to same player.
-- 0 = send every time (higher CPU/network).
Config.WeaponDurabilityClientRefreshMinMs = 1800

-- Client durability polling rate while firing.
-- Lower values increase event frequency and server load.
Config.WeaponDurabilityClientPollMs = 180

-- Throttle getInventory ammo sync (SyncEquippedWeaponAmmoToGrid).
-- 0 = run on every open request.
Config.InventoryOpenAmmoSyncThrottleMs = 900

-- Send full locales only on first open; skip on reopen for lower payload cost.
Config.OmitFullLocalesOnInventoryReopen = true

-- Skip generating/sending lightweight snapshots while UI is closed
-- (based on LocalPlayer.state.devixInvLightUi from client).
Config.SkipLightInventoryRefreshWhenUiClosed = true

-- QB/QBX sync mode:
-- true  = send lightweight item payload (`setPlayerItems`)
-- false = send full `QBCore:Player:SetPlayerData` payload.
Config.LightweightFrameworkSyncOnItemChange = true

-- Open inventory safety pass: ResolveGridOverlaps (CanPlaceAt+FindFreeSlot) pahali olabilir.
-- false = envanter acilisinda overlap fix calismaz (onerilen; hot-path CPU dusuk)
-- true  = rev degisince acilista overlap fix uygula
Config.ResolveGridOverlapsOnOpen = false
-- 0 = limit yok. >0 ise item sayisi bu esigi asarsa overlap fix atlanir.
Config.ResolveGridOverlapsOnOpenMaxItems = 0

-- Solo open (panels=0): player + clothes icindeki bag contents/contentsWeight hesaplamasini atla.
-- Bu hesap her bag icin ek LoadGridInventory cagirir; buyuk envanterlerde BuildInventoryResponse'u ciddi sisirir.
-- false yaparsan eski davranis (tooltipte bag contents aninda) geri gelir.
Config.SkipNestedBagMetaOnPrimaryOpen = true

-- PlayerLoaded/onResourceStart: quickslots+clothes bundle satirlarindan bellek cache (LoadQuickSlotsAndClothesCombined);
-- PrewarmQuickSlotsAndClothesOnPlayerLoaded kaldirildi — quick cache bos birakilmiyor.

-- Resource start itemDefs prewarm (Config.ItemList) JsonSafeCopy; batch + yield. 0 = kapali.
-- __devix_static_response_parts (itemLimit + UI sabitleri) resource start'ta Wait(0) ile hemen
-- hazirlanir (ItemDefsPrewarm'dan bagimsiz); yoksa ilk getInventory BUILD(first) tum ItemList'i tek karede tarar.
Config.ItemDefsPrewarmBatchSize = 0

-- QBCore:Server:PlayerLoaded: LoadInventoryRowsForTypes + LoadGridInventory + sync ayni event tick'inde
-- resmon'u siser. 2 = iki kez Wait(0) ile yuk dagitilir. 0 = eski davranis (tam senkron).
Config.PlayerLoadedInventoryDeferFrames = 4

-- PlayerLoaded sonrasinda ikinci dalga zorunlu sync (SyncPlayerInventoryToClient).
-- 0/false = kapali (onerilen; join spike azalir)
-- >0 = belirtilen ms sonra tetikle.
Config.PlayerLoadedPostSyncDelayMs = 0

-- Client ilk item callback senkronu:
-- false = framework cache'den (QBCore/QBX PlayerData.items) beslenir; getInventory RPC atilmaz.
-- true  = eski davranis, server getInventory callback'i atilir.
Config.InitialItemCallbackServerSyncOnPlayerLoaded = false
Config.InitialItemCallbackServerSyncOnClientResourceStart = false

-- =============================================================================
-- DEBUG FLAGS THAT IMPACT HOT PATH COST
-- =============================================================================
-- Keep these false in production if your target is minimum CPU usage.

-- Oyuncu girişi (QBCore:Server:PlayerLoaded): aşamalı süre + cpuSeg~ (resmon ile korelasyon).
-- sql_playerjoin_bundle_await satırındaki yüksek d= çoğunlukla MySQL await (ağ + LONGTEXT), saf Lua grid değil.
-- Ayrıca txAdmin / server.cfg: setr devix_inv_playerloaded_perf 1
Config.DebugPlayerLoadedPerf = true

-- false: tek sorgu IN(player,quickslots,clothes). true: önce player satırı, Wait(0), sonra quickslots+clothes (2 RTT;
-- uzak DB'de toplam süre artabilir; tek karede tek büyük result spike'ı bölmek için dene).
Config.PlayerLoadedInventorySqlSplit = false

-- Verbose per-useItem logs (can be expensive under spam).
Config.DebugVerboseUseItem = false
-- [use-clothes] perf log esigi. Bu ms altindaki satirlari yazdirma. 0 = hepsi.
Config.DebugUseItemClothesPerfMinMs = 15

-- useItem / ox köprü / quickslot / mermi yolu: resmon ile korelasyon (F8). Production'da false tut.
-- txAdmin / server.cfg: setr devix_inv_resmon_useitem 1 (istemci + sunucu)
Config.DebugResmonUseItemPrint = true

-- Verbose RemoveItem grid-name logs (string concat + large output).
Config.DebugVerboseRemoveItem = false

--- @param where "sv"|"cl"
--- @param tag string kısa etiket
--- @param detail? string|nil
function DevixInvResmonUseItemPrint(where, tag, detail)
    if not ((Config and Config.DebugResmonUseItemPrint == true) or (GetConvarInt("devix_inv_resmon_useitem", 0) == 1)) then
        return
    end
    local d = (detail ~= nil and tostring(detail) ~= "") and (" | " .. tostring(detail)) or ""
    print(("[devix-inv][resmon][useitem][%s] %s%s"):format(tostring(where), tostring(tag), d))
end
