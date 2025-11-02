# kbot
## devops application from scratch

# Link to bot:
t.me/Lex_kbot

Setup Instructions
1. Clone the Repository
git clone https://github.com/Alexskl25/kbot.git
cd <your-repo-name>

2. Install Dependencies
go mod tidy

or manually add:

go get github.com/spf13/cobra
go get gopkg.in/telebot.v3

3. Create a Bot with BotFather

Open Telegram and start a chat with @BotFather.

Send /newbot and follow the instructions.

Copy your bot token (it looks like 1234567890:ABCdefGhIJkLmNoPQRstuVWxyZ).

4. Set Environment Variable

On Linux/macOS:

export TELE_TOKEN=<your-bot-token>

On Windows (PowerShell):

setx TELE_TOKEN "<your-bot-token>"

5. Run the Bot

go run main.go

If everything is set up correctly, your bot will start and connect to Telegram.

6. How to build

go build -ldflags "-X="github.com/Alexskl25/kbot/cmd.appVersion=<Version>

7. How to RUN

./kbot start

🧪 Example Usage

User: /start hello

Bot: Hello! I'm KBot, your friendly Telegram bot version: v1.0.2