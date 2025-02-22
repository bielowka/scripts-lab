import os
import discord
import requests
from discord.ext import commands


DISCORD_TOKEN = os.getenv('DISCORD_TOKEN')
RASA_URL = "http://localhost:5005/webhooks/rest/webhook"

intents = discord.Intents.default()
intents.messages = True
intents.message_content = True
bot = commands.Bot(command_prefix="!", intents=intents)



@bot.event
async def on_ready():
    print(f'Logged in as {bot.user}')


@bot.event
async def on_message(message):
    if message.author == bot.user:
        return

    payload = {"sender": str(message.author), "message": message.content}
    response = requests.post(RASA_URL, json=payload)
    rasa_response = response.json()
    reply = rasa_response[0]["text"] if rasa_response else "I'm not sure how to respond."

    await message.channel.send(reply)


bot.run(DISCORD_TOKEN)

