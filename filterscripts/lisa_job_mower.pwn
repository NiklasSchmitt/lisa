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
	bool:loggedIn,
	name[MAX_PLAYER_NAME],
	level,
	skin,
	Float:health,
	money,
	bank_balance,
	score,
	nextScore,
	timerScore,
	Float:spawnX,
	Float:spawnY,
	Float:spawnZ,
	Float:spawnA,
	bool:allowSaveSpawn,
	textDraw,
	bool:showTextDraw,
	bool:afk,
	bool:isInJob,
	company
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

enum object {
	id,
	internal,
	model,
	Float:pos_x,
	Float:pos_y,
	Float:pos_z,
	Float:rot_x,
	Float:rot_y,
	Float:rot_z,
	draw_distance,
	description[256],
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
new Objects[MAX_OBJECTS][object];
new Vehicles[MAX_VEHICLES][vehicle];
new CheckPoints[MAX_CHECKPOINTS][checkpoint];

main () {
	print("\n----------------------------------");
	print("Load Filterscript: Job - Mower");
	print("----------------------------------\n");
}

public OnFilterScriptInit () {
	// Enable/Disable some samp-functions
	EnableStuntBonusForAll(0);
	ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
	ShowNameTags(1);

	MySQL_SetupConnection();
	mysql_log(ALL);

	mysql_pquery(handle, "SELECT * FROM pickups ORDER BY id ASC", "LoadPickUps");
	mysql_pquery(handle, "SELECT * FROM objects ORDER BY id ASC", "LoadObjects");
	mysql_pquery(handle, "SELECT * FROM vehicles ORDER BY id ASC", "LoadVehicles");

	return 1;
}

public OnFilterScriptExit() {
	mysql_close();

	return 1;
}

public OnPlayerSpawn (playerid) {
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
	new string[256];
	for (new i = 0; i <= MAX_PICKUPS; i++) {
			if (PickUps[i][model] == 1275) {
				if (PickUps[i][company] == 1) { // Mower
					PlayerTextDrawSetString(playerid, PlayerInfo[playerid][textDraw], "~y~Information:~n~~w~Willkommen im Dienst");
					PlayerTextDrawShow(playerid, PlayerInfo[playerid][textDraw]);
					SetTimerEx("HideTextDraw", 3000, false, "i", playerid);

					for (new v = 0; v < MAX_VEHICLES; v++) {
						if (Vehicles[v][internal] == 0) {
						Vehicles[v][model] = 414;
						Vehicles[v][pos_x] = 1220.3572;
						Vehicles[v][pos_y] = 192.3784;
						Vehicles[v][pos_z] = 19.5469;
						Vehicles[v][rot] = 338.3111;
						Vehicles[v][color_1] = -1;
						Vehicles[v][color_2] = -1;
						Vehicles[v][respawn_delay] = -1;
						Vehicles[v][owner] = 0;
						format(Vehicles[v][numberplate], 64, "LiSA");

						Vehicles[v][internal] = CreateVehicle(Vehicles[v][model], Vehicles[v][pos_x], Vehicles[v][pos_y], Vehicles[v][pos_z], Vehicles[v][rot], Vehicles[v][color_1], Vehicles[v][color_2], -1);
						SetVehicleNumberPlate(Vehicles[i][internal], Vehicles[i][numberplate]);

						return 1;
						}
					}
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
	if (dialogid == DIALOG_LOGIN) {
		if(!response) return Kick(playerid);
		if(strlen(inputtext) < 4) return ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "LiSA - Anmeldung", "Bitte logge Dich ein:\n{FF0000}Falsches Passwort!", "Ok", "Abbrechen");

		new query[256];
		mysql_format(handle, query, sizeof(query), "SELECT id, level, skin, health, money, bank_balance, score, score_timer, spawn_x, spawn_y, spawn_z FROM accounts WHERE name = '%e' AND password = SHA2('%e',256)", PlayerInfo[playerid][name], inputtext);
		mysql_pquery(handle, query, "OnUserLogin", "d", playerid);
		return 1;
	}

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
	if (!PlayerInfo[playerid][loggedIn]) return 1;

	new query[256];
	mysql_format(handle, query, sizeof(query), "UPDATE accounts SET health = '%f', money = '%d', bank_balance = '%d', score = '%d', score_timer = '%d' WHERE id = '%d'",
		PlayerInfo[playerid][health], PlayerInfo[playerid][money], PlayerInfo[playerid][bank_balance], PlayerInfo[playerid][score], PlayerInfo[playerid][nextScore], PlayerInfo[playerid][id]);
	mysql_pquery(handle, query);

	return 1;
}

stock SaveUserMoney (playerid) {
	if (!PlayerInfo[playerid][loggedIn]) return 1;

	new query[256];
	mysql_format(handle, query, sizeof(query), "UPDATE accounts SET money = '%d' WHERE id = '%d'",
		PlayerInfo[playerid][money], PlayerInfo[playerid][id]);
	mysql_pquery(handle, query);

	return 1;
}

stock SaveUserBankBalance (playerid) {
	if (!PlayerInfo[playerid][loggedIn]) return 1;

	new query[256];
	mysql_format(handle, query, sizeof(query), "UPDATE accounts SET bank_balance = '%d' WHERE id = '%d'",
		PlayerInfo[playerid][bank_balance], PlayerInfo[playerid][id]);
	mysql_pquery(handle, query);

	return 1;
}

stock SaveUserHealth (playerid) {
	if (!PlayerInfo[playerid][loggedIn]) return 1;

	new query[256];
	mysql_format(handle, query, sizeof(query), "UPDATE accounts SET health = '%f' WHERE id = '%d'",
		PlayerInfo[playerid][health],PlayerInfo[playerid][id]);
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

forward LoadObjects ();
public LoadObjects () {
	new rows;
	cache_get_row_count(rows);

	for (new i = 0; i < rows; i++) {
		cache_get_value_name_int(i, "id", Objects[i][id]);
		cache_get_value_name_int(i, "model", Objects[i][model]);
		cache_get_value_name_float(i, "pos_x", Objects[i][pos_x]);
		cache_get_value_name_float(i, "pos_y", Objects[i][pos_y]);
		cache_get_value_name_float(i, "pos_z", Objects[i][pos_z]);
		cache_get_value_name_float(i, "rot_x", Objects[i][rot_x]);
		cache_get_value_name_float(i, "rot_y", Objects[i][rot_y]);
		cache_get_value_name_float(i, "rot_z", Objects[i][rot_z]);
		cache_get_value_name_int(i, "draw_distance", Objects[i][draw_distance]);
		cache_get_value_name(i, "description", Objects[i][description],256);

		Objects[i][internal] = CreateObject(Objects[i][model],Objects[i][pos_x],Objects[i][pos_y],Objects[i][pos_z],Objects[i][rot_x],Objects[i][rot_y],Objects[i][rot_z],Objects[i][draw_distance]);
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
