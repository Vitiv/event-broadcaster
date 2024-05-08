import Debug "mo:base/Debug";
import Nat "mo:base/Nat";
import t "mo:candy/types";
import Principal "mo:base/Principal";

module {
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

    public shared ({ caller }) func register_publication(registration : [PublicationRegistration]) : async [(Text, Bool)] {
        Debug.print("Publisher: Register publication for namespace: " # registration[0].namespace);
        [(Principal.toText(caller), true)];
    };

    public func icrc72_publish(event : Event) : async ({
        #Ok : Value;
        #Err : Text;
    }) {
        Debug.print("Publisher: icrc72_publish: done, event:  " # Nat.toText(event.id));
        #Ok(#Text("Publisher: OK"));
    };

    public func icrc72_publish_relay(event : EventRelay) : async ({
        #Ok : Value;
        #Err : Text;
    }) {
        Debug.print("Publisher: icrc72_publish_relay: done, event:  " # Nat.toText(event.id));
        #Ok(#Text("Publisher: OK"));
    };

    public func publishEvent(broadcaster : Text, event : Event) : async ({
        #Ok : Value;
        #Err : Text;
    }) {
        Debug.print("Publisher: publishEvent: done, event:  " # Nat.toText(event.id) # " to " # broadcaster);
        #Ok(#Text("OK"));
    };

    public func get_publication_stats(broadcaster : Text, namespace : Text) : async [(Text, ICRC16)] {
        [("Publisher: Total Events", #Nat(10))];
    };
};
