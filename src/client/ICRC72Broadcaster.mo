import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Iter "mo:base/Iter";
import Debug "mo:base/Debug";
import Bool "mo:base/Bool";
import Buffer "mo:base/Buffer";
import Nat64 "mo:base/Nat64";
import Int "mo:base/Int";
import Nat32 "mo:base/Nat32";

import Publisher "./publications/PublisherManager";
import SubscriptionManager "./subscriptions/SubscriptionManager";
import Types "ICRC72Types";
import T "./EthTypes";
import EthSender "./EventSender";

actor class ICRC72Broadcaster() = Self {
    type Event = {
        id : Nat;
        timestamp : Nat;
        namespace : Text;
        data : ICRC16;
    };

    type EventRelay = {
        id : Nat;
        timestamp : Nat;
        namespace : Text;
        source : Principal;
        data : ICRC16;
    };

    type EventNotification = {
        id : Nat;
        eventId : Nat;
        timestamp : Nat;
        namespace : Text;
        data : ICRC16;
        source : Principal;
    };

    type ICRC16Property = {
        name : Text;
        value : ICRC16;
        immutable : Bool;
    };

    public type ICRC16 = {
        #Array : [ICRC16];
        #Blob : Blob;
        #Bool : Bool;
        #Bytes : [Nat8];
        #Class : [ICRC16Property];
        #Float : Float;
        #Floats : [Float];
        #Int : Int;
        #Int16 : Int16;
        #Int32 : Int32;
        #Int64 : Int64;
        #Int8 : Int8;
        #Map : [(Text, ICRC16)];
        #ValueMap : [(ICRC16, ICRC16)];
        #Nat : Nat;
        #Nat16 : Nat16;
        #Nat32 : Nat32;
        #Nat64 : Nat64;
        #Nat8 : Nat8;
        #Nats : [Nat];
        #Option : ?ICRC16;
        #Principal : Principal;
        #Set : [ICRC16];
        #Text : Text;
    };

    type ICRC16Map = (Text, ICRC16);

    // ICRC3
    type Value = {
        #Nat : Nat;
        #Nat8 : Nat8;
        #Int : Int;
        #Text : Text;
        #Blob : Blob;
        #Bool : Bool;
        #Array : [Value];
        #Map : [(Text, Value)];
    };

    type Message = {
        id : Nat;
        timestamp : Nat;
        namespace : Text;
        data : ICRC16;
        source : Principal;
        filter : Text;
    };

    type SubscriptionInfo = {
        subscriber : Principal;
        namespace : Text;
        config : [ICRC16Map];
        stats : [ICRC16Map];
    };

    type SubscriberActor = actor {
        icrc72_handle_notification([Message]) : async ();
        icrc72_handle_notification_trusted([Message]) : async [{
            #Ok : Value;
            #Err : Text;
        }];
    };

    private let subManager = SubscriptionManager.SubscriptionManager();
    private let pubManager = Publisher.PublisherManager();

    public func createEvent({
        id : Nat;
        timestamp : Nat;
        namespace : Text;
        source : Principal;
        data : Text;
    }) : async [(Text, Bool)] {
        let event : Types.EventRelay = {
            id = id;
            timestamp = timestamp;
            namespace = namespace;
            source = source;
            data = #Text(data);
        };
        await handleNewEvent(event);
    };

    public shared func handleNewEvent(event : Types.EventRelay) : async [(Text, Bool)] {
        let result_buffer = Buffer.Buffer<(Text, Bool)>(0);
        let eventFilters = parseNamespace(event.namespace);
        if (eventFilters.size() == 0) {
            return [("No namespaces", false)];
        };
        // Get subscribers by filter
        for (filter in eventFilters.vals()) {
            let _principals = await subManager.getSubscribersByNamespace(filter);
            if (_principals.size() == 0) {
                return [("No subscribers by namespace", false)];
            };
            // Convert Principals to Subscribers
            let _subscribers = Array.map<Principal, Types.Subscriber>(_principals, func(p : Principal) : Types.Subscriber { { subscriber = p; filter = eventFilters } });
            // send event to subscribers
            let publish_result = await pubManager.publishEventToSubscribers(_subscribers, event);
            result_buffer.add(filter, publish_result);
        };
        Buffer.toArray(result_buffer);
    };

    func parseNamespace(namespace : Text) : [Text] {
        let delimiter = #char '.';
        let partsIter = Text.split(namespace, delimiter);
        Iter.toArray(partsIter);
    };

    public func createSubscription({
        subscriber : Principal;
        namespace : Text;
        filters : [Text];
        active : Bool;
    }) : async Bool {

        let config : [(Text, Text)] = [("key", "value")];
        let stats : [(Text, Text)] = [("key", "value")];
        let subscription : Types.SubscriptionInfo = {
            subscriber = subscriber;
            namespace = namespace;
            config = [#Text(config[0].1)];
            stats = [#Text(stats[0].1)];
            active = active;
            filters = filters;
            messagesConfirmed = 0;
            messagesReceived = 0;
            messagesRequested = 0;

        };
        await subscribe(subscription);
    };

    public shared func subscribe(subscription : Types.SubscriptionInfo) : async Bool {
        await subManager.icrc72_register_single_subscription(subscription);
    };

    public func getSubscribersByNamespace(namespace : Text) : async [Principal] {
        await subManager.getSubscribersByNamespace(namespace);
    };

    public func getSubcriptions() : async [Types.SubscriptionInfo] {
        await subManager.getSubscriptions();
    };

    public func unsubscribeAll(subscriber : Principal) : async () {
        await subManager.unsubscribeAll(subscriber);
    };

    public func unsubscribeByNamespace(subscriber : Principal, namespace : Text) : async () {
        await subManager.unsubscribeByNamespace(subscriber, namespace);
    };

    public func confirm_messages(eventIds : [Nat]) : async [Result.Result<Bool, Text>] {
        // Mark messages as confirmed
        Array.map<Nat, Result.Result<Bool, Text>>(
            eventIds,
            func(id) : Result.Result<Bool, Text> {
                #ok true;
            },
        );
    };

    public func notify_subscribers(event : Event) : async Result.Result<Bool, Text> {
        // Send notification to all subscribers
        Debug.print("notify_subscribers: event: " # Nat.toText(event.id) # " " # event.namespace);
        #ok true;
    };

    func textToICRC16(text : Text) : ICRC16 {
        #Text(text);
    };

    func textArrayToPublicationInfo(stats : [(Text, Text)]) : [Types.PublicationInfo] {
        Array.map<(Text, Text), Types.PublicationInfo>(
            stats,
            func(stat) : Types.PublicationInfo {
                { namespace = stat.0; stats = [(stat.0, textToICRC16(stat.1))] };
            },
        );
    };

    public func register_publication({
        subscriber : Principal;
        publications : [{
            namespace : Text;
            stats : [(Text, Text)];

        }];
    }) : async [(Text, Bool)] {
        let publicationInfo = textArrayToPublicationInfo(publications[0].stats);
        await pubManager.register_publications(subscriber, publicationInfo);
    };

    public func getPublications(publisher : Principal) : async [Types.PublicationInfo] {
        await pubManager.getPublications(publisher);
    };

    public func getPublishers() : async [Principal] {
        await pubManager.getPublishers();
    };

    public func unregisterPublisher(publisher : Principal) : async Bool {
        await pubManager.unregisterPublisher(publisher);
    };

    public func removePublication(publisher : Principal, namespace : Text) : async Bool {
        await pubManager.removePublication(publisher, namespace);
    };

    //----------------------------------------------------------------------------------------
    // Tests
    public func test_subc() : async (Bool, Text) {
        let subscriber = Principal.fromText("bw4dl-smaaa-aaaaa-qaacq-cai");
        let subscription : Types.SubscriptionInfo = {
            namespace = "hackathon.hackathon";
            subscriber = subscriber;
            active = true;
            filters = ["hackathon"];
            messagesReceived = 0;
            messagesRequested = 0;
            messagesConfirmed = 0;
        };

        let result = await subscribe(subscription);
        let subscribersList = await subManager.getSubscribersByNamespace(subscription.namespace);
        Debug.print("Test_subc: subscribersList size: " # Nat.toText(subscribersList.size()));
        (result, subscription.namespace);
    };

    public func test() : async [(Principal, Types.Response)] {
        // register publication and subcsribe using e2e_subscriber canister
        let subscriber = Principal.fromText("bw4dl-smaaa-aaaaa-qaacq-cai");
        let namespace = "hackathon.hackathon";
        let subscription : Types.SubscriptionInfo = {
            namespace = namespace;
            subscriber = subscriber;
            active = true;
            filters = ["hackathon"];
            messagesReceived = 0;
            messagesRequested = 0;
            messagesConfirmed = 0;
        };

        let reg_pub_result = await pubManager.register_publications(
            subscriber,
            [
                {
                    namespace = namespace;
                    stats = [("key", #Text("value"))];
                },
            ],
        );
        Debug.print("test: reg_pub_result: namespace = " # reg_pub_result[0].0 # " , result = " # Bool.toText(reg_pub_result[0].1));
        let sub_result = await subscribe(subscription);
        Debug.print("test: sub_result: " # Bool.toText(sub_result));

        // publish event using e2e_publisher canister
        let event : Types.EventRelay = {
            namespace = namespace;
            source = Principal.fromText("bw4dl-smaaa-aaaaa-qaacq-cai");
            timestamp = 0;
            data = #Text("fff");
            id = 1;
        };
        let handle_result = await handleNewEvent(event);
        Debug.print("test: handle_result: " # Bool.toText(handle_result[0].1));
        let subscribersList = await subManager.getSubscribersByNamespace(namespace);
        Debug.print("test: subscribersList size: " # Nat.toText(subscribersList.size()));
        let subscribers = Array.map<Principal, Types.Subscriber>(subscribersList, func(p : Principal) : Types.Subscriber { { subscriber = p; filter = [namespace] } });
        for (subscriber in subscribers.vals()) {
            Debug.print("test: subscriber: " # Principal.toText(subscriber.subscriber) # " , filter: " # subscriber.filter[0]);
        };
        // publish to trusted canister
        let publish_result = await pubManager.publishEventWithResponse(subscribers, event); // send event to trusted subscribers
        Debug.print("test: publish_result: ");
        publish_result;
    };

    public func test_hackathon() : async Bool {
        // Create principals for Dev, Broadcaster, and OnLineSchool
        let dev = Principal.fromText("bw4dl-smaaa-aaaaa-qaacq-cai");
        // let broadcaster = Principal.fromActor(Self);
        let school = Principal.fromText("bw4dl-smaaa-aaaaa-qaacq-cai");
        // Test Wrong Namespace
        let wrongNamespaceEvent = {
            namespace = "nonexistent.news";
            source = school;
            timestamp = 1;
            data = #Text("This should not be delivered.");
            id = 5;
        };
        let wrongNamespaceResult = await Self.handleNewEvent(wrongNamespaceEvent);
        Debug.print("test_hackathon: Test for wrong namespace event handling: " # Bool.toText(wrongNamespaceResult[0].1));
        assert (not wrongNamespaceResult[0].1);

        // School registers publications
        let school_publications : [Types.PublicationInfo] = [
            {
                namespace = "school.news";
                stats = [("key", #Text("value"))];
            },
            {
                namespace = "hackathon";
                stats = [("key", #Text("value"))];
            },
        ];

        let result_reg = await pubManager.register_publications(school, school_publications);
        Debug.print("test_hackathon: result_reg: " # result_reg[0].0 # " " # Bool.toText(result_reg[0].1)); // result_reg: school.news true
        let school_sub_result = await Self.subscribe({
            namespace = school_publications[0].namespace;
            subscriber = school;
            active = true;
            filters = ["school.news", "hackathon"];
            messagesReceived = 0;
            messagesRequested = 0;
            messagesConfirmed = 0;
        });
        Debug.print("test_hackathon: school_sub_result: " # Bool.toText(school_sub_result));
        assert school_sub_result == true;

        // Dev registers subscription to school.news
        let dev_sub_result = await Self.subscribe({
            namespace = "school.news";
            subscriber = dev;
            active = true;
            filters = ["school.news"];
            messagesReceived = 0;
            messagesRequested = 0;
            messagesConfirmed = 0;
        });
        Debug.print("test_hackathon: dev_sub_result: " # Bool.toText(dev_sub_result));
        assert dev_sub_result == true;

        // School publishes events to school.news
        let event1 = {
            namespace = "school.news";
            source = school;
            timestamp = 1;
            data = #Text("Hackathon announced! Get ready for coding challenges and prizes!");
            id = 1;
        };
        let event2 = {
            namespace = school_publications[1].namespace;
            source = school;
            timestamp = 1;
            data = #Text("Hackathon registration is now open!");
            id = 2;
        };
        let handle_event1 = await Self.handleNewEvent(event1);
        Debug.print("test_hackathon: handle_event1: " # Bool.toText(handle_event1[0].1));
        let handle_event2 = await Self.handleNewEvent(event2);
        Debug.print("test_hackathon: handle_event2: " # Bool.toText(handle_event2[0].1));

        // School registers subscription to school.hackathon
        let school_sub_result2 = await Self.subscribe({
            namespace = school_publications[1].namespace;
            subscriber = school;
            active = true;
            filters = ["hackathon"];
            messagesReceived = 0;
            messagesRequested = 0;
            messagesConfirmed = 0;
        });
        Debug.print("test_hackathon: school_sub_result2: " # Bool.toText(school_sub_result));
        assert school_sub_result2 == true;

        // Dev registers publication to dev.hackathon
        let dev_reg_pub_result = await pubManager.register_publications(dev, [{ namespace = "hackathon"; stats = [("key", #Text("value"))] }]);
        Debug.print("test_hackathon: dev_reg_pub_result: " # Bool.toText(dev_reg_pub_result[0].1));
        let dev_sub_result2 = await Self.subscribe({
            namespace = "hackathon";
            subscriber = dev;
            active = true;
            filters = ["hackathon"];
            messagesReceived = 0;
            messagesRequested = 0;
            messagesConfirmed = 0;
        });
        Debug.print("test_hackathon: dev_sub_result: " # Bool.toText(dev_sub_result2));
        assert dev_sub_result2 == true;

        // Dev publishes event to dev.hackathon
        let event3 = {
            namespace = "hackathon";
            source = dev;
            timestamp = 1;
            data = #Text("I'm registering for the hackathon!");
            id = 3;
        };
        let event3_result = await Self.handleNewEvent(event3);
        Debug.print("test_hackathon: event3_result: " # Bool.toText(event3_result[0].1));
        assert event3_result[0].1 == true;

        // School publishes final event to school.news
        let event4 = {
            namespace = "hackathon";
            source = school;
            timestamp = 1;
            data = #Text("Hackathon results are in! Congratulations to all participants.");
            id = 4;
        };
        let handle_event3 = await Self.handleNewEvent(event4);
        Debug.print("test_hackathon: handle_event3: " # Bool.toText(handle_event3[0].1));
        assert (handle_event3[0].1 == true);
        // All assertions passed
        return true;
    };

    //-----------------------------------------------------------------------------
    // Ethereum Event Sender

    public func requestCost(source : T.RpcService, jsonRequest : Text, maxResponseBytes : Nat) : async Nat {
        await EthSender.requestCost(source, jsonRequest, Nat64.fromNat(maxResponseBytes));
    };

    public func getEthLogs(source_text : Text, provider : Text, config_text : Nat, addresses : [Text], blockTagFrom : Text, fromBlock : Nat, blockTagTo : Text, toBlock : Nat, topics : [Text], cycles : Nat) : async () {
        let source = parseRpcSource(source_text, provider);
        let config = parseRpcConfig(config_text);
        let getLogArgs = parseGetLogsArgs(addresses, blockTagFrom, fromBlock, blockTagTo, toBlock, topics);
        Debug.print("getEthLogs: source: " # source_text # " , provider: " # provider # " , config: " # Nat.toText(config_text) # " , addresses: " # addresses[0] # " , blockTag: " # blockTagFrom # " , fromBlock: " # Nat.toText(fromBlock) # " , toBlock: " # Nat.toText(toBlock) # " , topics: " # topics[0]);
        // TODO result handling
        let result = await EthSender.eth_getLogs(source, config, getLogArgs, cycles);
        switch (result) {
            case (#Consistent(_)) {
                Debug.print("getEthLogs: Consistent");
            };
            case (_) {
                Debug.print("getEthLogs: Inconsistent");
            };
        };

        return;
    };

    func parseRpcSource(source_text : Text, provider : Text) : T.RpcSources {
        if (source_text == "Sepolia") {
            return #EthSepolia(?[parseEthSepoliaService(provider)]);
        } else if (source_text == "Mainnet") {
            return #EthMainnet(?[parseEthMainnetService(provider)]);
        } else {
            return #EthSepolia(?[#Alchemy]);
        };

    };

    func parseRpcConfig(config : Nat) : ?T.RpcConfig {
        ?{ responseSizeEstimate = ?Nat64.fromNat(config) };
    };

    func parseGetLogsArgs(addresses : [Text], blockTagFrom : Text, fromBlock : Nat, blockTagTo : Text, toBlock : Nat, topics : [Text]) : T.GetLogsArgs {
        {
            addresses = addresses;
            fromBlock = parseBlockTag(blockTagFrom, fromBlock);
            toBlock = parseBlockTag(blockTagTo, toBlock);
            topics = ?[topics];
        };
    };

    func parseBlockTag(blockTag : Text, number : Nat) : ?T.BlockTag {
        switch (blockTag) {
            case ("Earliest") { return ? #Earliest };
            case ("Safe") { return ? #Safe };
            case ("Finalized") { return ? #Finalized };
            case ("Latest") { return ? #Latest };
            case ("Pending") { return ? #Pending };
            case ("Number") {
                return ? #Number(number);
            };
            case (_) { return null };
        };
    };

    func parseEthSepoliaService(service : Text) : T.EthSepoliaService {
        switch (service) {
            case ("Alchemy") { return #Alchemy };
            case ("BlockPi") { return #BlockPi };
            case ("PublicNode") { return #PublicNode };
            case ("Ankr") { return #Ankr };
            case (_) { return #Alchemy };
        };
    };

    func parseEthMainnetService(service : Text) : T.EthMainnetService {
        switch (service) {
            case ("Alchemy") { return #Alchemy };
            case ("BlockPi") { return #BlockPi };
            case ("Cloudflare") { return #Cloudflare };
            case ("PublicNode") { return #PublicNode };
            case ("Ankr") { return #Ankr };
            case (_) { return #Alchemy };
        };
    };
};
