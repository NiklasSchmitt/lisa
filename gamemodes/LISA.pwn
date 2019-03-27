#define OCMD_BEFORE_CALLBACK 1

#include <a_samp>
#include <a_mysql>
#include <ocmd>
#include <sscanf2>
#include <a_zones>

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

#define DIALOG_CARINFO_MAIN 1020

#define DIALOG_MM_MAIN_TEXT "Services\nNavigation\nMein Profil\n"

#define DIALOG_BANK_MAIN_TEXT "Kontostand\nEinzahlung\nAuszahlung\n"

new handle; //MySQL-Handle

enum player {
	id,
	bool:loggedIn,
	name[MAX_PLAYER_NAME+1],
	level,
	skin,
	Float:health,
	money,
	bank_balance,
	score,
	nextScore,
	timerScore,
	jobScore,
	nextJobScore,
	timerJobScore,
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
	print(" LISA - Life in San Andreas");
	print("----------------------------------\n");
}

public OnGameModeInit () {
	SetGameModeText("LiSA - Life in San Andreas");
	AddPlayerClass(0, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);

	// Enable/Disable some samp-functions
	LimitGlobalChatRadius(200000000);
	EnableStuntBonusForAll(0);
	ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
	ShowNameTags(1);

	MySQL_SetupConnection();
	mysql_log(ALL);

	mysql_pquery(handle, "SELECT * FROM pickups ORDER BY id ASC", "LoadPickUps");
	mysql_pquery(handle, "SELECT * FROM objects ORDER BY id ASC", "LoadObjects");
	mysql_pquery(handle, "SELECT * FROM vehicles WHERE company = 0 ORDER BY id ASC", "LoadVehicles");

	return 1;
}

public OnGameModeExit () {
	mysql_close();

	return 1;
}

public OnPlayerRequestClass (playerid) {
	if (!PlayerInfo[playerid][loggedIn]) {
		new query[128];
		mysql_format(handle, query, sizeof(query), "SELECT id FROM accounts WHERE name = '%e'", PlayerInfo[playerid][name]);
		mysql_pquery(handle, query, "OnUserCheck", "d", playerid);
	}

	return 1;

}

public OnPlayerConnect (playerid) {
	//Reset all the PlayerInfo - only for security
	PlayerInfo[playerid][id] = 0;
	PlayerInfo[playerid][loggedIn] = false;
	PlayerInfo[playerid][level] = 1;
	PlayerInfo[playerid][health] = 100;
	PlayerInfo[playerid][skin] = 26;
	PlayerInfo[playerid][money] = 10000;
	PlayerInfo[playerid][bank_balance] = 0;
	PlayerInfo[playerid][score] = 0;
	PlayerInfo[playerid][nextScore] = 0;
	PlayerInfo[playerid][spawnX] = 1676.86;
	PlayerInfo[playerid][spawnY] = 1447.42;
	PlayerInfo[playerid][spawnZ] = 10.7832;
	PlayerInfo[playerid][spawnA] = 0;
	PlayerInfo[playerid][allowSaveSpawn] = 0;
	GetPlayerName(playerid, PlayerInfo[playerid][name], MAX_PLAYER_NAME);
	PlayerInfo[playerid][afk] = false;

	PlayerInfo[playerid][textDraw] = CreatePlayerTextDraw(playerid, 30, 150, " ");
	PlayerTextDrawLetterSize(playerid, PlayerInfo[playerid][textDraw], 0.3, 1.1);
	PlayerTextDrawTextSize(playerid, PlayerInfo[playerid][textDraw], 200, 100);
	PlayerTextDrawUseBox(playerid, PlayerInfo[playerid][textDraw], true);
	PlayerTextDrawBoxColor(playerid, PlayerInfo[playerid][textDraw], 255);
	PlayerTextDrawFont(playerid, PlayerInfo[playerid][textDraw], 1);
	PlayerInfo[playerid][showTextDraw] = false;

	return 1;
}

public OnPlayerDisconnect (playerid, reason) {
	new string[128];
	GetPlayerName(playerid,string,MAX_PLAYER_NAME);
	format(string, 128, "%s hat den Server verlassen.", string);
	SendClientMessageToAll(-1,string);

	SaveAllUserStats(playerid);
	PlayerInfo[playerid][loggedIn] = false;

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

/////////////////////////////
///////////  CMD  ///////////
/////////////////////////////

ocmd:cmdlist (playerid) {
	if (PlayerInfo[playerid][level] >= 1 && PlayerInfo[playerid][afk] == false) {
		SendClientMessage(playerid, -1, "--- Kommandos für Spieler ---");
		SendClientMessage(playerid, -1, "/cmdlist | /mm | ");
	}

	return 1;
}

ocmd:mm (playerid) {
	if (PlayerInfo[playerid][level] >= 1 && PlayerInfo[playerid][afk] == false) {
  		ShowPlayerDialog(playerid, DIALOG_MM_MAIN, DIALOG_STYLE_LIST, "MobileManager", DIALOG_MM_MAIN_TEXT, "Okay", "Beenden");
	}

	return 1;
}

ocmd:carinfo (playerid) {
	if (PlayerInfo[playerid][level] >= 1 && PlayerInfo[playerid][afk] == false) {
		for (new i = 0; i < MAX_VEHICLES; i++) {
			if (IsPlayerInRangeOfVehicle(playerid, Vehicles[i][internal], 2) || IsPlayerInVehicle(playerid, Vehicles[i][internal])) {
				//ShowPlayerDialog(playerid, DIALOG_MM_MAIN, DIALOG_STYLE_LIST, "MobileManager", DIALOG_MM_MAIN_TEXT, "Okay", "Beenden");
			}
		}
	}
	return 1;
}

ocmd:savecarspawn (playerid) {
	if (PlayerInfo[playerid][level] >= 1 && PlayerInfo[playerid][afk] == false) {
		for (new i = 0; i < MAX_VEHICLES; i++) {
			if (IsPlayerInVehicle(playerid, Vehicles[i][internal])) {
				new Float:posx, Float:posy, Float:posz, Float:posa;
				GetVehiclePos(Vehicles[i][internal], posx, posy, posz);
				GetVehicleZAngle(Vehicles[i][internal], posa);
				Vehicles[i][pos_x] = posx;
				Vehicles[i][pos_y] = posy;
				Vehicles[i][pos_z] = posz;
				Vehicles[i][rot] = posa;

				SaveCarSpawn(i);
				PlayerTextDrawSetString(playerid, PlayerInfo[playerid][textDraw], "~y~Information:~n~~w~Erfolgreich gespeichert!");
				PlayerTextDrawShow(playerid, PlayerInfo[playerid][textDraw]);
				SetTimerEx("HideTextDraw", 3000, false, "i", playerid);
				return 1;
			}
		}
	}
	return 1;
}

ocmd:savetrailerspawn (playerid, params[]) {
	if (PlayerInfo[playerid][level] >= 2 && PlayerInfo[playerid][afk] == false) {
		if (IsPlayerInAnyVehicle(playerid) && IsTrailerAttachedToVehicle(GetPlayerVehicleID(playerid))) {
			new trailer = GetVehicleTrailer(GetPlayerVehicleID(playerid));
			for (new i = 0; i < MAX_VEHICLES; i++) {
				if (Vehicles[i][internal] == trailer) {
					new Float:posx, Float:posy, Float:posz, Float:posa;
					GetVehiclePos(trailer, posx, posy, posz);
					GetVehicleZAngle(trailer, posa);
					Vehicles[i][pos_x] = posx;
					Vehicles[i][pos_y] = posy;
					Vehicles[i][pos_z] = posz;
					Vehicles[i][rot] = posa;

					SaveCarSpawn(i);
					PlayerTextDrawSetString(playerid, PlayerInfo[playerid][textDraw], "~y~Information:~n~~w~Erfolgreich gespeichert!");
					PlayerTextDrawShow(playerid, PlayerInfo[playerid][textDraw]);
					SetTimerEx("HideTextDraw", 3000, false, "i", playerid);
					return 1;
				}
			}
		}
	}
	return 1;
}

ocmd:detach (playerid, params[]) {
	if (PlayerInfo[playerid][level] >= 1 && PlayerInfo[playerid][afk] == false) {
		if (IsPlayerInAnyVehicle(playerid) && IsTrailerAttachedToVehicle(GetPlayerVehicleID(playerid))) {
			DetachTrailerFromVehicle(GetPlayerVehicleID(playerid));
		}
	}
	return 1;
}
////////////////
// AFK & BACK //
////////////////

ocmd:afk (playerid) {
	if (PlayerInfo[playerid][level] >= 1 && PlayerInfo[playerid][afk] == false) {
		new string[128];
		GetPlayerName(playerid, string, MAX_PLAYER_NAME);
		format(string, 128, "%s ist jetzt AFK!", string);
		SendClientMessageToAll(-1, string);
		TogglePlayerControllable(playerid, 0);
		PlayerInfo[playerid][afk] = true;
		SaveAllUserStats(playerid);
	}
	return 1;
}

ocmd:back (playerid) {
	if (PlayerInfo[playerid][level] >= 1 && PlayerInfo[playerid][afk] == true) {
		new string[128];
		GetPlayerName(playerid, string, MAX_PLAYER_NAME);
		format(string, 128, "%s ist jetzt wieder da!", string);
		SendClientMessageToAll(-1, string);
		TogglePlayerControllable(playerid, 1);
		PlayerInfo[playerid][afk] = false;
		SaveAllUserStats(playerid);
	}
	return 1;
}

//////////////////////
// SAVE & SAVESPAWN //
//////////////////////

ocmd:allowsavespawn (playerid, params[]) {
	if (PlayerInfo[playerid][level] >= 2 && PlayerInfo[playerid][afk] == false) {
		new pID;
		sscanf(params, "i", pID);
		if (PlayerInfo[pID][loggedIn] == 1) {
			PlayerInfo[pID][allowSaveSpawn] = true;
			PlayerTextDrawSetString(playerid, PlayerInfo[playerid][textDraw], "~y~Information:~n~~w~Du darfst jetzt mit /savespawn speichern!");
			PlayerTextDrawShow(playerid, PlayerInfo[playerid][textDraw]);
		}
	}

	return 1;
}

ocmd:savespawn (playerid, params[]) {
	if (PlayerInfo[playerid][level] >= 1 && PlayerInfo[playerid][afk] == false) {
		if(PlayerInfo[playerid][loggedIn] == true && PlayerInfo[playerid][allowSaveSpawn] == true) {
			GetPlayerPos(playerid, PlayerInfo[playerid][spawnX], PlayerInfo[playerid][spawnY], PlayerInfo[playerid][spawnZ]);
			GetPlayerFacingAngle(playerid, PlayerInfo[playerid][spawnA]);

			new query1[256], query2[256];
			mysql_format(handle, query1, sizeof(query1),
				"UPDATE accounts SET spawn_x = '%f', spawn_y = '%f', spawn_z = '%f', spawn_a = '%f' WHERE id = '%d'",
				PlayerInfo[playerid][spawnX], PlayerInfo[playerid][spawnY], PlayerInfo[playerid][spawnZ], PlayerInfo[playerid][spawnA], PlayerInfo[playerid][id]);

			mysql_format(handle, query2, sizeof(query2),
				"UPDATE pickups SET pos_x = '%f', pos_y = '%f', pos_z = '%f' WHERE description LIKE '%e' AND model = '1277'",
				PlayerInfo[playerid][spawnX], PlayerInfo[playerid][spawnY], PlayerInfo[playerid][spawnZ], PlayerInfo[playerid][name]);

			if (mysql_pquery(handle, query1) == 1 && mysql_pquery(handle, query2) == 1) {
				PlayerInfo[playerid][allowSaveSpawn] = false;

				for (new i = 0; i < MAX_PICKUPS; i++) {
					if (PickUps[i][description] == PlayerInfo[playerid][name] && PickUps[i][model] == 1277) {
						DestroyPickup(PickUps[i][internal]);
						PickUps[i][pos_x] = PlayerInfo[playerid][spawnX];
						PickUps[i][pos_y] = PlayerInfo[playerid][spawnY];
						PickUps[i][pos_z] = PlayerInfo[playerid][spawnZ];
						PickUps[i][internal] = CreatePickup(PickUps[i][model], PickUps[i][type], PickUps[i][pos_x], PickUps[i][pos_y], PickUps[i][pos_z], PickUps[i][world]);

						SaveAllUserStats(playerid);
						PlayerTextDrawSetString(playerid, PlayerInfo[playerid][textDraw], "~y~Information:~n~~w~Erfolgreich gespeichert!");
						PlayerTextDrawShow(playerid, PlayerInfo[playerid][textDraw]);
						SetTimerEx("HideTextDraw", 3000, false, "i", playerid);

						return SendClientMessage(playerid, -1, "Erfolgreich gespeichert!");
					}
				}
			}
		}
	}

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
		if (PickUps[i][internal] == pickupid) {
			if (PickUps[i][model] == 1274) {
				ShowPlayerDialog(playerid, DIALOG_BANK_MAIN, DIALOG_STYLE_LIST, "Bank of San Andreas", DIALOG_BANK_MAIN_TEXT, "Okay", "Beenden");
			}
			if (PickUps[i][model] == 1277) {
				format(string, sizeof(string), "~y~Information:~n~~w~Hier wohnt %s", PickUps[i][description]);
				PlayerTextDrawSetString(playerid, PlayerInfo[playerid][textDraw], string);
				PlayerTextDrawShow(playerid, PlayerInfo[playerid][textDraw]);
				SetTimerEx("HideTextDraw", 3000, false, "i", playerid);
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

	if (dialogid == DIALOG_MM_MAIN) {
	    if (listitem == 0 && response == 1) { //Services
		    ShowPlayerDialog(playerid, DIALOG_MM_SERVICE, DIALOG_STYLE_LIST, "MobileManager", "Comming soon...\n", "Okay", "Zurück");
	    }
	    if (listitem == 1 && response == 1) { //Navigation
		    ShowPlayerDialog(playerid, DIALOG_MM_NAVIGATION, DIALOG_STYLE_LIST, "MobileManager", "Eismann\nSpedition LV", "Okay", "Zurück");
	    }

		if (listitem == 2 && response == 1) { //Mein Profil
			new profil_text[256];
			new rang[12];
			if (PlayerInfo[playerid][level] == 1) {
				rang = "Spieler";
			}
			if (PlayerInfo[playerid][level] == 2) {
				rang = "Scout";
			}
			if (PlayerInfo[playerid][level] == 3) {
				rang = "Admin";
			}

			GetPlayerName(playerid, profil_text, MAX_PLAYER_NAME);

			format(profil_text, sizeof (profil_text), "Name: %s\nRang: %d - %s\nBargeld: %d\nKontostand: %d\n", profil_text, PlayerInfo[playerid][level], rang, PlayerInfo[playerid][money], PlayerInfo[playerid][bank_balance]);
			ShowPlayerDialog(playerid, DIALOG_MM_PROFIL, DIALOG_STYLE_LIST, "MobileManager", profil_text, "Okay", "Zurück");
		}
	}

	if (dialogid == DIALOG_MM_NAVIGATION && response == 1) {
		if (listitem == 0 && response == 1) {
			if (CheckPoints[0][internal] == 0) {
				CheckPoints[0][pos_x] = 1230.4401;
				CheckPoints[0][pos_y] = 189.7190;
				CheckPoints[0][pos_z] = 19.2818;
				CheckPoints[0][size] = 5;
				CheckPoints[0][usuage] = 1; // 1 = Navigation | 2 = Job
			}
			CheckPoints[0][internal] = SetPlayerCheckpoint(playerid,CheckPoints[0][pos_x],CheckPoints[0][pos_y],CheckPoints[0][pos_z],CheckPoints[0][size]);
		}
		if (listitem == 1 && response == 1) {
			if (CheckPoints[0][internal] == 0) {
				CheckPoints[0][pos_x] = 1025.2941;
				CheckPoints[0][pos_y] = 2135.9253;
				CheckPoints[0][pos_z] = 10.8203;
				CheckPoints[0][size] = 5;
				CheckPoints[0][usuage] = 1; // 1 = Navigation | 2 = Job
			}
			CheckPoints[0][internal] = SetPlayerCheckpoint(playerid,CheckPoints[0][pos_x],CheckPoints[0][pos_y],CheckPoints[0][pos_z],CheckPoints[0][size]);
		}

		if (PlayerInfo[playerid][level] == 3) {
			ShowPlayerDialog(playerid, DIALOG_MM_ADMIN, DIALOG_STYLE_MSGBOX, "MobileManager", "ADMIN-Modus\nMöchtest du dich teleportieren?", "Teleport", "Marker");
		}
	}

	if (dialogid == DIALOG_MM_ADMIN && response == 1) {
		return SetPlayerPos(playerid,CheckPoints[0][pos_x],CheckPoints[0][pos_y],CheckPoints[0][pos_z]);
	}

	if ( (dialogid == DIALOG_MM_PROFIL || dialogid == DIALOG_MM_SERVICE || dialogid == DIALOG_MM_NAVIGATION) && response == 0) {
	 		ShowPlayerDialog(playerid, DIALOG_MM_MAIN, DIALOG_STYLE_LIST, "MobileManager", DIALOG_MM_MAIN_TEXT, "Okay", "Beenden");
	}

	if (dialogid == DIALOG_BANK_MAIN) {
	    if (listitem == 0 && response == 1) {
			new balance_text[256];
			format(balance_text, sizeof (balance_text), "Kontostand: %d$\n",PlayerInfo[playerid][bank_balance]);
			ShowPlayerDialog(playerid, DIALOG_BANK_BALANCE, DIALOG_STYLE_MSGBOX, "Kontostand - Bank of San Andreas", balance_text, "Okay", "");
	    }
	    if (listitem == 1 && response == 1) {
			 ShowPlayerDialog(playerid, DIALOG_BANK_DEPOSIT, DIALOG_STYLE_INPUT, "Einzahlung - Bank of San Andreas","Betrag eingeben:", "Okay", "Zurück");
	    }
		if (listitem == 2 && response == 1) {
			 ShowPlayerDialog(playerid, DIALOG_BANK_PAYOUT, DIALOG_STYLE_INPUT, "Auszahlung - Bank of San Andreas","Betrag eingeben:", "Okay", "Zurück");
		}
	}
	if (dialogid == DIALOG_BANK_DEPOSIT && response == 1) {
		new eingabe = strval(inputtext);
		if (eingabe) {
			if (eingabe <= PlayerInfo[playerid][money]) {
				PlayerInfo[playerid][money] -= eingabe;
				PlayerInfo[playerid][bank_balance] += eingabe;
				GivePlayerMoney(playerid, -eingabe);
				SaveAllUserStats(playerid);
				ShowPlayerDialog(playerid, DIALOG_BANK_MAIN, DIALOG_STYLE_LIST, "Bank of San Andreas", DIALOG_BANK_MAIN_TEXT, "Okay", "Beenden");
			} else {
				ShowPlayerDialog(playerid, DIALOG_BANK_DEPOSIT, DIALOG_STYLE_INPUT, "Einzahlung - Bank of San Andreas","{FF0000}Einzahlung nicht möglich!", "Okay", "Zurück");
			}
		} else {
			ShowPlayerDialog(playerid, DIALOG_BANK_DEPOSIT, DIALOG_STYLE_INPUT, "Einzahlung - Bank of San Andreas","{FF0000}Einzahlung nicht möglich!", "Okay", "Zurück");
		}
	}
	if (dialogid == DIALOG_BANK_PAYOUT && response == 1) {
		new eingabe = strval(inputtext);
		if (eingabe) {
			if (eingabe <= PlayerInfo[playerid][bank_balance]) {
				PlayerInfo[playerid][bank_balance] -= eingabe;
				PlayerInfo[playerid][money] += eingabe;
				GivePlayerMoney(playerid, eingabe);
				SaveAllUserStats(playerid);
				ShowPlayerDialog(playerid, DIALOG_BANK_MAIN, DIALOG_STYLE_LIST, "Bank of San Andreas", DIALOG_BANK_MAIN_TEXT, "Okay", "Beenden");
			} else {
				ShowPlayerDialog(playerid, DIALOG_BANK_PAYOUT, DIALOG_STYLE_INPUT, "Auszahlung - Bank of San Andreas","{FF0000}Auszahlung nicht möglich!", "Okay", "Zurück");
			}
		} else {
			ShowPlayerDialog(playerid, DIALOG_BANK_PAYOUT, DIALOG_STYLE_INPUT, "Auszahlung - Bank of San Andreas","{FF0000}Auszahlung nicht möglich!", "Okay", "Zurück");
		}
	}
	if (dialogid == DIALOG_BANK_PAYOUT && (response == 1 || response == 0)) {
	 		ShowPlayerDialog(playerid, DIALOG_BANK_MAIN, DIALOG_STYLE_LIST, "Bank of San Andreas", DIALOG_BANK_MAIN_TEXT, "Okay", "Beenden");
	}
	if ( (dialogid == DIALOG_BANK_PAYOUT || dialogid == DIALOG_BANK_DEPOSIT) && response == 0) {
	 		ShowPlayerDialog(playerid, DIALOG_BANK_MAIN, DIALOG_STYLE_LIST, "Bank of San Andreas", DIALOG_BANK_MAIN_TEXT, "Okay", "Beenden");
	}


	return 0;
}

public OnPlayerClickPlayer (playerid, clickedplayerid, source) {
	return 1;
}

////////////////////
// ADMIN-COMMANDS //
////////////////////

ocmd:vehicle (playerid, params[]) {
	if (PlayerInfo[playerid][level] == 3 && PlayerInfo[playerid][afk] == false) {
		new car, color1, color2, Float:posx, Float:posy, Float:posz, Float:posa;
		sscanf(params, "p|iii", car, color1, color2);

  		for (new i = 0; i < MAX_VEHICLES; i++) {
			if (car >= 400 && car <= 611) {
				if (Vehicles[i][internal] == 0) {
					GetPlayerPos(playerid, posx, posy, posz);
					GetPlayerFacingAngle(playerid, posa);
					Vehicles[i][model] = car;
					Vehicles[i][pos_x] = posx;
					Vehicles[i][pos_y] = posy;
					Vehicles[i][pos_z] = posz;
					Vehicles[i][rot] = posa;
					Vehicles[i][color_1] = color1;
					Vehicles[i][color_2] = color2;
					Vehicles[i][respawn_delay] = -1;
					Vehicles[i][owner] = PlayerInfo[playerid][id];
					format(Vehicles[i][numberplate], 64, "LiSA");

					Vehicles[i][internal] = CreateVehicle(car, posx, posy, posz, posa, color1, color2, -1);
					SetVehicleNumberPlate(Vehicles[i][internal], Vehicles[i][numberplate]);

					new query[256];
					mysql_format(handle, query, sizeof(query),
						"INSERT INTO vehicles (model, pos_x, pos_y, pos_z, rot, color1, color2, respawn_delay, owner) VALUES(%i, %f, %f, %f, %f, %i, %i, %i, %i)",
						car, posx, posy, posz, posa, color1, color2, -1, PlayerInfo[playerid][id]);
					mysql_pquery(handle, query);

					//PutPlayerInVehicle(playerid, Vehicles[i][internal], 0);
					return 1;
				}
			}
		}
	}

	return 1;
}

ocmd:repair (playerid, params[]) {
	if (PlayerInfo[playerid][level] == 3) {
		RepairVehicle(GetPlayerVehicleID(playerid));
 	}

	return 1;
}

ocmd:heal (playerid, params[]) {
	if (PlayerInfo[playerid][level] == 3) {
		new pID, value;
		sscanf(params, "ii", pID, value);

		if (pID == 0 && value == 0) {
			pID = playerid;
			value = 100;
		}

		PlayerInfo[pID][health] = value;
		SetPlayerHealth(pID, PlayerInfo[pID][health]);

		SaveUserHealth(pID);
 	}

	return 1;
}

ocmd:money (playerid, params[]) {
	if (PlayerInfo[playerid][level] == 3 && PlayerInfo[playerid][afk] == false) {
		new pID, value, result[128];
		sscanf(params, "ii", pID, value);

		if (GetPlayerMoney(pID) == PlayerInfo[pID][money]) {
			PlayerInfo[pID][money] += value;
			ResetPlayerMoney(pID);
			GivePlayerMoney(pID,PlayerInfo[pID][money]);

			new string[128];
			format(string, sizeof(string), "~r~Information:~n~~w~%s hat %s %i $ gegeben.", PlayerInfo[playerid][name],  PlayerInfo[pID][name], value);

			PlayerTextDrawSetString(playerid, PlayerInfo[playerid][textDraw], string);
			PlayerTextDrawShow(playerid, PlayerInfo[playerid][textDraw]);
			SetTimerEx("HideTextDraw", 5000, false, "i", playerid);

			PlayerTextDrawSetString(pID, PlayerInfo[pID][textDraw], string);
			PlayerTextDrawShow(pID, PlayerInfo[pID][textDraw]);
			SetTimerEx("HideTextDraw", 5000, false, "i", pID);

			format(result, sizeof(result), "Du hast %i $ von einem Admin erhalten.", value);
			SendClientMessage(pID, -1, result);

			SaveUserMoney(pID);
		}
	}

	return 1;
}

ocmd:say (playerid, params[]) {
	if (PlayerInfo[playerid][level] == 3) {
		new text[128];
		sscanf(params, "s", text);
		format(text,sizeof(text),"say %s",text);
		SendRconCommand(text);
	}

	return 1;
}

ocmd:gmx (playerid) {
	if (PlayerInfo[playerid][level] == 3) {
		SendClientMessage(playerid, 0x4B95FFFF, "* GMX: Eingeleitet!");
		SendClientMessage(playerid, 0x4B95FFFF, "* GMX: Speichere alle Spieler...");
		new counter, result[256];
		for (new i = 0; i < MAX_PLAYERS; i++) {
			if (PlayerInfo[i][loggedIn]) {
				SaveAllUserStats(i);
				counter++;
			}
		}
		format(result, sizeof(result), "* GMX: %i Spieler gespeichert!", counter);
		SendClientMessage(playerid, 0x4B95FFFF, result);
		SendRconCommand("say GMX in weniger als 5 Sekunden!");
		SetTimer("GmxTimer",3000,false);
	}

	return 1;
}

//////////////////////////
// ADDITIONAL FUNCTIONS //
//////////////////////////

forward BeforePlayerCommandText (playerid, cmdtext[]);
public BeforePlayerCommandText (playerid, cmdtext[]) {
	new text[256];
	sscanf(cmdtext, "s", text);

	if (!PlayerInfo[playerid][loggedIn]) {
		SendClientMessage(playerid, -1, "Du bist nicht eingeloggt!");
		return 0;
	}

	if (PlayerInfo[playerid][level] < 1 || PlayerInfo[playerid][level] > 3) {
		SendClientMessage(playerid, -1, "Du darfst das nicht!");
		return 0;
	}

	return 1;
}

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
	mysql_format(handle, query, sizeof(query), "UPDATE `accounts` SET bank_balance = '%d' WHERE id = '%d'",
		PlayerInfo[playerid][bank_balance], PlayerInfo[playerid][id]);
	mysql_pquery(handle, query);

	return 1;
}

stock SaveUserHealth (playerid) {
	if (!PlayerInfo[playerid][loggedIn]) return 1;

	new query[256];
	mysql_format(handle, query, sizeof(query), "UPDATE `accounts` SET `health` = '%f' WHERE `id` = '%d'",
		PlayerInfo[playerid][health], PlayerInfo[playerid][id]);
	mysql_pquery(handle, query);

	return 1;
}

stock SaveCarSpawn (vehicleid) {
	if (!Vehicles[vehicleid][internal]) return 1;

	new query[256];
	mysql_format(handle, query, sizeof(query), "UPDATE `vehicles` SET `pos_x` = '%f',`pos_y` = '%f',`pos_z` = '%f',`rot` = '%f' WHERE `id` = '%d'",
		Vehicles[vehicleid][pos_x], Vehicles[vehicleid][pos_y], Vehicles[vehicleid][pos_z], Vehicles[vehicleid][rot], Vehicles[vehicleid][id]);
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

forward OnUserCheck (playerid);
public OnUserCheck (playerid) {
	if (cache_num_rows() == 1) {
		ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "LiSA - Anmeldung", "Bitte logge Dich ein:", "Okay", "Abbrechen");
	} else {
		return Kick(playerid); 	// User is not whitelisted
	}

	return 1;
}

forward OnUserLogin (playerid);
public OnUserLogin (playerid) {
	if (cache_num_rows() != 1) {
		// User not found or bad password
		ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "LiSA - Anmeldung", "Bitte logge Dich ein:\n{FF0000}Falsches Passwort!", "Okay", "Abbrechen");
	} else {
		cache_get_value_name_int(0, "id", PlayerInfo[playerid][id]);
		cache_get_value_name_int(0, "level", PlayerInfo[playerid][level]);
		cache_get_value_name_int(0, "skin", PlayerInfo[playerid][skin]);
		cache_get_value_name_float(0, "health", PlayerInfo[playerid][health]);
		cache_get_value_name_int(0, "money", PlayerInfo[playerid][money]);
		cache_get_value_name_int(0, "bank_balance", PlayerInfo[playerid][bank_balance]);
		cache_get_value_name_int(0, "score", PlayerInfo[playerid][score]);
		cache_get_value_name_int(0, "score_timer", PlayerInfo[playerid][nextScore]);
		cache_get_value_name_float(0, "spawn_x", PlayerInfo[playerid][spawnX]);
		cache_get_value_name_float(0, "spawn_y", PlayerInfo[playerid][spawnY]);
		cache_get_value_name_float(0, "spawn_z", PlayerInfo[playerid][spawnZ]);
		cache_get_value_name_float(0, "spawn_a", PlayerInfo[playerid][spawnA]);

		GivePlayerMoney(playerid, PlayerInfo[playerid][money]);
		SetPlayerHealth(playerid, PlayerInfo[playerid][health]);
		SetPlayerScore(playerid, PlayerInfo[playerid][score]);
		SetSpawnInfo(playerid, 0, PlayerInfo[playerid][skin], PlayerInfo[playerid][spawnX], PlayerInfo[playerid][spawnY], PlayerInfo[playerid][spawnZ], PlayerInfo[playerid][spawnA], 0, 0, 0, 0, 0, 0);

		SetPlayerColor(playerid, 0xCCE2FFFF);
		SetPlayerSkin(playerid, PlayerInfo[playerid][skin]);
		new string[128];
		GetPlayerName(playerid,string,MAX_PLAYER_NAME);
		format(string,128, "%s hat den Server betreten.", string);
		SendClientMessageToAll(-1,string);

		PlayerInfo[playerid][loggedIn] = true;
		PlayerInfo[playerid][timerScore] = SetTimer ("ScoreTimer", 60000, true);

		SpawnPlayer(playerid);
	}

	return 1;
}

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

///////////
// TIMER //
///////////

forward ScoreTimer (playerid);
public ScoreTimer (playerid) {
	PlayerInfo[playerid][nextScore] += 1;

	if (PlayerInfo[playerid][nextScore] >= 60) {
		PlayerInfo[playerid][score] += 1;
		SetPlayerScore(playerid, PlayerInfo[playerid][score]);
		PlayerInfo[playerid][nextScore] = 0;
	}
	SaveAllUserStats(playerid);
}


forward GmxTimer(playerid);
public GmxTimer(playerid) {
	SendRconCommand("gmx");
}
