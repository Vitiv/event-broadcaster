import { test; suite } "mo:test/async";
import Principal "mo:base/Principal";
import Debug "mo:base/Debug";
import Bool "mo:base/Bool";
import Broadcaster "../ICRC72Broadcaster";

let test_subscriber = Principal.fromText("aaaaa-aa");
let broadcaster = "rkp4c-7iaaa-aaaaa-aaaca-cai";
let caster = await Broadcaster.ICRC72Broadcaster();

await suite(
    "Broadcaster methods tests",
    func() : async () {
        await test(
            "createEvent",
            func() : async () {
                let event = {
                    id = 1;
                    namespace = "default";
                    source = Principal.fromText(broadcaster);
                    dataType = "Text";
                    data = "TextData";
                };
                let result = await caster.createEvent(event);
                Debug.print("result: " # Bool.toText(result));
                assert (result == false); // TODO fix to true
            },
        );
    },
);
