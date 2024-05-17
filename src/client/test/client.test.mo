import { test; suite } "mo:test/async";
import Subscriber "../Subscriber";
import Principal "mo:base/Principal";
import Debug "mo:base/Debug";
import Int "mo:base/Int";
import Option "mo:base/Option";

let test_subscriber = Principal.fromText("aaaaa-aa");
let broadcaster = "rkp4c-7iaaa-aaaaa-aaaca-cai";

await suite(
    "Subscriber method tests",
    func() : async () {
        await test(
            "subscribe",
            func() : async () {
                let subscribeResult = await Subscriber.register_subscription(
                    broadcaster,
                    test_subscriber,
                    [{
                        namespace = "default";
                        config = [];
                        filter = ?{ topic = "TestFilter"; condition = null };
                        skip = null;
                        stopped = false;
                    }],
                );
                assert (subscribeResult[0].1 == true);

            },
        );

        await test(

            "icrc72_handle_notification",
            func() : async () {

                let message = {
                    id = 1;
                    timestamp = 1;
                    namespace = "default";
                    data = #Int(1234);
                    source = Principal.fromText(broadcaster);
                    filter = "TestFilter";
                };
                await Subscriber.icrc72_handle_notification([message]);
            },
        );

        // negative tests

        // await test(
        //     "subscribe with invalid filter",
        //     func() : async () {
        //         let subscribeResult = await Subscriber.register_subscription(
        //             broadcaster,
        //             [{
        //                 namespace = "default";
        //                 config = [];
        //                 filter = ?"InvalidFilter";
        //                 skip = null;
        //                 stopped = false;
        //             }],
        //         );
        //         assert (subscribeResult[0].1 == false);
        //     },
        // );

        // await test(
        //     "get subscriptions with invalid subscriber",
        //     func() : async () {
        //         let subscriptions = await Subscriber.get_subscriptions(
        //             Principal.fromText("invalid-subscriber"),
        //         );
        //         assert (subscriptions == []);
        //     },
        // );
    },
);
