pub static FORBIDDEN_WORDS: &[&str] = &[
    "씨발", "좆", "병신",
    "카카오톡", "kkt", "kakao",
    "신한은행", "국민은행", "카카오뱅크",
    "계좌", "통장", "송금", "입금",
];

pub fn contains_forbidden_word(msg: &str) -> bool {
    let lower = msg.to_lowercase();
    FORBIDDEN_WORDS.iter().any(|w| lower.contains(w))
}
