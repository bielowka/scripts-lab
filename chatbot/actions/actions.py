import json

from rasa_sdk import Action
from rasa_sdk.events import SlotSet

class ActionShowMenu(Action):
    def name(self):
        return "action_show_menu"

    def run(self, dispatcher, tracker, domain):
        try:
            with open("menu.json", "r") as f:
                menu_data = json.load(f)["items"]
        except:
            dispatcher.utter_message(text="Sorry, I couldn't fetch menu.")
            return []
        menu_items = [f"{item['name']} - {item['price']} PLN" for item in menu_data]
        dispatcher.utter_message(text=f"Our menu: {', '.join(menu_items)}")
        return []


class ActionCheckOpenStatus(Action):
    def name(self):
        return "action_check_open_status"

    def run(self, dispatcher, tracker, domain):
        try:
            with open("opening_hours.json", "r") as f:
                hours_data = json.load(f)["items"]
        except:
            dispatcher.utter_message(text="Sorry, I couldn't fetch opening hours.")
            return []

        entities = tracker.latest_message.get("entities", [])
        day = next((e["value"] for e in entities if e["entity"] == "day"), None)
        time = next((e["value"] for e in entities if e["entity"] == "time"), None)

        if not day or day not in hours_data:
            dispatcher.utter_message(text="Please provide a valid day.")
            return []

        open_time, close_time = hours_data[day]["open"], hours_data[day]["close"]
        if open_time == 0 and close_time == 0:
            dispatcher.utter_message(text=f"The restaurant is closed on {day}.")
        elif time:
            time = int(time.split(":")[0])
            if open_time <= int(time) < close_time:
                dispatcher.utter_message(text=f"Yes, the restaurant is open at {time}:00 on {day}.")
            else:
                dispatcher.utter_message(text=f"No, the restaurant is closed at {time}:00 on {day}.")
        else:
            dispatcher.utter_message(text=f"On {day}, we are open from {open_time}:00 to {close_time}:00.")
        return []

class ActionPlaceOrder(Action):
    def name(self):
        return "action_place_order"

    # def run(self, dispatcher, tracker, domain):
    #     user_message = tracker.latest_message.get("text", "")
    #     dispatcher.utter_message(text=f"Order received: {user_message}. We will prepare it soon.")
    #     return []

    def run(self, dispatcher, tracker, domain):
        food_item = tracker.get_slot("food_item")
        special_request = tracker.get_slot("special_request")

        try:
            with open("menu.json", "r") as f:
                menu_data = json.load(f)["items"]
        except:
            dispatcher.utter_message(text="Sorry, I couldn't fetch menu.")
            return []
        menu_items = [item["name"].lower() for item in menu_data]

        if food_item and food_item.lower() in menu_items:
            order_text = f"Order received: {food_item}"
            if special_request:
                order_text += f" with {special_request}"
            order_text += ". We will prepare it soon."
            dispatcher.utter_message(text=order_text)
        else:
            dispatcher.utter_message(text="Sorry, we don't serve that item. Please choose from our menu.")

        return [SlotSet("food_item", None), SlotSet("special_request", None)]