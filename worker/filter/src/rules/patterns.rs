use regex::Regex;

pub fn matches_forbidden_pattern(msg: &str) -> bool {
    let account_pattern = Regex::new(r"\b\d{10,14}\b").unwrap();
    let phone_pattern   = Regex::new(r"01[0-9]-?\d{3,4}-?\d{4}").unwrap();

    account_pattern.is_match(msg) || phone_pattern.is_match(msg)
}
