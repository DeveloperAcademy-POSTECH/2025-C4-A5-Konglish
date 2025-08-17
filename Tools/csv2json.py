"""
csv2json.py

csv 파일을 json으로 변환한다.

- 사용 방법
    python csv2json.py raw_database.csv
"""

import csv
import sys
import json
import uuid

def main():
    if len(sys.argv) != 2:
        print("usage: python csv2json.py raw_database.csv")
        sys.exit(1)

    input_file_path = sys.argv[1]

    category_data, level_data = get_categories_and_levels(input_file_path)
    write_json(category_data, create_destination_file_path(input_file_path, "categories"))
    write_json(level_data, create_destination_file_path(input_file_path, "levels"))

    cardData = get_cards(input_file_path, category_data=category_data, level_data=level_data)
    write_json(cardData, create_destination_file_path(input_file_path, "cards"))

def create_destination_file_path(original_path: str, middle_fix: str, new_extension: str = "json") -> str:
    chunks = original_path.split(".")
    return ".".join(chunks[0:-1]) + f".{middle_fix}" + f".{new_extension}"

def get_categories_and_levels(file_path: str) -> tuple[list[dict], list[dict]]:
    print("source file path : " + file_path)

    categories = set()
    with open(file_path, 'r') as file:
        csv_reader = csv.reader(file)
        for (idx, row) in enumerate(csv_reader):
            if idx == 0:
                continue

            categories.add(row[0])
    
    category_data = []
    level_data = []

    for category_title in categories:
        category_id = str(uuid.uuid4())

        category_data.append({
            "id": category_id,
            "imageName": category_title,
            "nameKor": get_korean_name(category_title),
            "nameEng": category_title
        })

        for level in (1, 2, 3):
            level_data.append({
                "id": str(uuid.uuid4()),
                "categoryTitle": category_title,
                "categoryId": category_id,
                "level": level
            })
    
    return category_data, level_data

def get_korean_name(eng_name: str) -> str:
    if eng_name == "Animals":
        return "동물"
    
    if eng_name == "Food":
        return "음식"
    
    if eng_name == "Things at Home":
        return "집 안 물건"
    
    if eng_name == "School":
        return "학교"
    
    if eng_name == "Places":
        return "장소"
    
    if eng_name == "My Body & Clothes":
        return "내 몸과 옷"
    
    if eng_name == "Nature":
        return "자연"
    
    if eng_name == "Action":
        return "움직임"

def get_cards(file_path: str, category_data: list[dict], level_data: list[dict]) -> list[dict]:
    print("source file path : " + file_path)

    card_data = []

    with open(file_path, 'r') as file:
        csv_reader = csv.reader(file)
        for (idx, row) in enumerate(csv_reader):
            if idx == 0:
                continue

            category_title = row[0]
            word_eng = row[1]
            word_kor = row[2]
            word_level = row[3]
            is_boss = row[4]

            level_id = None
            for category in category_data:
                if category["nameEng"] == category_title:
                    category_id = category["id"]

                    for level in level_data:
                        if level["categoryId"] == category_id and level["level"] == int(word_level):
                            level_id = level["id"]

            card_data.append({
                "id": str(uuid.uuid4()),
                "categoryTitle": category_title,
                "levelId": level_id,
                "wordLevel": int(word_level),
                "imageName": word_eng,
                "pronunciation": word_eng,
                "wordKor": word_kor,
                "wordEng": word_eng,
                "isBoss": is_boss == "TRUE"
            })
    
    return card_data

def write_json(data: list[dict], file_path: str):
    with open(file_path, 'w') as f:
        json.dump(data, f, indent=4, ensure_ascii=False)

if __name__ == "__main__":
    main()
