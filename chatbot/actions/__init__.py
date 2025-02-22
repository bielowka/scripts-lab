import os
import discord
import requests
from discord.ext import commands

# Load Discord bot token from environment variables
DISCORD_TOKEN = os.getenv('DISCORD_TOKEN')
RASA_URL = "http://localhost:5005/webhooks/rest/webhook"

# Initialize Discord bot
bot = commands.Bot(command_prefix="!")


# Event: Bot is ready
@bot.event
async def on_ready():
    print(f'Logged in as {bot.user}')


# Event: On message received
@bot.event
async def on_message(message):
    if message.author == bot.user:
        return

    payload = {"sender": str(message.author), "message": message.content}
    response = requests.post(RASA_URL, json=payload)
    rasa_response = response.json()
    reply = rasa_response[0]["text"] if rasa_response else "I'm not sure how to respond."

    await message.channel.send(reply)


# Run bot
bot.run(DISCORD_TOKEN)