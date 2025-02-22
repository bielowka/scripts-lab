import json

import yaml
import random
import re
import shutil


def load_nlu_data(file_path):
    with open(file_path, "r", encoding="utf-8") as file:
        nlu_data = yaml.safe_load(file)

    for intent_data in nlu_data.get("nlu", []):
        if isinstance(intent_data.get("examples"), str):
            examples_list = intent_data["examples"].strip().split("\n")
            intent_data["examples"] = [ex.strip("- ") for ex in examples_list if ex.strip()]

    return nlu_data


def introduce_typos(word):
    if len(word) < 4 or "[" in word or "(" in word:
        return word

    typo_type = random.choice(["swap", "remove", "duplicate", "replace"])

    if typo_type == "swap" and len(word) > 3:
        idx = random.randint(0, len(word) - 2)
        word = word[:idx] + word[idx + 1] + word[idx] + word[idx + 2:]

    elif typo_type == "remove" and len(word) > 3:
        idx = random.randint(0, len(word) - 1)
        word = word[:idx] + word[idx + 1:]

    elif typo_type == "duplicate":
        idx = random.randint(0, len(word) - 1)
        word = word[:idx] + word[idx] + word[idx:]

    elif typo_type == "replace":
        idx = random.randint(0, len(word) - 1)
        word = word[:idx] + random.choice("abcdefghijklmnopqrstuvwxyz") + word[idx + 1:]

    return word


def generate_typo_examples(intent_examples):
    typo_examples = []
    for example in intent_examples:
        words = example.split()

        modified_words = []
        for word in words:
            if re.match(r".*\[[^\]]+\]\([^)]+\)", word):
                modified_words.append(word)
            else:
                modified_words.append(introduce_typos(word))

        typo_examples.append(" ".join(modified_words))

    return typo_examples

def load_menu_items():
    with open(MENU_FILE, "r", encoding="utf-8") as file:
        menu_data = json.load(file)
    return [item["name"] for item in menu_data["items"]]

def generate_menu_examples(menu_items):
    examples = []
    for item in menu_items:
        examples.append(f"I’d like to order a [{item}](food_item)")
        examples.append(f"Can I have a [{item}](food_item) with [onions](special_request)?")
        examples.append(f"I want [{item}](food_item), extra [cheese](special_request)")
    return examples


def augment_nlu_data(nlu_data, menu_items):
    for intent_data in nlu_data.get("nlu", []):
        if intent_data["intent"] == "order_food":
            menu_examples = generate_menu_examples(menu_items)
            intent_data["examples"] += menu_examples

        examples_list = intent_data.get("examples", [])
        typo_examples = generate_typo_examples(examples_list)

        intent_data["examples"] = examples_list + typo_examples

    return nlu_data

def save_nlu_data(nlu_data, file_path):
    with open(file_path, "w", encoding="utf-8") as file:
        file.write("version: '3.1'\n")
        file.write("nlu:\n")

        for intent_data in nlu_data.get("nlu", []):
            file.write(f"- intent: {intent_data['intent']}\n")
            file.write("  examples: |\n")
            for example in intent_data["examples"]:
                file.write(f"    - {example}\n")

        file.write("\n- regex: food_item\n  examples: |\n")
        file.write("    - (?i)\\b[a-zA-Z]+(?:\\s[a-zA-Z]+)?\\b\n")

        file.write("\n- regex: special_request\n  examples: |\n")
        file.write("    - (?i)\\b[a-zA-Z]+(?:\\s[a-zA-Z]+)?\\b\n")

MENU_FILE = "actions/menu.json"
input_nlu_file = "nlu_base.yml"
output_nlu_file = "nlu_augmented.yml"

menu_items = load_menu_items()

nlu_data = load_nlu_data(input_nlu_file)
augmented_nlu_data = augment_nlu_data(nlu_data, menu_items)
save_nlu_data(augmented_nlu_data, output_nlu_file)

shutil.move(output_nlu_file, "data/nlu.yml")