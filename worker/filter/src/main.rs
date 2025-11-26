use std::env;
use serde::{Deserialize, Serialize};
use serde_json::{json};
use std::io::{self, Write};

#[derive(Serialize, Deserialize, Debug)]
struct ChatMessage {
    sender_id: String,
    post_uuid: String,
    peer_id: String,
    room_id: String,
    content: String,
}

static FORBIDDEN_WORDS: &[&str] = &[
    "씨발",
    "븅신",
    "병신",
    "좆",
    "카카오톡",
    "kakao",
    "kkt",
    "신한은행",
    "국민은행",
    "카카오뱅크",
    "계좌",
    "통장",
    "송금",
    "입금",
];

fn contains_forbidden_word(msg: &str) -> bool {
    let lower = msg.to_lowercase();
    FORBIDDEN_WORDS.iter().any(|w| lower.contains(w))
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        let output = json!({});
        println!("{}", output.to_string());
        return;
    }
    let msg_json_str = &args[1];
    let mut chat_message: ChatMessage = match serde_json::from_str(msg_json_str) {
        Ok(msg) => msg,
        Err(_) => {
            // 파싱 실패 시 원본 그대로 반환하여 Go에서 처리하거나 무시
            println!("{}", msg_json_str);
            return;
        }
    };

    if contains_forbidden_word(&chat_message.content) {
        chat_message.content = String::from("비속어 및 금지 정보가 포함된 메시지입니다.");
    }

    match serde_json::to_string(&chat_message) {
    Ok(output_str) => {
        let mut stdout = io::stdout();
        if let Err(e) = write!(stdout, "{}", output_str) {
            eprintln!("Failed to write to stdout: {}", e);
        }
        if let Err(e) = stdout.flush() {
            eprintln!("Failed to flush stdout: {}", e);
        }
    },
    Err(_) => {
    }
}
}
