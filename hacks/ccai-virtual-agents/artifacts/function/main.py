import json
import random

# original implementation was: https://xkcd.com/221/
def on_request(request) -> str:
	days: int = random.randint(1, 20)
	return json.dumps({"vacation_days_left": days})
