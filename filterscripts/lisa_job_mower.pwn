#define OCMD_BEFORE_CALLBACK 1
#define FILTERSCRIPT
#include <a_samp>
#include <a_mysql>
#include <ocmd>
#include <sscanf2>

#define MYSQL_HOST "127.0.0.1"
#define MYSQL_USER "root"
#define MYSQL_PASS ""
#define MYSQL_DB "lisa"

#define MAX_CHECKPOINTS 10

#define DIALOG_REGISTER  1403
#define DIALOG_LOGIN 2401
#define DIALOG_MM_MAIN 1000
#define DIALOG_MM_SERVICE 1001
#define DIALOG_MM_PROFIL 1002
#define DIALOG_MM_NAVIGATION 1003
#define DIALOG_MM_ADMIN 1004

#define DIALOG_BANK_MAIN 1010
#define DIALOG_BANK_BALANCE 1011
#define DIALOG_BANK_DEPOSIT 1012
#define DIALOG_BANK_PAYOUT 1013

#define DIALOG_MM_MAIN_TEXT "Services\nNavigation\nMein Profil\n"

#define DIALOG_BANK_MAIN_TEXT "Kontostand\nEinzahlung\nAuszahlung\n"

new handle; //MySQL-Handle

enum player {
	id,
	name[MAX_PLAYER_NAME+1],
	skin,
	money,
	bank_balance,
	score,
	nextScore,
	timerScore,
	textDraw,
	bool:showTextDraw,
	bool:inJob,
	company,
	bool:trailerAttached,
	maxTrailerCapacity,
	currentTrailerCapacity,
	nextCpPosX,
	nextCpPosY,
	nextCpPosZ,

}

enum pickup {
	id,
	internal,
	model,
	type,
	Float:pos_x,
	Float:pos_y,
	Float:pos_z,
	world,
	description[256],
	company,
}

enum vehicle {
	id,
	internal,
	model,
	Float:pos_x,
	Float:pos_y,
	Float:pos_z,
	Float:rot,
	color_1,
	color_2,
	respawn_delay,
	numberplate[64],
	owner,
	company,
}

enum checkpoint {
	id,
	internal,
	Float:pos_x,
	Float:pos_y,
	Float:pos_z,
	Float:size,
	usuage, // 1 = Navigation | 2 = Job
	position[256], // Position-String z.B. "BSN, Los Santos"
	company
}



new PlayerInfo[MAX_PLAYERS][player];
new PickUps[MAX_PICKUPS][pickup];
//new Objects[MAX_OBJECTS][object];
new Vehicles[MAX_VEHICLES][vehicle];
new CheckPoints[MAX_CHECKPOINTS][checkpoint];
new CurrentCheckPoint[MAX_CHECKPOINTS][checkpoint];

main () {
	print("\n----------------------------------");
	print("Load Filterscript: Job - Mower");
	print("----------------------------------\n");
}

public OnFilterScriptInit () {
	MySQL_SetupConnection();
	mysql_log(ALL);

	mysql_pquery(handle, "SELECT * FROM `pickups` WHERE `company` = 2", "LoadPickUps");
	mysql_pquery(handle, "SELECT * FROM `checkpoints` WHERE `company` = 2", "LoadCheckpoints");
	mysql_pquery(handle, "SELECT * FROM `vehicles` WHERE `company` = 2", "LoadVehicles");

	return 1;
}

public OnFilterScriptExit() {
	mysql_close();

	return 1;
}

public OnPlayerSpawn (playerid) {
	new playername[MAX_PLAYER_NAME + 1];
	GetPlayerName(playerid, playername, sizeof(playername));
	PlayerInfo[playerid][name] = playername;

	new query[256];
	mysql_format(handle, query, sizeof(query), "SELECT id, skin, job, job_score, job_timer FROM accounts WHERE name = '%e'", PlayerInfo[playerid][name]);
	mysql_pquery(handle, query, "OnUserLoadJob", "d", playerid);

	return 1;
}

public OnPlayerDeath (playerid, killerid, reason) {
	return 1;
}

public OnVehicleSpawn (vehicleid) {
	return 1;
}

public OnVehicleDeath (vehicleid, killerid) {
	return 1;
}

public OnPlayerText (playerid, text[]) {
	return 1;
}

public OnPlayerCommandText (playerid, cmdtext[]) {
	return 0;
}

public OnPlayerEnterVehicle (playerid, vehicleid, ispassenger) {
	new string[256];
	for (new i = 0; i <= MAX_VEHICLES; i++) {
		if (Vehicles[i][internal] == vehicleid && Vehicles[i][company] == 2){
			//TODO Check if a trailer is attached and if this trailer is one of the company
			// && IsTrailerAttachedToVehicle(vehicleid)) {
			//new trailer = GetVehicleTrailer(GetPlayerVehicleID(playerid));
			//for (new i = 0; i < MAX_VEHICLES; i++) {
				//if (Vehicles[i][internal] == trailer) {
			if ( PlayerInfo[playerid][company] == 2 && PlayerInfo[playerid][inJob] == true && IsTrailerAttachedToVehicle(vehicleid)) {
				if (PlayerInfo[playerid][currentTrailerCapacity] == 0) {
					for (new i = 0; i <= MAX_CHECKPOINTS; i++) {
						if (CheckPoints[i][company] == 2 && CheckPoints[i][usuage] == 3) {
							CurrentCheckPoint[0][internal] = SetPlayerCheckpoint(playerid,CheckPoints[i][pos_x],CheckPoints[i][pos_y],CheckPoints[i][pos_z],CheckPoints[i][size]);
						}
					}
				}else{
					// do the rest of your tour
				}
			}
		}
	}
	return 1;
}

public OnPlayerExitVehicle (playerid, vehicleid) {
	return 1;
}

public OnPlayerStateChange (playerid, newstate, oldstate) {
	return 1;
}

public OnPlayerEnterCheckpoint (playerid) {
	if (CheckPoints[0][usuage] == 1) { // 1 = Navigation | 2 = Job
		DisablePlayerCheckpoint(playerid);
	}
	return 1;
}

public OnPlayerLeaveCheckpoint (playerid) {
	return 1;
}

public OnPlayerEnterRaceCheckpoint (playerid) {
	return 1;
}

public OnPlayerLeaveRaceCheckpoint (playerid) {
	return 1;
}

public OnRconCommand (cmd[]) {
	return 1;
}

public OnPlayerRequestSpawn (playerid) {
	return 1;
}

public OnObjectMoved (objectid) {
	return 1;
}

public OnPlayerObjectMoved (playerid, objectid) {
	return 1;
}

public OnPlayerPickUpPickup (playerid, pickupid) {
	// https://wiki.sa-mp.com/wiki/GetPlayerDistanceFromPoint  > https://wiki.sa-mp.com/wiki/VectorSize???
	new string[256];
	for (new i = 0; i <= MAX_PICKUPS; i++) {
		if (PickUps[i][internal] == pickupid && PickUps[i][model] == 1275 && PickUps[i][company] == 2) {
			if (PlayerInfo[playerid][company] == 2 && PlayerInfo[playerid][inJob] == false) { // Spedition
				PlayerTextDrawSetString(playerid, PlayerInfo[playerid][textDraw], "~y~Information:~n~~w~Willkommen im Dienst");
				PlayerTextDrawShow(playerid, PlayerInfo[playerid][textDraw]);
				SetTimerEx("HideTextDraw", 3000, false, "i", playerid);

				// Load User and start job-timers
				SetPlayerSkin(playerid, 133);
				SetPlayerColor(playerid, 0x80a7e5);
				PlayerInfo[playerid][inJob] = true;
				PlayerInfo[playerid][timerScore] = SetTimer ("ScoreTimer", 60000, true);

				PlayerInfo[playerid][maxTrailerCapacity] = 250;
				PlayerInfo[playerid][trailerAttached] = false;
				return 1;
			}

			if (PlayerInfo[playerid][company] == 2 && PlayerInfo[playerid][inJob] == true) { // Spedition
				SetPlayerSkin(playerid, PlayerInfo[playerid][skin]);
				SetPlayerColor(playerid, 0xCCE2FFFF);
				PlayerInfo[playerid][inJob] = false;
				KillTimer(PlayerInfo[playerid][timerScore]);
				return 1;
			}
		}
	}

	return 1;
}

public OnVehicleMod (playerid, vehicleid, componentid) {
	return 1;
}

public OnVehiclePaintjob (playerid, vehicleid, paintjobid) {
	return 1;
}

public OnVehicleRespray (playerid, vehicleid, color1, color2) {
	return 1;
}

public OnPlayerSelectedMenuRow (playerid, row) {
	return 1;
}

public OnPlayerExitedMenu (playerid) {
	return 1;
}

public OnPlayerInteriorChange (playerid, newinteriorid, oldinteriorid) {
	return 1;
}

public OnPlayerKeyStateChange (playerid, newkeys, oldkeys) {
	return 1;
}

public OnRconLoginAttempt (ip[], password[], success) {
	return 1;
}

public OnPlayerUpdate (playerid) {
	return 1;
}

public OnPlayerStreamIn (playerid, forplayerid) {
	return 1;
}

public OnPlayerStreamOut (playerid, forplayerid) {
	return 1;
}

public OnVehicleStreamIn (vehicleid, forplayerid) {
	return 1;
}

public OnVehicleStreamOut (vehicleid, forplayerid) {
	return 1;
}

public OnDialogResponse (playerid, dialogid, response, listitem, inputtext[]) {
	return 0;
}

public OnPlayerClickPlayer (playerid, clickedplayerid, source) {
	return 1;
}

//////////////////////////
// ADDITIONAL FUNCTIONS //
//////////////////////////

forward IsPlayerInRangeOfVehicle(playerid, vehicleid, Float:range);
public IsPlayerInRangeOfVehicle(playerid, vehicleid, Float:range) {
	new Float:v_Pos[3];
	GetVehiclePos(vehicleid, v_Pos[0], v_Pos[1], v_Pos[2]);

	if ( IsPlayerInRangeOfPoint(playerid, range, v_Pos[0], v_Pos[1], v_Pos[2]) ){
 		return 1;
	}
	return 0;
}

forward HideTextDraw (playerid);
public HideTextDraw (playerid) {
	PlayerTextDrawHide(playerid, PlayerInfo[playerid][textDraw]);
	return 1;
}

//////////
// SAVE //
//////////

stock SaveAllUserStats (playerid) {
	new query[256];
	mysql_format(handle, query, sizeof(query), "UPDATE accounts SET job_score = '%d', job_timer = '%d' WHERE id = '%d'",
		PlayerInfo[playerid][score], PlayerInfo[playerid][nextScore], PlayerInfo[playerid][id]);
	mysql_pquery(handle, query);

	return 1;
}

stock SaveUserMoney (playerid) {
	new query[256];
	mysql_format(handle, query, sizeof(query), "UPDATE accounts SET money = '%d' WHERE id = '%d'",
		PlayerInfo[playerid][money], PlayerInfo[playerid][id]);
	mysql_pquery(handle, query);

	return 1;
}

//////////
// LOAD //
//////////

forward LoadPickUps ();
public LoadPickUps () {
	new rows;
	cache_get_row_count(rows);

	for (new i = 0; i < rows; i++) {
		cache_get_value_name_int(i, "id", PickUps[i][id]);
		cache_get_value_name_int(i, "model", PickUps[i][model]);
		cache_get_value_name_int(i, "type", PickUps[i][type]);
		cache_get_value_name_int(i, "world", PickUps[i][world]);
		cache_get_value_name_float(i, "pos_x", PickUps[i][pos_x]);
		cache_get_value_name_float(i, "pos_y", PickUps[i][pos_y]);
		cache_get_value_name_float(i, "pos_z", PickUps[i][pos_z]);
		cache_get_value_name(i, "description", PickUps[i][description],256);
		cache_get_value_name_int(i, "company", PickUps[i][company]);

		PickUps[i][internal] = CreatePickup(PickUps[i][model],PickUps[i][type],PickUps[i][pos_x],PickUps[i][pos_y],PickUps[i][pos_z],PickUps[i][world]);
	}
	return 1;
}

forward LoadCheckpoints ();
public LoadCheckpoints () {
	new rows;
	cache_get_row_count(rows);

	for (new i = 0; i < rows; i++) {
		cache_get_value_name_int(i, "id", CheckPoints[i][id]);
		cache_get_value_name_int(i, "size", CheckPoints[i][size]);
		cache_get_value_name_float(i, "pos_x", CheckPoints[i][pos_x]);
		cache_get_value_name_float(i, "pos_y", CheckPoints[i][pos_y]);
		cache_get_value_name_float(i, "pos_z", CheckPoints[i][pos_z]);
		cache_get_value_name(i, "description", CheckPoints[i][description],256);
		cache_get_value_name_int(i, "company", CheckPoints[i][company]);
		cache_get_value_name_int(i, "usuage", CheckPoints[i][usuage]);

		//PickUps[i][internal] = CreatePickup(PickUps[i][model],PickUps[i][type],PickUps[i][pos_x],PickUps[i][pos_y],PickUps[i][pos_z],PickUps[i][world]);
	}
	return 1;
}

forward OnUserLoadJob (playerid);
public OnUserLoadJob (playerid) {
	if (cache_num_rows() != 1) {
		// User not found
	} else {
		cache_get_value_name_int(0, "id", PlayerInfo[playerid][id]);
		cache_get_value_name_int(0, "skin", PlayerInfo[playerid][skin]);
		cache_get_value_name_int(0, "job", PlayerInfo[playerid][company]);
		cache_get_value_name_int(0, "job_score", PlayerInfo[playerid][score]);
		cache_get_value_name_int(0, "job_timer", PlayerInfo[playerid][nextScore]);
	}

	return 1;
}

forward LoadVehicles ();
public LoadVehicles () {
	new rows;
	cache_get_row_count(rows);

	for (new i = 0; i < rows; i++) {
		cache_get_value_name_int(i, "id", Vehicles[i][id]);
		cache_get_value_name_int(i, "model", Vehicles[i][model]);
		cache_get_value_name_float(i, "pos_x", Vehicles[i][pos_x]);
		cache_get_value_name_float(i, "pos_y", Vehicles[i][pos_y]);
		cache_get_value_name_float(i, "pos_z", Vehicles[i][pos_z]);
		cache_get_value_name_float(i, "rot", Vehicles[i][rot]);
		cache_get_value_name_int(i, "color1", Vehicles[i][color_1]);
		cache_get_value_name_int(i, "color2", Vehicles[i][color_2]);
		cache_get_value_name_int(i, "respawn_delay", Vehicles[i][respawn_delay]);
		cache_get_value_name_int(i, "owner", Vehicles[i][owner]);
		cache_get_value_name(i, "numberplate", Vehicles[i][numberplate],64);
		cache_get_value_name_int(i, "company", Vehicles[i][company]);

		Vehicles[i][internal] = CreateVehicle(Vehicles[i][model],Vehicles[i][pos_x],Vehicles[i][pos_y],Vehicles[i][pos_z],Vehicles[i][rot],Vehicles[i][color_1],Vehicles[i][color_2],Vehicles[i][respawn_delay]);
		SetVehicleNumberPlate(Vehicles[i][internal], Vehicles[i][numberplate]);
	}
	return 1;
}

forward ScoreTimer (playerid);
public ScoreTimer (playerid) {
	PlayerInfo[playerid][nextScore] += 1;

	if (PlayerInfo[playerid][nextScore] >= 60) {
		PlayerInfo[playerid][score] += 1;
		PlayerInfo[playerid][nextScore] = 0;
	}
	SaveAllUserStats(playerid);
}
//////////////////////////////
// LOGIN & MYSQL-CONNECTION //
//////////////////////////////

stock MySQL_SetupConnection (ttl = 3) {
	print("[MySQL] Connecting...");
	mysql_log(ERROR);
	handle = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASS, MYSQL_DB);

	if (mysql_errno() != 0) {
		if (ttl > 1) {
			print("[MySQL] Could not connect to database!");
			printf("[MySQL] retry (TTL: %d).", ttl-1);
			return MySQL_SetupConnection(ttl-1);
		} else {
			print("[MySQL] Could not connect to database.");
			print("[MySQL] Please check credentials.");
			print("[MySQL] shutdown server NOW!");
			return SendRconCommand("exit");
		}
	}
	printf("[MySQL] Connected to database! Handle: %d", handle);

	return 1;
}
