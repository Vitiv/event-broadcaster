import { test; suite } "mo:test/async";
import Publisher "../Publisher";
import Principal "mo:base/Principal";
import Debug "mo:base/Debug";
import Int "mo:base/Int";
import Option "mo:base/Option";

let test_subscriber = Principal.fromText("aaaaa-aa");
let broadcaster = "rkp4c-7iaaa-aaaaa-aaaca-cai";

await suite(
    "Publisher method tests",
    func() : async () {
        await test(
            "subscribe",
            func() : async () {
                // public shared ({ caller }) func register_publication(registration : [PublicationRegistration]) : async [(Text, Bool)] {
                /*
public type PublicationRegistration = {
        namespace : Text;
        config : [(Text, ICRC16)];
    };*/
                let registration = {
                    namespace = "default";
                    config = [];
                };
                let result = await Publisher.register_publication([registration]);
                Debug.print("result: " # result[0].0);
                assert (result[0].1 == true);
            },
        );

        await test(
            "icrc72_publish",
            func() : async () {
                /*
                 public func icrc72_publish(event : Event) : async ({
        #Ok : Value;
        #Err : Text;
    })
                 public type Event = {
        id : Nat;
        timestamp : Nat;
        namespace : Text;
        source : Principal;
        data : ICRC16;
    };
                */
                let event = {
                    id = 1;
                    timestamp = 1;
                    namespace = "default";
                    source = test_subscriber;
                    data = #Int(1);
                };
                let result = await Publisher.icrc72_publish(event);
                Debug.print("result: ");
                assert (result == #Ok(#Int(1)));
            },
        );

        // negative tests

    },
);
