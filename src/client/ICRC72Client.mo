import Debug "mo:base/Debug";
import Nat "mo:base/Nat";
import t "mo:candy/types";
import Principal "mo:base/Principal";

module {
    public type Message = {
        id : Nat;
        timestamp : Nat;
        namespace : Text;
        data : ICRC16;
        source : Principal;
        filter : Text;
    };

    public type Event = {
        id : Nat;
        timestamp : Nat;
        namespace : Text;
        source : Principal;
        data : ICRC16;
    };

    public type EventRelay = {
        id : Nat;
        timestamp : Nat;
        namespace : Text;
        source : Principal;
        data : ICRC16;
    };

    public type PublicationRegistration = {
        namespace : Text;
        config : [(Text, ICRC16)];
    };

    public type SubscriptionRegistration = {
        namespace : Text;
        config : [(Text, ICRC16)];
        filter : ?Text;
        skip : ?Nat;
        stopped : Bool;
    };

    public type SubscriptionUpdate = {
        subscriptionId : Nat;
        newConfig : ?[(Text, ICRC16)];
        newFilter : ?Text;
        newSkip : ?Nat;
        newStopped : ?Bool;
    };

    public type ICRC16Property = {
        name : Text;
        value : ICRC16;
        immutable : Bool;
    };

    public type ICRC16 = t.CandyShared;

    // ICRC3
    public type Value = {
        #Nat : Nat;
        #Nat8 : Nat8;
        #Int : Int;
        #Text : Text;
        #Blob : Blob;
        #Bool : Bool;
        #Array : [Value];
        #Map : [(Text, Value)];
    };

    public func icrc72_handle_notification(message : Message) : async () {
        Debug.print("Client: icrc72_event_listener: done, message:  " # Nat.toText(message.id));
    };

    public func icrc72_handle_notification_trusted(message : Message) : async ({
        #Ok : Value;
        #Err : Text;
    }) {
        Debug.print("Client: icrc72_event_listener_trusted: done, message:  " # Nat.toText(message.id));
        #Ok(#Text("Client: OK"));
    };

    public func icrc72_publish(event : Event) : async ({
        #Ok : Value;
        #Err : Text;
    }) {
        Debug.print("Client: icrc72_publish: done, event:  " # Nat.toText(event.id));
        #Ok(#Text("Client: OK"));
    };

    public func icrc72_publish_relay(event : EventRelay) : async ({
        #Ok : Value;
        #Err : Text;
    }) {
        Debug.print("Client: icrc72_publish_relay: done, event:  " # Nat.toText(event.id));
        #Ok(#Text("Client: OK"));
    };

    public func publishEvent(broadcaster : Text, event : Event) : async ({
        #Ok : Value;
        #Err : Text;
    }) {
        // Call hub.icrc72_publish(event) but we need to add publisher and filters
        Debug.print("Client: publishEvent: done, event:  " # Nat.toText(event.id) # " to " # broadcaster);
        #Ok(#Text("OK"));
    };

    public shared ({ caller }) func register_publication(registration : [PublicationRegistration]) : async [(Text, Bool)] {
        // icrc72_register_publication(vec PublicationRegistration) ->  vec Bool;
        Debug.print("Client: Register publication for namespace: " # registration[0].namespace);
        [(Principal.toText(caller), true)];
    };

    public shared ({ caller }) func register_subscription(subscription : [SubscriptionRegistration]) : async [(Text, Bool)] {
        // icrc72_register_subscription(vec SubscriptionRegistration) ->  vec Bool;
        Debug.print("Client: Register subscription for namespace: " # subscription[0].namespace);
        [(Principal.toText(caller), true)];
    };

    public func publishEventRelay(event : EventRelay) : async ({
        #Ok : Value;
        #Err : Text;
    }) {
        // icrc72_publish_event_relay(vec EventRelay) ->  vec opt variant{
        //   #Ok: vec Nat;
        //   #Err: PublishError;
        // };
        Debug.print("Client: publishEventRelay: done, event:  " # Nat.toText(event.id));
        #Ok(#Text("Client: OK"));
    };

    public func update_subscription(subscriptionId : Nat) : async Bool {
        // icrc72_update_subscription(vec SubscriptionUpdate) ->  vec[Bool];
        Debug.print("Client: Cancel subscription ID: " # Nat.toText(subscriptionId));
        true;
    };

    public func subscribe(caller : Principal, broadcaster : Text, namespace : Text, filter : ?Text, skip : ?Nat) : async Nat {
        // icrc72_subscribe(vec SubscriptionRegistration) ->  vec[Nat];
        Debug.print("Client: Subscribe to namespace: " # namespace);
        1;
    };

    // ----------------------------------------------------------
    public func get_publication_stats(broadcaster : Text, namespace : Text) : async [(Text, ICRC16)] {
        [("Client: Total Events", #Nat(10))];
    };

    public func get_subscription_stats(broadcaster : Text, namespace : Text) : async [(Text, ICRC16)] {
        [("Client: Active Subscriptions", #Nat(5))];
    };

};
