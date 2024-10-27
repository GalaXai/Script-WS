from typing import List, Union, Dict


class OrderSystem:
  def __init__(self, menu):
    self.current_orders: List[Dict] = []
    self.menu = menu

  def add_order(self, product: Union[str, int], amount: int = 1) -> str:
    try:
      # If product is a number (index)
      if isinstance(product, int) or product.isdigit():
        index = int(product) - 1  # Convert to 0-based index
        if 0 <= index < len(self.menu):
          item = self.menu[index]
        else:
          return "Invalid menu item number!"
      # If product is a name
      else:
        item = next((item for item in self.menu if item["name"].lower() == product.lower()), None)
        if not item:
          return f"Product '{product}' not found in menu!"

      for _ in range(amount):
        self.current_orders.append(item)

      return f"Added {amount}x {item['name']} to your order!"

    except Exception as e:
      return f"Error processing order: {str(e)}"

  def finalize_order(self, is_delivery: bool) -> str:
    if not self.current_orders:
      return "No items in your order!"

    # Check for Carbonara in delivery orders
    if is_delivery and any(item["name"] == "Spaghetti Carbonara" for item in self.current_orders):
      raise ValueError("Spaghetti Carbonara cannot be delivered! \n Please remove it from order if u want food on delivery.")

    total_price = sum(item["price"] for item in self.current_orders)

    base_prep_time = max(item["preparation_time"] for item in self.current_orders)

    final_prep_time = base_prep_time + (0.5 if is_delivery else 0)

    # Create order summary
    items_summary = {}
    for item in self.current_orders:
      items_summary[item["name"]] = items_summary.get(item["name"], 0) + 1

    summary = "\n".join(f"{count}x {name}" for name, count in items_summary.items())

    self.current_orders = []

    return (
      f"Order Summary:\n{summary}\n"
      f"Total Price: ${total_price:.2f}\n"
      f"Estimated Time: {final_prep_time:.1f} hours\n"
      f"{'Delivery' if is_delivery else 'Take-out'} order"
    )

  def remove_item(self, index: int) -> str:
    if not self.current_orders:
      return "No items in your order!"

    if 0 <= index < len(self.current_orders):
      removed_item = self.current_orders.pop(index)
      if self.current_orders:
        return f"Removed {removed_item['name']} from your order.\nCurrent order:\n" + self.format_current_order()
      return f"Removed {removed_item['name']} from your order. Your order is now empty."
    raise IndexError("Invalid item number")

  def format_current_order(self) -> str:
    order_list = ""
    for idx, item in enumerate(self.current_orders, start=1):
      order_list += f"{idx}. {item['name']}: ${item['price']:.2f}\n"
    return order_list


async def handle_order_command(message, order_system) -> str:
  """Handle the !order command"""
  parts = message.content.split()[1:]  # Split message and remove !order

  if not parts:
    return "Usage: !order [amount] <product name or number>"

  # Check if first part is amount
  if parts[0].isdigit():
    amount = int(parts[0])
    product = " ".join(parts[1:])
  else:
    amount = 1
    product = " ".join(parts)

  return order_system.add_order(product, amount)


async def handle_done_command(message, order_system) -> str:
  """Handle the !done command"""
  # Ask user about delivery preference
  return "Would you like delivery or take-out? (Reply with !delivery or !takeout)"


async def handle_delivery_command(message, order_system, is_delviery) -> str:
  """Handle the !delivery command"""
  return order_system.finalize_order(is_delivery=is_delviery)
