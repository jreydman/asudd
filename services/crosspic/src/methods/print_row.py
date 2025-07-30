import os

terminal_size_width, terminal_size_height = os.get_terminal_size()

def print_row(text=None):
    text = f" [ {text} ] " if text else ""
    print(f"\n{text.center(terminal_size_width, '=')}\n")
