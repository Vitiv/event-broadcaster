import Principal "mo:base/Principal";
import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Time "mo:base/Time";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import Hash "mo:base/Hash";
import Blob "mo:base/Blob";

actor TelegramApp {

    // Типы данных
    type UserId = Principal;
    type AuthToken = Text;
    type ChatId = Text;
    type MessageId = Nat;

    type Message = {
        id : MessageId;
        chatId : ChatId;
        from : UserId;
        content : Text;
        timestamp : Int;
    };

    type User = {
        id : UserId;
        authToken : AuthToken;
        chatId : ?ChatId;
    };

    // IC Management Canister
    type IC = actor {
        http_request : shared ({
            url : Text;
            method : Text;
            body : [Nat8];
            headers : [{ name : Text; value : Text }];
        }) -> async ({
            status : Nat;
            headers : [{ name : Text; value : Text }];
            body : [Nat8];
        });
    };

    let ic : IC = actor "aaaaa-aa";

    // Стабильные переменные для сохранения состояния
    private stable var nextMessageIdState : Nat = 0;
    private stable var usersEntries : [(UserId, User)] = [];
    private stable var messagesEntries : [(MessageId, Message)] = [];

    // Хранилище данных
    private var users = HashMap.HashMap<UserId, User>(10, Principal.equal, Principal.hash);
    private var messages = HashMap.HashMap<MessageId, Message>(100, Nat.equal, Hash.hash);

    // Конфигурация Telegram Bot
    private let telegramToken : Text = "YOUR_TELEGRAM_BOT_TOKEN";
    private let telegramApiUrl : Text = "https://api.telegram.org/bot" # telegramToken # "/";

    // Система для обновления состояния после обновления канистера
    system func preupgrade() {
        usersEntries := Iter.toArray(users.entries());
        messagesEntries := Iter.toArray(messages.entries());
    };

    system func postupgrade() {
        users := HashMap.fromIter<UserId, User>(usersEntries.vals(), 10, Principal.equal, Principal.hash);
        messages := HashMap.fromIter<MessageId, Message>(messagesEntries.vals(), 100, Nat.equal, Hash.hash);
        usersEntries := [];
        messagesEntries := [];
    };

    // Вспомогательные функции
    private func nextMessageId() : MessageId {
        nextMessageIdState += 1;
        nextMessageIdState - 1;
    };

    // Функция для отправки HTTP-запроса
    private func httpRequest(method : Text, url : Text, body : Text) : async {
        status : Nat;
        body : Blob;
    } {
        let request_headers = [
            { name = "Content-Type"; value = "application/json" },
        ];

        let response = await ic.http_request({
            url = url;
            method = method;
            body = Blob.toArray(Text.encodeUtf8(body));
            headers = request_headers;
        });

        return {
            status = response.status;
            body = Blob.fromArray(response.body);
        };
    };

    // Отправка сообщения в Telegram
    private func sendTelegramMessage(chatId : ChatId, text : Text) : async Result.Result<(), Text> {
        let url = telegramApiUrl # "sendMessage";
        let body = "{\"chat_id\":\"" # chatId # "\",\"text\":\"" # text # "\"}";

        let response = await httpRequest("POST", url, body);

        if (response.status == 200) {
            #ok(());
        } else {
            #err("Ошибка отправки сообщения в Telegram: " # Nat.toText(response.status));
        };
    };

    // Публичные функции

    // Аутентификация
    public shared (msg) func authenticate(token : AuthToken) : async Result.Result<Text, Text> {
        let userId = msg.caller;
        let user : User = {
            id = userId;
            authToken = token;
            chatId = null;
        };
        users.put(userId, user);
        #ok("Аутентификация успешна");
    };

    // Установка chatId для пользователя
    public shared (msg) func setChatId(chatId : ChatId) : async Result.Result<(), Text> {
        let userId = msg.caller;
        switch (users.get(userId)) {
            case (null) { #err("Пользователь не аутентифицирован") };
            case (?user) {
                let updatedUser : User = {
                    id = user.id;
                    authToken = user.authToken;
                    chatId = ?chatId;
                };
                users.put(userId, updatedUser);
                #ok(());
            };
        };
    };

    // Отправка сообщения
    public shared (msg) func sendMessage(content : Text) : async Result.Result<MessageId, Text> {
        let userId = msg.caller;
        switch (users.get(userId)) {
            case (null) { #err("Пользователь не аутентифицирован") };
            case (?user) {
                switch (user.chatId) {
                    case (null) {
                        #err("ChatId не установлен для пользователя");
                    };
                    case (?chatId) {
                        let messageId = nextMessageId();
                        let message : Message = {
                            id = messageId;
                            chatId = chatId;
                            from = userId;
                            content = content;
                            timestamp = Time.now();
                        };
                        messages.put(messageId, message);

                        // Отправка сообщения через Telegram Bot API
                        let sendResult = await sendTelegramMessage(chatId, content);
                        switch (sendResult) {
                            case (#ok) { #ok(messageId) };
                            case (#err(e)) { #err(e) };
                        };
                    };
                };
            };
        };
    };

    // Получение сообщения
    public query func getMessage(messageId : MessageId) : async Result.Result<Message, Text> {
        switch (messages.get(messageId)) {
            case (null) { #err("Сообщение не найдено") };
            case (?message) { #ok(message) };
        };
    };

    // Обработка входящего сообщения от Telegram (упрощенная версия)
    public func handleIncomingMessage(fromUser : Text, chatId : Text, content : Text) : async () {
        let messageId = nextMessageId();
        let message : Message = {
            id = messageId;
            chatId = chatId;
            from = Principal.fromText(fromUser);
            content = content;
            timestamp = Time.now();
        };
        messages.put(messageId, message);

        Debug.print("Получено новое сообщение: " # debug_show (message));
    };

    // Выход из системы
    public shared (msg) func logout() : async () {
        let userId = msg.caller;
        users.delete(userId);
    };

    // Получение всех сообщений пользователя
    public query (msg) func getUserMessages() : async [Message] {
        let userId = msg.caller;
        let userMessages = Buffer.Buffer<Message>(0);
        for (message in messages.vals()) {
            if (message.from == userId) {
                userMessages.add(message);
            };
        };
        Buffer.toArray(userMessages);
    };

};
