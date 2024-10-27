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
from bot_commands import handle_order_command, handle_done_command, handle_delivery_command, OrderSystem

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

intents = discord.Intents.default()
intents.message_content = True
bot = commands.Bot(command_prefix="!", intents=intents)
bot.order_systems = {}


def get_available_commands() -> str:
  return (
    "**Available Commands:**\n\n"
    "• **!check_open** [day] [hour]\n"
    "  *Check opening hours for a specific day/time or today*\n"
    "  Examples:\n"
    "  › !check_open Monday 14\n"
    "  › !check_open Mon\n"
    "  › !check_open\n\n"
    "• **!menu**\n"
    "  *View our menu items*\n\n"
    "• **!order** [amount] <item>\n"
    "  *Order items by name or menu number*\n"
    "  Examples:\n"
    "  › !order 2 Pizza\n"
    "  › !order 1 Burger\n"
    "  › !order 3\n\n"
    "• **!current_order**\n"
    "  *Show your current order*\n\n"
    "• **!remove** <number>\n"
    "  *Remove an item from your order by its number*\n"
    "  Example:\n"
    "  › !remove 1\n\n"
    "• **!done**\n"
    "  *Finish your order*"
  )


@bot.event
async def on_ready():
  print(f"{bot.user} has connected to Discord!")


@bot.command()
async def order(ctx, *args):
  order_system = bot.order_systems.get(ctx.channel.id)
  response = await handle_order_command(ctx.message, order_system)
  await ctx.send(response)


@bot.command()
async def done(ctx):
  order_system = bot.order_systems.get(ctx.channel.id)
  response = await handle_done_command(ctx.message, order_system)
  await ctx.send(response)


@bot.command()
async def delivery(ctx):
  order_system = bot.order_systems.get(ctx.channel.id)
  try:
    response = await handle_delivery_command(ctx.message, order_system, True)
    await ctx.send(response)
    greeting = random.choice(responses["farewells"])
    await ctx.channel.send(greeting)
    # Lock the thread if message is in a thread
    if hasattr(ctx.channel, "parent") and ctx.channel.parent:
      await ctx.channel.edit(locked=True, auto_archive_duration=60)
  except ValueError as e:
    await ctx.send(f"Error: {str(e)}")


@bot.command()
async def takeout(ctx):
  order_system = bot.order_systems.get(ctx.channel.id)
  response = await handle_delivery_command(ctx.message, order_system, False)
  await ctx.send(response)
  greeting = random.choice(responses["farewells"])
  await ctx.channel.send(greeting)
  # Lock the thread if message is in a thread
  if hasattr(ctx.channel, "parent") and ctx.channel.parent:
    await ctx.channel.edit(locked=True, auto_archive_duration=60)


@bot.command(name="current_order")
async def show_current_order(ctx):
  order_system = bot.order_systems.get(ctx.channel.id)
  if not order_system:
    await ctx.send("No active order found!")
    return

  response = order_system.format_current_order()
  if not response:
    await ctx.send("Your order is empty!")
  else:
    await ctx.send("Your current order:\n" + response)


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


@bot.command()
async def remove(ctx, *args):
  order_system = bot.order_systems.get(ctx.channel.id)
  if not order_system:
    await ctx.send("No active order found!")
    return

  try:
    if not args:
      await ctx.send("Please specify what item to remove. Example: !remove 1")
      return

    item_index = int(args[0]) - 1  # Convert to 0-based index
    response = order_system.remove_item(item_index)
    await ctx.send(response)
  except ValueError:
    await ctx.send("Please provide a valid item number from your order.")
  except IndexError:
    await ctx.send("That item number doesn't exist in your order.")


@bot.event
async def on_message(message):
  if message.author == bot.user:
    return

  if bot.user.mentioned_in(message) or isinstance(message.channel, discord.DMChannel):
    # Create a thread only in guild channels, not in DMs
    if isinstance(message.channel, discord.TextChannel):
      thread = await message.create_thread(name="Customer Order", auto_archive_duration=60)
      channel = thread
    else:
      channel = message.channel
    order_system = OrderSystem(menu_items)
    # Store it in the bot's state
    bot.order_systems[thread.id] = order_system

    # Send greeting
    greeting = random.choice(responses["greetings"])
    await channel.send(greeting)

    # Always send available commands
    await channel.send(get_available_commands())

  await bot.process_commands(message)


# Run the bot
bot.run(DISCORD_BOT_TOKEN)
