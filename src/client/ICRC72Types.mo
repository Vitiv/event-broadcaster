import Nat64 "mo:base/Nat64";
import Buffer "mo:base/Buffer";

module {
    public type ICRC16Property = {
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

    //ICRC3 Value
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

    public type Map = [(Text, ICRC16)];

    public type ICRC16ValueMap = { key : ICRC16; value : ICRC16 };

    public type PublisherInfo = {
        publisher : Principal; // The principal ID of the publisher canister
        publicationCount : Nat; // Total number of publications made by this publisher
        cyclesReceived : ?Nat; // Optional field to track cycles received from subscribers or for use in micropayments
        messagesSent : Nat; // Total number of messages sent by this publisher
        notifications : Nat; // Total notifications triggered by the publisher's messages
        notificationsConfirmed : Nat; // Total notifications confirmed by subscribers
        subscriberCount : Nat; // Count of subscribers registered for this publisher's messages
    };

    public func equalPublisherInfo(a : PublisherInfo, b : PublisherInfo) : Bool {
        a.publisher == b.publisher and a.publicationCount == b.publicationCount and a.cyclesReceived == b.cyclesReceived and a.messagesSent == b.messagesSent and a.notifications == b.notifications and a.notificationsConfirmed == b.notificationsConfirmed and a.subscriberCount == b.subscriberCount
    };
    public type PublicationRegistration = {
        namespace : Text; // The namespace of the publication for categorization and filtering
        config : Map; // Additional configuration or metadata about the publication
        // publishers : ?[Principal]; // Optional list of publishers authorized to publish under this namespace
        // subscribers : ?[Principal]; // Optional list of subscribers authorized to subscribe to this namespace
        // mode : Nat; // Publication mode (e.g., sequential, ranked, etc.)
    };

    public type PublicationInfo = {
        namespace : Text; // The namespace of the publication
        stats : Map; // Additional statistics or metadata about the publication
        // publisherCount : Nat; // Number of publishers associated with this namespace
        // messages : Nat; // Total number of messages under this publication
        // messagesSent : Nat; // Count of messages sent in this namespace
        // notifications : Nat; // Notifications generated by the publication
        // notificationConfirmations : Nat; // Number of notifications confirmed by subscribers
        // subscriberCount : Nat; // Number of subscribers to this publication
    };

    public type PublishError = {
        #Unauthorized;
        #ImproperId : Text;
        #Busy; // This Broadcaster is busy at the moment and cannot process requests
        #GenericError : GenericError;
    };

    public type GenericError = {
        error_code : Nat;
        message : Text;
    };

    public func equalPublicationInfo(a : PublicationInfo, b : PublicationInfo) : Bool {
        a.namespace == b.namespace and a.stats == b.stats
    };

    public type Subscriber = {
        subscriber : Principal; // The principal ID of the subscriber canister
        filter : [Text]; // A list of event filters specifying what types of messages this subscriber wants to receive
    };

    // public type EventFilter = {
    //     namespace : Text; // Namespace of the events to subscribe to for organized categorization
    //     eventType : Text; // Type of event this filter applies to, allows filtering specific types of events within a namespace
    //     filterDetails : Text; // Additional filter criteria, possibly a JSON-like query string or similar expressive format for complex filtering
    // };
    public type SubscriptionRegistration = {
        namespace : Text; // The namespace to which the subscription pertains
        filters : [Text]; // Filters defining what messages should be received
        skip : ?Nat; // Optional parameter to skip certain numbers of messages (e.g., for paging)
        stopped : Bool; // Flag to determine whether the subscription is active or temporarily stopped
        config : Map;

    };

    public type SubscriptionInfo = {
        namespace : Text; // The namespace of the subscription
        subscriber : Principal; // Principal ID of the subscriber
        active : Bool; // Indicates whether the subscription is currently active
        filters : [Text]; // Currently active filters for this subscription
        messagesReceived : Nat; // Total number of messages received under this subscription
        messagesRequested : Nat; // Number of messages explicitly requested or queried by the subscriber
        messagesConfirmed : Nat; // Number of messages confirmed by the subscriber (acknowledgment of processing or receipt)
    };

    public func mapValueToICRC16(data : Value) : ICRC16 {
        switch (data) {
            case (#Nat(v)) #Nat(v);
            case (#Nat8(v)) #Nat8(v);
            case (#Int(v)) #Int(v);
            case (#Text(v)) #Text(v);
            case (#Blob(v)) #Blob(v);
            case (#Bool(v)) #Bool(v);
            case (#Array(v)) {
                let result = Buffer.Buffer<ICRC16>(v.size());
                for (item in v.vals()) {
                    result.add(mapValueToICRC16(item));
                };
                #Array(Buffer.toArray(result));
            };
            case (#Map(v)) {
                let result = Buffer.Buffer<(Text, ICRC16)>(v.size());
                for (item in v.vals()) {
                    result.add((item.0, mapValueToICRC16(item.1)));
                };
                #Map(Buffer.toArray(result));
            };
        };
    };

    public func appendArray<X>(array1 : [X], array2 : [X]) : [X] {
        let buffer1 = Buffer.fromArray<X>(array1);
        let buffer2 = Buffer.fromArray<X>(array2);
        buffer1.append(buffer2);
        Buffer.toArray(buffer1);
    };

    public type Response = {
        #Ok : Value;
        #Err : Text;
    };

    public type Event = {
        id : Nat;
        prevId : ?Nat;
        timestamp : Nat;
        namespace : Text;
        source : Principal;
        data : ICRC16;
        headers : ?ICRC16Map;
    };

    public type EventNotification = {
        id : Nat;
        eventId : Nat;
        preEventId : ?Nat;
        timestamp : Nat;
        namespace : Text;
        data : ICRC16;
        source : Principal;
        headers : ?ICRC16Map;
        filter : ?Text;
    };

    public type ICRC16Map = (Text, ICRC16);

    public type SubscriberActor = actor {
        icrc72_handle_notification([EventNotification]) : async ();
        icrc72_handle_notification_trusted([EventNotification]) : async {
            #Ok : Value;
            #Err : Text;
        };

    };

    // New Subscriber Types
    type Skip = {
        mod : Nat;
        offset : ?Nat;
    };

    type SubscriptionConfig = [ICRC16Map];

    // type SubscriptionRegistration = {
    //     namespace : Text;
    //     config : SubscriptionConfig;
    //     memo : ?Blob;
    // };

    // type SubscriptionInfo = {
    //     subscriptionId : Nat;
    //     subscriber : Principal;
    //     namespace : Text;
    //     config : SubscriptionConfig;
    //     stats : [ICRC16Map];
    // };

    type SubscriptionUpdate = {
        subscriptionId : Nat;
        newConfig : ?SubscriptionConfig;
    };

    type Subscription = {
        subscriptionId : Nat;
        subscriber : Principal;
        namespace : Text;
        config : SubscriptionConfig;
        memo : ?Blob;
        stats : [ICRC16Map];
    };

    public type Permission = {
        #Admin;
        #Read;
        #Write;
    };

    public type Reason = Text;
    public type RejectedResponse = (Principal, Nat, Reason);

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
};
