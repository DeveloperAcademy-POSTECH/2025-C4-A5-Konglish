# CSV to JSON Converter

CSV 파일을 카테고리와 카드 데이터가 포함된 두 개의 JSON 파일로 변환하는 Python 스크립트입니다.

## 사용 방법

```bash
python csv2json.py <input_csv_file>
```

### 예시
```bash
python csv2json.py raw_database.csv
```

실행하면 다음 두 파일이 생성됩니다:
- `raw_database.categories.json` - 카테고리 데이터
- `raw_database.cards.json` - 카드 데이터

## CSV 스키마

입력 CSV 파일은 다음 5개 컬럼을 가져야 합니다:

| 컬럼명 | 설명 | 예시 |
|--------|------|------|
| Category | 카테고리명 (영어) | Animals, Food, Places |
| English | 영어 단어 | butterfly, dog, cat |
| Korean | 한국어 번역 | 나비, 개, 고양이 |
| Level | 난이도 레벨 (1-3) | 1, 2, 3 |
| Boss | 보스 카드 여부 | TRUE, FALSE |

### CSV 예시
```csv
Category,English,Korean,Level,Boss
Animals,butterfly,나비,1,TRUE
Animals,dog,개,1,FALSE
Food,potato,감자,1,TRUE
Food,egg,계란,1,FALSE
```

## JSON 스키마

### 1. Categories JSON (`*.categories.json`)

카테고리 정보를 담는 JSON 파일입니다.

```json
[
    {
        "id": "uuid",
        "imageName": "카테고리 이미지명",
        "difficulty": 1,
        "nameKor": "한국어 카테고리명",
        "nameEng": "영어 카테고리명"
    }
]
```

#### 필드 설명
- `id`: 고유 식별자 (UUID)
- `imageName`: 이미지 파일명 (영어 카테고리명과 동일)
- `difficulty`: 난이도 (1, 2, 3)
- `nameKor`: 한국어 카테고리명
- `nameEng`: 영어 카테고리명

### 2. Cards JSON (`*.cards.json`)

개별 카드 정보를 담는 JSON 파일입니다.

```json
[
    {
        "id": "uuid",
        "categoryId": "카테고리_uuid",
        "imageName": "이미지파일명",
        "pronunciation": "발음",
        "wordKor": "한국어_단어",
        "wordEng": "영어_단어",
        "isBoss": true
    }
]
```

#### 필드 설명
- `id`: 고유 식별자 (UUID)
- `categoryId`: 해당 카드가 속한 카테고리의 ID (categories.json의 id와 연결)
- `imageName`: 이미지 파일명 (영어 단어와 동일)
- `pronunciation`: 발음 (현재는 영어 단어와 동일)
- `wordKor`: 한국어 단어
- `wordEng`: 영어 단어
- `isBoss`: 보스 카드 여부 (boolean)

## 데이터 관계

두 JSON 파일은 다음과 같은 관계를 가집니다:

```
Categories (1) ←→ (N) Cards
```

- 하나의 카테고리는 여러 개의 카드를 가질 수 있습니다
- 각 카드는 정확히 하나의 카테고리에 속합니다
- `cards.json`의 `categoryId`는 `categories.json`의 `id`를 참조합니다

### 관계 예시
```json
// categories.json
{
    "id": "ea7f8c97-5839-40e2-aa90-b56f54184911",
    "imageName": "Animals",
    "difficulty": 1,
    "nameKor": "동물",
    "nameEng": "Animals"
}

// cards.json
{
    "id": "10a04ea4-060e-403e-a9f9-64e9dbb9c072",
    "categoryId": "ea7f8c97-5839-40e2-aa90-b56f54184911", // 위 카테고리 참조
    "imageName": "butterfly",
    "pronunciation": "butterfly",
    "wordKor": "나비",
    "wordEng": "butterfly",
    "isBoss": true
}
```

## 카테고리 매핑

스크립트는 다음과 같이 영어 카테고리명을 한국어로 매핑합니다:

| 영어 | 한국어 |
|------|--------|
| Animals | 동물 |
| Food | 음식 |
| Things at Home | 집 안 물건 |
| School | 학교 |
| Places | 장소 |
| My Body & Clothes | 내 몸과 옷 |
| Nature | 자연 |
| Action | 움직임 |

## 특징

- 각 카테고리는 난이도별(1, 2, 3)로 분리되어 별도의 카테고리 항목으로 생성됩니다
- 모든 ID는 UUID v4를 사용하여 고유성을 보장합니다
- 출력 JSON 파일은 UTF-8 인코딩으로 저장되며, 한국어가 올바르게 표시됩니다
