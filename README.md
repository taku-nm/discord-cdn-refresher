# discord-cdn-refresher

I'm currently too lazy to make this a proper github action.

## To use this:

Copy the files

Modify the workflow to target your input file.

Create secrets in your repository to define the discord bot token (the bot needs to be able to see the channel the messages are located in)

Create a personal access token that has workflow and repo permissions https://github.com/settings/tokens

Dispatch the workflow at least once manually to get the cycle running.

--- 
This probably has some limitations. The script does replace every URL it can find and determine as expired.

It now also sleeps for whatever time is needed if it finds that the next schedule would be within 500 seconds.

This avoids schedules that are too tight for github.

This is pre-alpha. This is just another silly little script, supporting auto-cli
