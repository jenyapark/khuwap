use reqwest::blocking::Client;
use serde::{Serialize, Deserialize};

pub fn maybe_ai_classify(msg: &str) -> bool {
    // 너무 짧으면 false
    if msg.len() < 4 {
        return false;
    }

    // 안전한 단어 → AI 호출 PASS
    if msg.contains("학교") || msg.contains("수업") {
        return false;
    }

    // AI 호출 부분 
    let client = Client::new();

    let resp = client.post("흠덩흠덩")
        .json(&serde_json::json!({ "msg": msg }))
        .send();

    if resp.is_err() {
        return false;  // AI 실패하면 OK 처리
    }

    let text = resp.unwrap().text().unwrap();

    text == "BLOCK"
}
