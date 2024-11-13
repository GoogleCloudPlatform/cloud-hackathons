import json
import random

def on_request(request) -> str:
	days: int = random.randint(1, 100)
	return json.dumps({"vacation_days_left": days})
