import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Result "mo:base/Result";

module {
    public type SubscriberID = Principal;

    public type StatFields = {
        var activeSubscriptions : Nat;
        var totalSubscriptions : Nat;
        var lastSubscriptionTimestamp : Nat;
        var messagesReceived : Nat;
        var messagesConfirmed : Nat;
        var dataReceived : Nat;
        var errors : Nat;
    };

    public class SubscriptionStats() {
        private let stats = HashMap.HashMap<SubscriberID, StatFields>(10, Principal.equal, Principal.hash);

        public func registerSubscriber(id : SubscriberID) : async Result.Result<Nat, Text> {
            switch (stats.get(id)) {
                case null {
                    let newStats = {
                        var activeSubscriptions = 0;
                        var totalSubscriptions = 0;
                        var lastSubscriptionTimestamp = 0;
                        var messagesReceived = 0;
                        var messagesConfirmed = 0;
                        var dataReceived = 0;
                        var errors = 0;
                    };
                    stats.put(id, newStats);
                    #ok(0);
                };
                case (_) {
                    #err("Subscriber " # Principal.toText(id) # " already registered");
                };
            };
        };

        public func recordSubscription(id : SubscriberID, timestamp : Nat) {
            switch (stats.get(id)) {
                case null { /* Ignore */ };
                case (?subStats) {
                    subStats.activeSubscriptions += 1;
                    subStats.totalSubscriptions += 1;
                    subStats.lastSubscriptionTimestamp := timestamp;
                };
            };
        };

        public func recordUnsubscription(id : SubscriberID) {
            switch (stats.get(id)) {
                case null { /* Ignore */ };
                case (?subStats) {
                    if (subStats.activeSubscriptions > 0) {
                        subStats.activeSubscriptions -= 1;
                    };
                };
            };
        };

        public func recordMessageReceived(id : SubscriberID, dataSize : Nat) {
            switch (stats.get(id)) {
                case null { /* Ignore */ };
                case (?subStats) {
                    subStats.messagesReceived += 1;
                    subStats.dataReceived += dataSize;
                };
            };
        };

        public func recordMessageConfirmed(id : SubscriberID) {
            switch (stats.get(id)) {
                case null { /* Ignore */ };
                case (?subStats) {
                    subStats.messagesConfirmed += 1;
                };
            };
        };

        public func recordError(id : SubscriberID) {
            switch (stats.get(id)) {
                case null { /* Ignore */ };
                case (?subStats) {
                    subStats.errors += 1;
                };
            };
        };

        public func get(id : SubscriberID, field : Text) : ?Nat {
            switch (stats.get(id)) {
                case null { null };
                case (?subStats) {
                    switch (field) {
                        case "activeSubscriptions" {
                            ?subStats.activeSubscriptions;
                        };
                        case "totalSubscriptions" {
                            ?subStats.totalSubscriptions;
                        };
                        case "lastSubscriptionTimestamp" {
                            ?subStats.lastSubscriptionTimestamp;
                        };
                        case "messagesReceived" { ?subStats.messagesReceived };
                        case "messagesConfirmed" { ?subStats.messagesConfirmed };
                        case "dataReceived" { ?subStats.dataReceived };
                        case "errors" { ?subStats.errors };
                        case _ { null };
                    };
                };
            };
        };

        public func getAll(id : SubscriberID) : ?[(Text, Nat)] {
            switch (stats.get(id)) {
                case null { null };
                case (?subStats) {
                    ?[
                        ("activeSubscriptions", subStats.activeSubscriptions),
                        ("totalSubscriptions", subStats.totalSubscriptions),
                        ("lastSubscriptionTimestamp", subStats.lastSubscriptionTimestamp),
                        ("messagesReceived", subStats.messagesReceived),
                        ("messagesConfirmed", subStats.messagesConfirmed),
                        ("dataReceived", subStats.dataReceived),
                        ("errors", subStats.errors),
                    ];
                };
            };
        };

        public func getAllSubscribers() : [SubscriberID] {
            Iter.toArray(stats.keys());
        };
    };
};
