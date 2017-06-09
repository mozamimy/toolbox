extern crate imap;
extern crate openssl;

use std::env;
use openssl::ssl;

fn main() {
    println!("Usagi");

    let user = env::var("USER").expect("USER must be set.");
    let password = env::var("PASSWORD").expect("PASSWORD must be set.");

    let ssl_conn_builder = ssl::SslConnectorBuilder::new(ssl::SslMethod::tls()).unwrap().build();
    let mut imap_socket = imap::client::Client::secure_connect(
        ("imap.gmail.com", 993),
        "imap.gmail.com",
        ssl_conn_builder
    ).unwrap();
    imap_socket.login(user.as_str(), password.as_str());

    match imap_socket.status("INBOX", "(MESSAGES)") {
        Ok(boxes) => {
            for mail_box in boxes {
                println!("{}", mail_box);
            }
        },
        Err(e) => panic!("Error listing: {:?}", e)
    }

    match imap_socket.select("INBOX") {
        Ok(mailbox) => println!("{}", mailbox),
        Err(e) => panic!("Error selecting INBOX: {}", e)
    }

    match imap_socket.fetch("3", "body[text]") {
        Ok(result) => println!("{:?}", result),
        Err(err) => println!("Error fetching a mail: {}", err)
    }

    imap_socket.logout();
}
