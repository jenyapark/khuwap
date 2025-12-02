mod rule;
mod ai;

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

const BLOCKED_MESSAGE: &str = "비속어 및 금지 거래 유도를 포함한 메시지입니다.";

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
            println!("{}", msg_json_str);
            return;
        }
    };

    let msg_json_str = &args[1];

    let mut chat_message: ChatMessage = match serde_json::from_str(msg_json_str) {
        Ok(msg) => msg,
        Err(_) => {
            println!("{}", msg_json_str);
            return;
        }
    };

    let original_content = &chat_message.content.clone();

    // rule.rs
    if rule::contains_forbidden_word(original_content) {
        chat_message.content = BLOCKED_MESSAGE.to_string();
    }

    //ai.rs
    if chat_message.content == *original_content {
        if ai::maybe_ai_classify(original_content) {
            chat_message.content = BLOCKED_MESSAGE.to_string();
        }
    }

    match serde_json::to_string(&chat_message) {
        Ok(output_str) => {
            let mut stdout = io::stdout();
            let _ = write!(stdout, "{}", output_str);
            let _ = stdout.flush();
        },
        Err(e) => {
            eprintln!("Failed to serialize result: {}", e);
        }
    }
}
