import os

from TwitchChannelPointsMiner import TwitchChannelPointsMiner
from TwitchChannelPointsMiner.classes.Settings import FollowersOrder, Priority, Events
from TwitchChannelPointsMiner.classes.entities.Streamer import Streamer, StreamerSettings
from TwitchChannelPointsMiner.classes.Webhook import Webhook
from TwitchChannelPointsMiner.logger import LoggerSettings

twitch_miner = TwitchChannelPointsMiner(
    enable_analytics=False,	
    username=os.environ['TWITCH_USERNAME'], 
    priority=[
        Priority.STREAK, # - We want first of all to catch all watch streak from all streamers
        Priority.DROPS,  # - When we don't have anymore watch streak to catch, wait until all drops are collected over the streamers
        Priority.ORDER   # - When we have all of the drops claimed and no watch-streak available, use the order priority (POINTS_ASCENDING, POINTS_DESCEDING)
    ],
    logger_settings=LoggerSettings(
        save=True,                              # If you want to save logs in a file (suggested)
        console_username=False,                 # Adds a username to every console log line if True. Also adds it to Telegram, Discord, etc. Useful when you have several accounts
        auto_clear=True,                        # Create a file rotation handler with interval = 1D and backupCount = 7 if True (default)
        time_zone=os.environ['TIMEZONE'],       # Set a specific time zone for console and file loggers. Use tz database names. Example: "America/Denver"
        webhook=Webhook(
                endpoint=os.environ['NTFY_ENDPOINT'],
                method="GET",
                events=[Events.STREAMER_ONLINE],
            )
    ),
    streamer_settings=StreamerSettings(make_predictions=False)
)

twitch_miner.mine(followers=True, followers_order=FollowersOrder.ASC)