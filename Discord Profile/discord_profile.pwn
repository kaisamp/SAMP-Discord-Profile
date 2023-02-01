/*
	.____     ________     ____________________ 
	|    |   /  _____/  /\ \______   \______   \
	|    |  /   \  ___  \/  |       _/|     ___/
	|    |__\    \_\  \ /\  |    |   \|    |    
	|_______ \______  / \/  | ___|___/|____|
			\/      \/   
                     Legacy Roleplay       
              Legacy Gaming Development Team
         

                 Disccord Profile System
                 Created By: Genjii#4764

                  MySQL Version: R39-6

                 Developed: 12/19/2020

*/

#include <discord-connector>
#include <discord-cmd>


#define DISCORD_PROFILE_CHANNEL 	"1065180735784357888"    // Member

public OnGameModeInit()
{
    member_channel = DCC_FindChannelById(DISCORD_PROFILE_CHANNEL);
    return 1;
}

DCMD:profile(user, channel, params[])
{
    if(channel != member_channel)
    {   
        new channel_name[64], szString[128];
        DCC_GetChannelName(member_channel, channel_name, sizeof(channel_name));

        format(szString, sizeof(szString), "This command should only be used on #%s!", channel_name);
        SendWrongChannel(channel, 0xFF0000, "Wrong Channel", szString);
        return 0;
    }
    if(isnull(params))
    {
        return SendMessageChannel(channel, 0xFF0000, "", "`Usage: !profile [username]`");
    }

    mysql_format(connectionID, queryBuffer, sizeof(queryBuffer), "SELECT * FROM users WHERE username = '%e'", params);
    mysql_tquery(connectionID, queryBuffer, "DiscordCheckingStats", "s", params);
    return 1;
}

forward DiscordCheckingStats(username[]);
public DiscordCheckingStats(username[])
{
    member_channel = DCC_FindChannelById(DISCORD_PROFILE_CHANNEL);
    if(!cache_get_row_count(connectionID))
	{
        SendMessageChannel(member_channel, 0xFF0000, "Error: Invalid Username", "The player specified doesn't exist.");
    }
    else
    {
        new skin, hours, number;
        new string[1028], skinurl[1028];
        
        skin = cache_get_field_content_int(0, "skin");
        hours = cache_get_field_content_int(0, "hours");
        number = cache_get_field_content_int(0, "phone");

        format(string, sizeof(string), "**Name:** %s\n**Skin:** %i\n**Playing Hours:** %i\n**Phone Number:** %i", username, skin, hours, number);
        format(skinurl, sizeof(skinurl), "https://assets.open.mp/assets/images/skins/%i.png", cache_get_field_content_int(0, "skin"));
        SendDiscordProfile(member_channel, 0xFF0000, ""SERVER_NAME" Profile", string, skinurl);
    }
}


forward SendDiscordProfile(DCC_Channel:channel, color, const title[], const message[], const skin[]);
public SendDiscordProfile(DCC_Channel:channel, color, const title[], const message[], const skin[]) {
    new DCC_Embed:embed= DCC_CreateEmbed(title);
    DCC_SetEmbedColor(embed, color);
    DCC_SetEmbedDescription(embed, message);
    DCC_SetEmbedImage(embed, skin);
    DCC_SendChannelEmbedMessage(channel, embed);
    return 1;
}
