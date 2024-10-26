"""
- Answer the question if the restaurant is open on a given date/time,

- List the menu items,

- Place an order - here we expect a possibility that the order will contain items not listed on the menu, or additional requests (like ‘without the tomatoes’).

- For each of our main intents (mentioned above), it is required to write a simple generator,
    to create the training dataset with some common typos and language mistakes.
    Please feel free to choose the cases you want to handle.
    Apart from those, we should include the secondary intents, like greeting or farewell, to be handled as well.
"""

import discord
from discord.ext import commands
from dotenv import load_dotenv

from utils import load_data, get_full_day_name

from datetime import datetime
from typing import Optional
import random
import os

load_dotenv()
DISCORD_BOT_TOKEN = os.getenv("DISCORD_BOT_TOKEN")

data = load_data()
menu_items = data.get("menu", {})
opening_hours = data.get("opening_hours", {})
responses = data.get("responses", {})

# Discord bot setup
intents = discord.Intents.default()
intents.message_content = True
bot = commands.Bot(command_prefix="!", intents=intents)


def get_available_commands() -> str:
  return (
    "You can use the following commands:\n"
    "!check_open [day] [hour] - Check our opening hours for a specific day and time, or just for today\n"
    "  Examples: !check_open Monday 14, !check_open Mon, !check_open\n"
    "!menu - View our menu items"
  )


@bot.event
async def on_ready():
  print(f"{bot.user} has connected to Discord!")


@bot.command()
async def check_open(ctx, day: str = None, hour: Optional[int] = None):
  if not day:
    now = datetime.now()
    day = now.strftime("%A")
    if hour is None:
      hour = now.hour
  day = get_full_day_name(day)

  if day not in opening_hours.keys():
    await ctx.send(f"Sorry, I don't recognize the day '{day}'. Please use a valid day of the week.")
    return

  hours = opening_hours[day]
  if hours["open"] == 0 and hours["close"] == 0:
    await ctx.send(f"We're closed on {day}.")
  else:
    if hour is not None:
      if 0 <= hour < 24:
        if hours["open"] <= hour < hours["close"]:
          await ctx.send(f"Yes, we're open at {hour:02d}:00 on {day}. Our hours are from {hours['open']:02d}:00 to {hours['close']:02d}:00.")
        else:
          await ctx.send(f"Sorry, we're closed at {hour:02d}:00 on {day}. Our hours are from {hours['open']:02d}:00 to {hours['close']:02d}:00.")
      else:
        await ctx.send("Invalid hour. Please provide a number between 0 and 23.")
    else:
      await ctx.send(f"On {day}, we're open from {hours['open']:02d}:00 to {hours['close']:02d}:00.")


@bot.command()
async def menu(ctx):
  menu_list = "Our Menu:\n"
  for idx, item in enumerate(menu_items, start=1):
    menu_list += f"{idx}. {item['name']}: ${item['price']:.2f}\n"
  await ctx.send(menu_list)


@bot.event
async def on_message(message):
  if message.author == bot.user:
    return

  if bot.user.mentioned_in(message):
    thread = await message.create_thread(name="Customer Order", auto_archive_duration=60)

    greeting = random.choice(responses["greetings"])
    await thread.send(greeting)

    await thread.send(get_available_commands())

  await bot.process_commands(message)


# Run the bot
bot.run(DISCORD_BOT_TOKEN)
