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

Maybe it could cause issues if an URL is about to expire within 2 minutes, therefore trying to call the workflow again within 2 minutes.

GitHub warns that workflows only run every 5 minutes, so maybe this just causes a delay or maybe this causes it to skip?

I have no idea. This is pre-alpha. This is just another silly little script, supporting auto-cli
