# utils.py

def read_input(date_string: str) -> str:
	with open(f"data/{date_string}.txt") as f:
		return f.read()