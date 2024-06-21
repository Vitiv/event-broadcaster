import { test; suite } "mo:test/async";
import Principal "mo:base/Principal";
import Debug "mo:base/Debug";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Bool "mo:base/Bool";
import Types "../ICRC72Types";
import SubscriptionManager "../subscriptions/SubscriptionManager";

let test_subscriber = Principal.fromText("aaaaa-aa");
let test_namespace = "default";
let subscriptionManager = SubscriptionManager.SubscriptionManager();

await suite(
    "SubscriptionManager method tests",
    func() : async () {
        await test(
            "icrc72_register_single_subscription",
            func() : async () {
                let subscriptionInfo = {
                    namespace = test_namespace;
                    filters = ["filter1"];
                    skip = null;
                    stopped = false;
                    subscriber = test_subscriber;
                    active = false;
                    messagesConfirmed = 0;
                    messagesReceived = 0;
                    messagesRequested = 0;
                };
                let result = await subscriptionManager.icrc72_register_single_subscription(subscriptionInfo);
                Debug.print("icrc72_register_single_subscription result: " # Bool.toText(result));
                assert (result == true);
            },
        );

        await test(
            "icrc72_register_subscription",
            func() : async () {
                let subscriptionInfos = [{
                    namespace = test_namespace;
                    filters = ["filter1"];
                    skip = null;
                    stopped = false;
                    subscriber = test_subscriber;
                    active = false;
                    messagesConfirmed = 0;
                    messagesReceived = 0;
                    messagesRequested = 0;
                }];
                let result = await subscriptionManager.icrc72_register_subscription(subscriptionInfos);
                // Debug.print("icrc72_register_subscription result: " # Text.concatMap(result, func(x) { x.0.namespace # ": " # Bool.toText(x.1) }));
                assert (result[0].1 == true);
            },
        );

        await test(
            "getSubscribersByNamespace",
            func() : async () {
                let result = await subscriptionManager.getSubscribersByNamespace(test_namespace);
                Debug.print("getSubscribersByNamespace result size: " # Nat.toText(result.size()));
                assert (result.size() == 1);
            },
        );

        await test(
            "getSubscriptionsByNamespace",
            func() : async () {
                let result = await subscriptionManager.getSubscriptionsByNamespace(test_namespace);
                Debug.print("getSubscriptionsByNamespace result size: " # Nat.toText(result.size()));
                assert (result.size() == 1);
            },
        );

        await test(
            "getSubscriptionInfo",
            func() : async () {
                let result = await subscriptionManager.getSubscriptionInfo(test_subscriber);
                Debug.print("getSubscriptionInfo result size: " # Nat.toText(result.size()));
                assert (result.size() == 1);
            },
        );

        await test(
            "getSubscriptions",
            func() : async () {
                let result = await subscriptionManager.getSubscriptions();
                Debug.print("getSubscriptions result size: " # Nat.toText(result.size()));
                assert (result.size() == 1);
            },
        );

        await test(
            "unsubscribeByNamespace",
            func() : async () {
                await subscriptionManager.unsubscribeByNamespace(test_subscriber, test_namespace);
                let result = await subscriptionManager.getSubscriptionInfo(test_subscriber);
                Debug.print("unsubscribeByNamespace result size: " # Nat.toText(result.size()));
                assert (result.size() == 0);
            },
        );

        await test(
            "unsubscribeAll",
            func() : async () {
                let res = await subscriptionManager.icrc72_register_single_subscription({
                    namespace = test_namespace;
                    filters = ["filter1"];
                    skip = null;
                    stopped = false;
                    subscriber = test_subscriber;
                    active = false;
                    messagesConfirmed = 0;
                    messagesReceived = 0;
                    messagesRequested = 0;
                });
                await subscriptionManager.unsubscribeAll(test_subscriber);
                let result = await subscriptionManager.getSubscriptionInfo(test_subscriber);
                Debug.print("unsubscribeAll result size: " # Nat.toText(result.size()));
                assert (result.size() == 0);
            },
        );

        await test(
            "updateSubscriptionStatus",
            func() : async () {
                let subscriptionInfo = {
                    namespace = test_namespace;
                    filters = ["filter1"];
                    skip = null;
                    stopped = false;
                    subscriber = test_subscriber;
                    active = false;
                    messagesConfirmed = 0;
                    messagesReceived = 0;
                    messagesRequested = 0;
                };
                let res1 = await subscriptionManager.icrc72_register_single_subscription(subscriptionInfo);
                await subscriptionManager.updateSubscriptionStatus(test_subscriber, test_namespace, true);
                let result = await subscriptionManager.getSubscriptionInfo(test_subscriber);
                // Debug.print("updateSubscriptionStatus result: " # match result[0].stopped {
                //     true => "true",
                //     false => "false"
                // });
                assert (result[0].namespace == test_namespace);
                assert (result[0].active == true);
            },
        );

        // Negative tests

        await test(
            "unsubscribeByNamespace with invalid namespace",
            func() : async () {
                let res = await subscriptionManager.icrc72_register_single_subscription({
                    namespace = test_namespace;
                    filters = ["filter1"];
                    skip = null;
                    stopped = false;
                    subscriber = test_subscriber;
                    active = false;
                    messagesConfirmed = 0;
                    messagesReceived = 0;
                    messagesRequested = 0;
                });
                await subscriptionManager.unsubscribeByNamespace(test_subscriber, "invalid_namespace");
                let result = await subscriptionManager.getSubscriptionInfo(test_subscriber);
                Debug.print("unsubscribeByNamespace with invalid namespace result size: " # Nat.toText(result.size()));
                assert (result.size() == 1);
            },
        );

        await test(
            "unsubscribeAll for non-existent subscriber",
            func() : async () {
                let non_existent_subscriber = Principal.fromText("mls5s-5qaaa-aaaal-qi6rq-cai");
                await subscriptionManager.unsubscribeAll(non_existent_subscriber);
                let result = await subscriptionManager.getSubscriptionInfo(non_existent_subscriber);
                Debug.print("unsubscribeAll for non-existent subscriber result size: " # Nat.toText(result.size()));
                assert (result.size() == 0);
            },
        );

        await test(
            "updateSubscriptionStatus for non-existent subscription",
            func() : async () {
                let test_subscriber_result = await subscriptionManager.getSubscriptionInfo(test_subscriber);
                Debug.print("updateSubscriptionStatus for non-existent subscription result size: " # Nat.toText(test_subscriber_result.size()));
                Debug.print("updateSubscriptionStatus for non-existent subscription result namespace: " # test_subscriber_result[0].namespace);
                Debug.print("updateSubscriptionStatus for non-existent subscription result status: " # Bool.toText(test_subscriber_result[0].active));
                await subscriptionManager.updateSubscriptionStatus(test_subscriber, "invalid_namespace", false);
                let result = await subscriptionManager.getSubscriptionInfo(test_subscriber);
                Debug.print("updateSubscriptionStatus for non-existent subscription size after update: " # Nat.toText(result.size()));
                Debug.print("updateSubscriptionStatus for non-existent subscription namespace after update: " # result[0].namespace);
                assert (result[0].active == true);
                Debug.print("updateSubscriptionStatus for non-existent subscription result status: " # Bool.toText(result[0].active));

            },
        );
    },
);
