#!/bin/bash
set -e

echo "=== HumanitZ 서버 파일 업데이트 중... ==="
steamcmd +force_install_dir /home/steam/serverfiles \
	+login anonymous \
    +app_update 2728330 -beta linuxbranch validate \
    +quit

echo "=== 서버 설정 확인 중... ==="
CONFIG_DIR="/home/steam/serverfiles/HumanitZServer/Saved/Config/LinuxServer"
mkdir -p "$CONFIG_DIR"

if [ ! -f "$CONFIG_DIR/GameServerSettings.ini" ]; then
    echo "=== ini 파일 없음, 환경변수로 초기 생성 ==="
    cat > "$CONFIG_DIR/GameServerSettings.ini" << EOF
[Host Settings]
ServerName="${SERVER_NAME:-HumanitZ [Dedicated]}"
Password="${SERVER_PASSWORD:-}"
SaveName="${SAVE_NAME:-DedicatedSaveMP}"
SearchID="HumanitZ_Dedicated"
AdminPass="${ADMIN_PASSWORD:-}"
MaxPlayers=${MAX_PLAYERS:-16}
ReserveSlots=0
RCONEnabled=${RCON_ENABLED:-false}
RConPort=8889
RCONPass="${RCON_PASSWORD:-}"
NoDeathFeedback=true
NoJoinFeedback=true
LimitedSpawns=false
UseGlobalBanList=true

[World Settings]
Version=35
XpMultiplier=${XP_MULTIPLIER:-1}
SaveIntervalSec=${SAVE_INTERVAL:-300}
PermaDeath=${PERMA_DEATH:-false}
OnDeath=${ON_DEATH:-2}
RespawnTimer=15
PVP=${PVP:-true}
LogoutTimer=30
AirDrop=true
AirDropInterval=1
WeaponBreak=true
MaxOwnedCars=2
MultiplayerSleep=false
LootRespawn=true
LootRespawnTimer=60
PickupRespawnTimer=90
RarityFood=${LOOT_RARITY:-2}
RarityDrink=${LOOT_RARITY:-2}
RarityMelee=${LOOT_RARITY:-2}
RarityRanged=${LOOT_RARITY:-2}
RarityAmmo=${LOOT_RARITY:-2}
RarityArmor=${LOOT_RARITY:-2}
RarityResources=${LOOT_RARITY:-2}
RarityOther=${LOOT_RARITY:-2}
ZombieDiffHealth=${ZOMBIE_HEALTH:-1}
ZombieDiffSpeed=${ZOMBIE_SPEED:-2}
ZombieDiffDamage=${ZOMBIE_DAMAGE:-3}
ZombieAmountMulti=${ZOMBIE_AMOUNT:-1}
HumanAmountMulti=1
ZombieDogMulti=1
ZombieRespawnTimer=90
HumanRespawnTimer=90
HumanHealth=2
HumanSpeed=2
HumanDamage=2
AnimalMulti=1
AnimalRespawnTimer=90
StartingSeason=1
DaysPerSeason=5
DayDur=40
NightDur=20
VitalDrain=${VITAL_DRAIN:-1}
DogEnabled=true
RecruitDog=true
DogNum=8
BuildingHealth=1
CompanionHealth=1
CompanionDmg=1
AllowDismantle=true
AllowHouseDismantle=true
Territory=true
FreeBuild=true
NoBuildZone=true
Decay=7
BuildingDecay=7
PickupCleanup=6
FakeBuildingCleanup=3000
FoodDecay=1
GenFuel=1
Sleep=true
FreezeTime=true
MapSeg0=12
MapSeg1=20
MapSeg2=60
Voip=true
AIEvent=2
Weather_ClearSky=1
Weather_Cloudy=1
Weather_Foggy=1
Weather_LightRain=1
Weather_Rain=1
Weather_Thunderstorm=1
Weather_LightSnow=1
Weather_Snow=1
Weather_Blizzard=1
EOF
    echo "=== ini 파일 생성 완료 ==="
else
    echo "=== ini 파일 존재, 기존 설정 유지 ==="
fi

echo "=== 서버 시작 ==="
cd /home/steam/serverfiles
chmod +x HumanitZServer.sh
exec ./HumanitZServer.sh -log -port=${PORT:-7778} -queryport=${QUERY_PORT:-27018}