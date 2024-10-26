import json
import os


def load_data() -> dict:
	data = {}
	data_dir = "python/data"

	for filename in os.listdir(data_dir):
		if filename.endswith(".json"):
			file_path = os.path.join(data_dir, filename)
			with open(file_path, "r") as file:
				file_data = json.load(file)
				key = os.path.splitext(filename)[0]
				data[key] = file_data["items"]

	return data


def get_full_day_name(day) -> str:
	days = {"mon": "Monday", "tue": "Tuesday", "wed": "Wednesday", "thu": "Thursday", "fri": "Friday", "sat": "Saturday", "sun": "Sunday"}
	return days.get(day[:3].lower(), day)
