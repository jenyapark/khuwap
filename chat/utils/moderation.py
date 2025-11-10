import re

# ✅ 금칙어 목록 (원하면 DB나 외부 파일로 확장 가능)
BANNED_WORDS = [
    "계좌번호", "은행", "카톡", 
]

def contains_profanity(text: str) -> bool:
    """
    텍스트에 금칙어가 포함되어 있으면 True 반환
    """
    pattern = re.compile("|".join(map(re.escape, BANNED_WORDS)), re.IGNORECASE)
    return bool(pattern.search(text))
