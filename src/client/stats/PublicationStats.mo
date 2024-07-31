import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Option "mo:base/Option";
import Hash "mo:base/Hash";
import Nat32 "mo:base/Nat32";
import Result "mo:base/Result";
import Time "mo:base/Time";
import Debug "mo:base/Debug";
import Array "mo:base/Array";
import T "../ICRC72Types";
import Utils "../Utils";

module {
    public type PublicationID = Nat;

    public type StatFields = {
        var eventCount : Nat;
        var lastEventTimestamp : Nat;
        var uniqueSources : Nat;
        namespace : Text;
        var dataSize : Nat;
        var eventsSent : Nat;
        var notifications : Nat;
        var confirmations : Nat;
        var errors : Nat;
        var subscriberCount : Nat;
    };

    public type ResponsesStats = StatFields and {
        var responsesReceived : Nat;
        var responsesAccepted : Nat;
        var responsesRejected : Nat;
        var lastResponseTimestamp : Int;
    };

    public class PublicationStats() {
        public var stats = HashMap.HashMap<PublicationID, StatFields>(10, Nat.equal, Hash.hash);
        public var sources = HashMap.HashMap<PublicationID, HashMap.HashMap<Text, Bool>>(10, Nat.equal, Hash.hash);
        public var responses = HashMap.HashMap<PublicationID, ResponsesStats>(10, Nat.equal, Hash.hash);

        public func registerPublication(id : PublicationID, registration : { namespace : Text }) : async Result.Result<Nat, Text> {
            switch (stats.get(id)) {
                case null {
                    let newStats = {
                        var eventCount = 0;
                        var lastEventTimestamp = 0;
                        var uniqueSources = 0;
                        namespace = registration.namespace;
                        var dataSize = 0;
                        var eventsSent = 0;
                        var notifications = 0;
                        var confirmations = 0;
                        var errors = 0;
                        var subscriberCount = 0;
                    };
                    stats.put(id, newStats);
                    sources.put(id, HashMap.HashMap<Text, Bool>(10, Text.equal, Text.hash));
                    #ok(0);
                };
                case (_) {
                    #err("Namespace " # registration.namespace # " already exists");
                };
            };
        };

        public func recordEvent(
            id : PublicationID,
            event : {
                timestamp : Nat;
                source : Principal;
                dataSize : Nat;
            },
        ) {
            switch (stats.get(id)) {
                case null { /* Ignore */ };
                case (?pubStats) {
                    pubStats.eventCount += 1;
                    pubStats.lastEventTimestamp := event.timestamp;
                    pubStats.dataSize += event.dataSize;

                    let pubSources = Option.get(sources.get(id), HashMap.HashMap<Text, Bool>(10, Text.equal, Text.hash));
                    let sourceKey = Principal.toText(event.source);
                    if (not Option.get(pubSources.get(sourceKey), false)) {
                        pubSources.put(sourceKey, true);
                        pubStats.uniqueSources += 1;
                    };
                };
            };
        };

        public func updateSubscribers(id : PublicationID, change : Int) {
            switch (stats.get(id)) {
                case null {
                    /* Ignoring updates for unregistered publications */
                };
                case (?pubStats) {
                    if (change > 0) {
                        pubStats.subscriberCount += Nat32.toNat(Nat32.fromIntWrap(change));
                    } else if (change < 0 and pubStats.subscriberCount > (Nat32.toNat(Nat32.fromIntWrap(-change)))) {
                        pubStats.subscriberCount -= (Nat32.toNat(Nat32.fromIntWrap(-change)));
                    };
                };
            };
        };

        public func increment(id : PublicationID, field : Text) {
            switch (stats.get(id)) {
                case null {
                    /* Ignoring updates for unregistered publications */
                };
                case (?pubStats) {
                    switch (field) {
                        case "eventsSent" { pubStats.eventsSent += 1 };
                        case "notifications" { pubStats.notifications += 1 };
                        case "confirmations" { pubStats.confirmations += 1 };
                        case "errors" { pubStats.errors += 1 };
                        case "responsesReceived" {
                            switch (responses.get(id)) {
                                case null {
                                    let newResponseStats : ResponsesStats = {
                                        var responsesReceived = 1;
                                        var responsesAccepted = 0;
                                        var responsesRejected = 0;
                                        var lastResponseTimestamp = Time.now();
                                        var eventCount = pubStats.eventCount;
                                        var lastEventTimestamp = pubStats.lastEventTimestamp;
                                        var uniqueSources = pubStats.uniqueSources;
                                        var dataSize = pubStats.dataSize;
                                        var eventsSent = pubStats.eventsSent;
                                        var notifications = pubStats.notifications;
                                        var confirmations = pubStats.confirmations;
                                        var errors = pubStats.errors;
                                        var subscriberCount = pubStats.subscriberCount;
                                        namespace = pubStats.namespace;
                                    };
                                    responses.put(id, newResponseStats);
                                };
                                case (?responseStats) {
                                    responseStats.responsesReceived += 1;
                                    responseStats.lastResponseTimestamp := Time.now();
                                };
                            };
                        };
                        case "responsesAccepted" {
                            switch (responses.get(id)) {
                                case null {
                                    /* Ignore if no response stats exist */
                                };
                                case (?responseStats) {
                                    responseStats.responsesAccepted += 1;
                                };
                            };
                        };
                        case "responsesRejected" {
                            switch (responses.get(id)) {
                                case null {
                                    /* Ignore if no response stats exist */
                                };
                                case (?responseStats) {
                                    responseStats.responsesRejected += 1;
                                };
                            };
                        };
                        case _ {}; // Ignore unknown fields
                    };
                };
            };
        };

        public func get(id : PublicationID, field : Text) : ?Nat {
            switch (stats.get(id)) {
                case null {
                    // If not found in stats, check responses
                    switch (responses.get(id)) {
                        case null { null };
                        case (?responseStats) {
                            switch (field) {
                                case "responsesReceived" {
                                    ?responseStats.responsesReceived;
                                };
                                case "responsesAccepted" {
                                    ?responseStats.responsesAccepted;
                                };
                                case "responsesRejected" {
                                    ?responseStats.responsesRejected;
                                };
                                case _ { null };
                            };
                        };
                    };
                };
                case (?pubStats) {
                    switch (field) {
                        case "eventCount" { ?pubStats.eventCount };
                        case "lastEventTimestamp" {
                            ?pubStats.lastEventTimestamp;
                        };
                        case "uniqueSources" { ?pubStats.uniqueSources };
                        case "dataSize" { ?pubStats.dataSize };
                        case "eventsSent" { ?pubStats.eventsSent };
                        case "notifications" { ?pubStats.notifications };
                        case "confirmations" { ?pubStats.confirmations };
                        case "errors" { ?pubStats.errors };
                        case "subscriberCount" { ?pubStats.subscriberCount };
                        case "responsesReceived" {
                            switch (responses.get(id)) {
                                case null { null };
                                case (?responseStats) {
                                    ?responseStats.responsesReceived;
                                };
                            };
                        };
                        case "responsesAccepted" {
                            switch (responses.get(id)) {
                                case null { null };
                                case (?responseStats) {
                                    ?responseStats.responsesAccepted;
                                };
                            };
                        };
                        case "responsesRejected" {
                            switch (responses.get(id)) {
                                case null { null };
                                case (?responseStats) {
                                    ?responseStats.responsesRejected;
                                };
                            };
                        };
                        case _ { null };
                    };
                };
            };
        };

        public func getNamespace(id : PublicationID) : ?Text {
            switch (stats.get(id)) {
                case null { null };
                case (?pubStats) { ?pubStats.namespace };
            };
        };

        public func getAll(id : PublicationID) : [(Text, Nat)] {
            var resStat = switch (stats.get(id)) {
                case null { null };
                case (?pubStats) {
                    ?[
                        ("eventCount", pubStats.eventCount),
                        ("lastEventTimestamp", pubStats.lastEventTimestamp),
                        ("uniqueSources", pubStats.uniqueSources),
                        ("dataSize", pubStats.dataSize),
                        ("eventsSent", pubStats.eventsSent),
                        ("notifications", pubStats.notifications),
                        ("confirmations", pubStats.confirmations),
                        ("errors", pubStats.errors),
                        ("subscriberCount", pubStats.subscriberCount),
                    ];
                };
            };
            var resResp = switch (responses.get(id)) {
                case null { null };
                case (?stats) {
                    ?[
                        ("responsesReceived", stats.responsesReceived),
                        ("responsesAccepted", stats.responsesAccepted),
                        ("responsesRejected", stats.responsesRejected),
                    ];
                };
            };
            Array.append(Option.get(resStat, []), Option.get(resResp, []));
        };

        public func getAllPublications() : [PublicationID] {
            Iter.toArray(stats.keys());
        };

        public func parseHeaders(headers : ?T.ICRC16Map) : (?Text, ?Text) {
            switch (headers) {
                case (?h) {
                    if (h.0 == "response") {
                        switch (h.1) {
                            case (#Map(map)) {
                                let source = switch (Utils.getValueByKey(map, "source")) {
                                    case (? #Text(text)) { ?text };
                                    case (_) { null };
                                };

                                let namespace = switch (Utils.getValueByKey(map, "namespace")) {
                                    case (? #Text(text)) { ?text };
                                    case (_) { null };
                                };
                                return (source, namespace);
                            };
                            case (_) {
                                return (null, null);
                            };
                        };
                    };
                    return (null, null);
                };
                case (null) {
                    return (null, null);
                };
            };
        };

        public func updateStats(event : T.Event, subscription : T.SubscriptionInfo, publish_result : Nat) {
            let (source, namespace) = parseHeaders(event.headers);
            let publicationID = switch (namespace, source) {
                case (?ns, ?src) {
                    getPublicationId(ns, Principal.fromText(src));
                };
                case _ { 0 }; // 0 by default
            };

            Debug.print("Updating stats for publicationID: " # debug_show (publicationID));

            // Record the event
            recordEvent(
                publicationID,
                {
                    timestamp = event.timestamp;
                    source = subscription.subscriber;
                    dataSize = getDataSize(event.data);
                },
            );

            // Increment eventsSent
            increment(publicationID, "eventsSent");

            // Update response stats
            let currentResponseStats = switch (responses.get(publicationID)) {
                case (null) {
                    Debug.print("Creating new ResponsesStats for publicationID: " # debug_show (publicationID));
                    {
                        var eventCount = 0;
                        var lastEventTimestamp = 0;
                        var uniqueSources = 0;
                        namespace = Option.get(namespace, "unknown");
                        var dataSize = 0;
                        var eventsSent = 0;
                        var notifications = 0;
                        var confirmations = 0;
                        var errors = 0;
                        var subscriberCount = 0;
                        var responsesReceived = 0;
                        var responsesAccepted = 0;
                        var responsesRejected = 0;
                        var lastResponseTimestamp = Time.now();
                    };
                };
                case (?stats) {
                    Debug.print("Updating existing ResponsesStats for publicationID: " # debug_show (publicationID));
                    stats;
                };
            };

            currentResponseStats.responsesReceived += 1;
            if (publish_result > 0) {
                currentResponseStats.responsesAccepted += 1;
            } else {
                currentResponseStats.responsesRejected += 1;
            };
            currentResponseStats.lastResponseTimestamp := Time.now();

            responses.put(publicationID, currentResponseStats);

            Debug.print(
                "Updated response stats for publicationID " # debug_show (publicationID) # ": received=" # debug_show (currentResponseStats.responsesReceived) #
                ", accepted=" # debug_show (currentResponseStats.responsesAccepted) #
                ", rejected=" # debug_show (currentResponseStats.responsesRejected) #
                ", lastTimestamp=" # debug_show (currentResponseStats.lastResponseTimestamp)
            );
        };
        public func getPublicationId(namespace : Text, source : Principal) : PublicationID {
            let combinedHash = Text.hash(namespace) ^ Principal.hash(source);
            Nat32.toNat(combinedHash) % 1_000_000;
        };

        private func getDataSize(data : T.ICRC16) : Nat {
            // TODO
            1;
        };
        // ------ Responses ------

        public func getResponsedNamespace(id : PublicationID) : Text {
            switch (responses.get(id)) {
                case null { "" };
                case (?pubStats) { pubStats.namespace };
            };
        };
        public func recordResponse(id : PublicationID) {
            switch (responses.get(id)) {
                case null { /* Ignore */ };
                case (?pubStats) {
                    pubStats.responsesReceived += 1;
                    pubStats.lastResponseTimestamp := Time.now();
                };
            };
        };

        public func recordRejectedResponse(id : PublicationID) {
            switch (responses.get(id)) {
                case null { /* Ignore */ };
                case (?pubStats) {
                    if (pubStats.responsesReceived > pubStats.responsesRejected) {
                        pubStats.responsesRejected += 1;
                    };
                };
            };
        };

        public func getLastResponseTimestamp(id : PublicationID) : ?Int {
            switch (responses.get(id)) {
                case null { null };
                case (?responseStats) {
                    Debug.print("Last response timestamp for publicationID " # debug_show (id) # ": " # debug_show (responseStats.lastResponseTimestamp));
                    ?responseStats.lastResponseTimestamp;
                };
            };
        };
    };
};
