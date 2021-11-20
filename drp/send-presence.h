#pragma once
#pragma comment(lib, "discord-rpc.lib")
/*
This is a simple example in C of using the rich presence API asyncronously.
*/

#define _CRT_SECURE_NO_WARNINGS /* thanks Microsoft */

#include <iostream>
#include <Windows.h>
#include <math.h>
#include <algorithm>
#include <codecvt>
#include "discord_rpc.h"

static const char* APPLICATION_ID = "911489645446062091";

static void updateDiscordPresence(int64_t startTime, const char *state, const char *details, const char *large_image_key, const char *small_image_key, const char *large_image_text, const char *small_image_text)
{
	DiscordRichPresence discordPresence;
	memset(&discordPresence, 0, sizeof(discordPresence));
	discordPresence.state = state;
	discordPresence.details = details;
	discordPresence.largeImageKey = large_image_key;
	discordPresence.smallImageKey = small_image_key;
	discordPresence.largeImageText = large_image_text;
	discordPresence.smallImageText = small_image_text;
	discordPresence.startTimestamp = startTime;
	discordPresence.instance = 0;
	Discord_UpdatePresence(&discordPresence);
}

static void discordInit()
{
	DiscordEventHandlers handlers;
	Discord_Initialize(APPLICATION_ID, &handlers, 1, NULL);
}
