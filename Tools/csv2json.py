"""
csv2json.py

csv 파일을 json으로 변환한다.

- 사용 방법
    python csv2json.py raw_database.csv

- 소스 csv 파일 형식
    id,메뉴 이름,휴대성,사먹? 직접?,(단백질) 주재료,유니크 포인트,담당자
    40949894-896c-4a62-acf0-9b69214601c9,닭강정,휴대 쉬움,사먹기가 편한,닭고기/오리고기,"바삭바삭, 달콤한 맛을 느낄 수 있어요",민볼
    db7a9345-97b9-498e-b6ed-45b22eefe8c9,닭다리살 오븐구이,휴대 쉬움,사먹기가 편한,닭고기/오리고기,"겉은 바삭하고, 속은 촉촉하고 부드러워 입안에서 육즙이 풍부하게 퍼져요.",""
    abe56bd0-a0c0-4127-b2ac-d861b05616ef,닭가슴살 스틱,휴대 쉬움,사먹기가 편한,닭고기/오리고기,간편하게 단백질을 섭취하기 용이해요.,""

    "휴대성" 컬럼의 값은 다음 두 문자열 중 하나여야 한다.
    - 휴대 쉬움
    - 휴대 어려움

    "사먹? 직접?" 컬럼의 값은 다음 두 문자열 중 하나여야 한다.
    - 휴대 쉬움
    - 사먹기가 편한

    "(단백질) 주재료" 컬럼의 값은 다음 네 문자열 중 하나여야 한다.
    - "소고기/돼지고기"
    - "닭고기/오리고기"
    - "생선/해산물"
    - "콩·두부·계란"

- 결과 json 파일 형식
    [
        {
            "id": "40949894-896c-4a62-acf0-9b69214601c9",
            "title": "닭강정",
            "uniquePoint": "바삭바삭, 달콤한 맛을 느낄 수 있어요",
            "attributes": {
                "isPortable": true,
                "isCookable": false,
                "mainIngredient": "닭고기/오리고기"
            },
            "author": "민볼"
        }
    ]
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

    categoryData = get_category_data(input_file_path)
    write_json(categoryData, create_destination_file_path(input_file_path, "categories"))

    cardData = get_card_data(input_file_path, category_data=categoryData)
    write_json(cardData, create_destination_file_path(input_file_path, "cards"))

def create_destination_file_path(original_path: str, middle_fix: str, new_extension: str = "json") -> str:
    chunks = original_path.split(".")
    return ".".join(chunks[0:-1]) + f".{middle_fix}" + f".{new_extension}"

def get_category_data(file_path: str) -> list[dict]:
    print("source file path : " + file_path)

    categories = set()
    with open(file_path, 'r') as file:
        csv_reader = csv.reader(file)
        for (idx, row) in enumerate(csv_reader):
            if idx == 0:
                continue

            categories.add(row[0])
    
    category_data = []
    for category_title in categories:
        for level in (1, 2, 3):
            category_data.append({
                "id": str(uuid.uuid4()),
                "imageName": category_title,
                "difficulty": level,
                "nameKor": get_korean_name(category_title),
                "nameEng": category_title
            })
    
    return category_data

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

def get_card_data(file_path: str, category_data: list[dict]) -> list[dict]:
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
            category_level = row[3]
            is_boss = row[4]

            category_id = None
            for category in category_data:
                if category["nameEng"] == category_title and category["difficulty"] == int(category_level):
                    category_id = category["id"]
                    break

            card_data.append({
                "id": str(uuid.uuid4()),
                "categoryId": category_id,
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
