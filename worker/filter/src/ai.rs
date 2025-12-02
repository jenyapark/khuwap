use reqwest::blocking::Client;
use serde::{Serialize, Deserialize};
use serde_json::json;
use std::env;
use std::time::Duration;

pub fn maybe_ai_classify(msg: &str) -> bool {
    // 너무 짧으면 false
    if msg.len() < 4 {
        return false;
    }

    // 안전한 단어 -> AI 호출 PASS
    if msg.contains("학교") || msg.contains("수업") {
        return false;
    }

    // AI 호출 부분 
    let api_key = match env::var("GEMINI_API_KEY") {
        Ok(v) => v,
        Err(_) => return false,
    };

    let client = Client::new();

    let url = format!(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key={}",
        api_key
    );

    let payload = json!({
        "contents": [{
            "parts": [{
                "text": format!(
                    "다음 메시지가 공격적·욕설 혹은 금전 거래 유도에 해당하면 \"BLOCK\".\n아니면 \"OK\"만 출력:\n\n{}",
                    msg
                )
            }]
        }]
    });



    let resp = client
        .post(&url)
        .json(&payload)
        .send();

    if resp.is_err() {
        return false; 
    }

    let body = resp.unwrap().text();
    if body.is_err() {
        return false;
    }

    let body = body.unwrap();
    if body.contains("BLOCK") {
        return true;
    }

    false
}
