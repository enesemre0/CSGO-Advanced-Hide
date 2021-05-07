#include <sourcemod> 
#include <sdktools> 
#include <sdkhooks> 
#include <colors_csgo>
#include <cstrike>

#define newdecls required

bool g_bHideTeam[MAXPLAYERS + 1] =  { false, ... };
bool g_bHideAll[MAXPLAYERS + 1] =  { false, ... };
bool g_bHideEnemy[MAXPLAYERS + 1] =  { false, ... };

public Plugin myinfo = 
{
	name = "HidePlayers",
	author = "EnesEmre",
	description = "Oyuncuları Gizlersiniz",
	version = "1.0",
	url = "https://github.com/enesemre0"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_ggizle", Command_Hide);
	RegConsoleCmd("sm_ghide", Command_Hide);
	RegConsoleCmd("sm_gelismishide", Command_Hide);
	for (int i = 1; i <= MaxClients; i++)
    	if (IsClientInGame(i))
        	OnClientPutInServer(i);
}

public void OnMapStart()
{
	for (int i; i <= MaxClients; i++)
	{
		g_bHideTeam[i] = false;
		g_bHideAll[i] = false;
	}
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_SetTransmit, Hook_SetTransmit);
}

Menu Hide(int client)
{
	Menu menu = new Menu(Menu_CallBack);
	menu.SetTitle("[EnesEmre] Oyuncu Gizleme\nAktif Gizleme: Yok\n ");
	if (GetClientTeam(client) != CS_TEAM_SPECTATOR || GetClientTeam(client) != CS_TEAM_NONE)
	{
		if (g_bHideTeam[client])
		{
			menu.SetTitle("[EnesEmre] Oyuncu Gizleme\nAktif Gizleme: Takım Arkadaşları\n ");
			menu.AddItem("0", "Takım Arkadaşlarını Gör");
			menu.AddItem("1","Düşman Takımı Gizle", ITEMDRAW_DISABLED);
			menu.AddItem("2", "Tüm Oyuncuları Gizle", ITEMDRAW_DISABLED);
		}
		else if (g_bHideAll[client])
		{
			menu.SetTitle("[EnesEmre] Oyuncu Gizleme\nAktif Gizleme: Tüm Oyuncular\n ");
			menu.AddItem("0","Takım Arkadaşlarını Gizle", ITEMDRAW_DISABLED);
			menu.AddItem("1", "Düşman Takımı Gizle", ITEMDRAW_DISABLED);
			menu.AddItem("2", "Tüm Oyuncuları Gör");
		}
		else if (g_bHideEnemy[client])
		{
			menu.SetTitle("[EnesEmre] Oyuncu Gizleme\nAktif Gizleme: Düşman Takım\n ");
			menu.AddItem("0","Takım Arkadaşlarını Gizle", ITEMDRAW_DISABLED);
			menu.AddItem("1", "Düşman Takımı Gör");
			menu.AddItem("2", "Tüm Oyuncuları Gizle", ITEMDRAW_DISABLED);
		}
		else {
			menu.AddItem("0", "Takım Arkadaşlarını Gizle");
			menu.AddItem("1", "Düşman Takımı Gizle");
			menu.AddItem("2", "Tüm Oyuncuları Gizle");
		}
		menu.ExitButton = true;
		menu.ExitBackButton = false;
	}
	return menu;
}

public Action Command_Hide(int client, int args) 
{
	Hide(client).Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
} 

public int Menu_CallBack(Menu menu, MenuAction action, int client, int position)
{
	if (action == MenuAction_Select)
	{
		char Item[4];
		menu.GetItem(position, Item, sizeof(Item));
		if (strcmp(Item, "0", false) == 0)
		{
			g_bHideTeam[client] = !g_bHideTeam[client];
			CPrintToChat(client, "{darkred}[EnesEmre] {default}%s", g_bHideTeam[client] ? "{blue}Takım {default}arkadaşları {darkred}gizlendi.{default}":"{blue}Takım {default}arkadaşları {green}görünür.{default}");
			Hide(client).Display(client, MENU_TIME_FOREVER);
		}
		else if (strcmp(Item, "2", false) == 0)
		{
			g_bHideAll[client] = !g_bHideAll[client];
			CPrintToChat(client, "{darkred}[EnesEmre] {default}%s", g_bHideAll[client] ? "{blue}Tüm {default}Oyuncular {darkred}gizlendi.{default}":"{blue}Tüm {default}Oyuncular {green}görünür.{default}");	
			Hide(client).Display(client, MENU_TIME_FOREVER);
		}
		else if (strcmp(Item, "1", false) == 0)
		{
			g_bHideEnemy[client] = !g_bHideEnemy[client];
			CPrintToChat(client, "{darkred}[EnesEmre] {default}%s", g_bHideEnemy[client] ? "{blue}Düşman {default}takım {darkred}gizlendi.{default}":"{blue}Düşman {default}takım {green}görünür.{default}");	
			Hide(client).Display(client, MENU_TIME_FOREVER);
		}
		else if (action == MenuAction_End)
		{
			delete menu;
		}
	}
}

public Action Hook_SetTransmit(int entity, int client) 
{ 
	if (g_bHideTeam[client] && entity != client && GetClientTeam(client) == GetClientTeam(entity))
	{
		return Plugin_Handled;
	}
	else if (g_bHideAll[client] && entity != client)
	{
		return Plugin_Handled;
	}
	else if (g_bHideEnemy[client] && entity != client && GetClientTeam(client) != GetClientTeam(entity))
	{
		return Plugin_Handled;
	}
	return Plugin_Continue;
} 