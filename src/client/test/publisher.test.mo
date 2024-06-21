import { test; suite } "mo:test/async";
import Publisher "../publications/PublisherManager";
import Principal "mo:base/Principal";
import Debug "mo:base/Debug";
import Int "mo:base/Int";
import Option "mo:base/Option";
import Bool "mo:base/Bool";
import Nat "mo:base/Nat";
import Text "mo:base/Text";

let test_publisher = Principal.fromText("aaaaa-aa");
let broadcaster = "rkp4c-7iaaa-aaaaa-aaaca-cai";
let pub = Publisher.PublisherManager();
let test_namespace = "default";

await suite(
    "Publisher method tests",
    func() : async () {
        await test(
            "register_single_publication",
            func() : async () {
                let registration = {
                    namespace = test_namespace;
                    config = [];
                };
                let result = await pub.register_single_publication(test_publisher, registration);
                Debug.print("register_single_publication result namespace: " # result.0);
                Debug.print("register_single_publication result: " # Bool.toText(result.1));
                assert (result.0 == test_namespace);
                assert (result.1 == true);
            },
        );

        await test(
            "getPublications",
            func() : async () {
                let result = await pub.getPublications(test_publisher);
                Debug.print("getPublications result size: " # Nat.toText(result.size()));
                assert (result.size() == 1);
            },
        );

        await test(
            "register_publications",
            func() : async () {
                let registrations = [{
                    namespace = test_namespace;
                    config = [];
                }];
                let result = await pub.register_publications(test_publisher, registrations);
                Debug.print("register_publications result size: " # Nat.toText(result.size()));
                for (r in result.vals()) {
                    Debug.print("register_publications result 0 namespace: " # r.0);
                    Debug.print("register_publications result 0 : " # Bool.toText(r.1));
                };

                // Debug.print("register_publications result: " # Text.concatMap(result, func(x) { x.0 # ": " # Bool.toText(x.1) }));
                assert (result[0].1 == false);
            },
        );

        await test(
            "removePublication",
            func() : async () {
                let result = await pub.removePublication(test_publisher, test_namespace);
                Debug.print("removePublication result: " # Bool.toText(result));
                assert (result == true);
            },
        );

        await test(
            "unregisterPublisher",
            func() : async () {
                let result = await pub.unregisterPublisher(test_publisher);
                Debug.print("unregisterPublisher result: " # Bool.toText(result));
                assert (result == true);
            },
        );

        await test(
            "getPublications",
            func() : async () {
                let result = await pub.getPublications(test_publisher);
                Debug.print("getPublications result size: " # Nat.toText(result.size()));
                assert (result.size() == 0); // после удаления всех публикаций размер должен быть 0
            },
        );

        await test(
            "getPublishers",
            func() : async () {
                let result = await pub.getPublishers();
                Debug.print("getPublishers result size: " # Nat.toText(result.size()));
                assert (result.size() == 0); // после удаления издателя его не должно быть в списке
            },
        );

        await test(
            "getPublicationsByNamespace",
            func() : async () {
                let result = await pub.getPublicationsByNamespace(test_publisher, test_namespace);
                // Debug.print("getPublicationsByNamespace result: " # Option.get(result, {}));
                assert (result == null); // после удаления публикаций по namespace результат должен быть null
            },
        );

        // await test(
        //     "publishEventWithResponse",
        //     func() : async () {
        //         let subscribers = [{
        //             subscriber = test_publisher;
        //             filter = [];
        //         }];
        //         let eventRelay = {
        //             id = 1;
        //             timestamp = 0;
        //             namespace = test_namespace;
        //             source = test_publisher;
        //             data = #Nat(1);
        //             headers = null;
        //             prevId = ?0;

        //         };
        //         let result = await pub.publishEventWithResponse(subscribers, eventRelay);
        //         Debug.print("publishEventWithResponse result size: " # Nat.toText(result.size()));
        //         assert (result.size() == 1);
        //     },
        // );

        // await test(
        //     "publishEventToSubscribers",
        //     func() : async () {
        //         let subscribers = [{
        //             subscriber = test_publisher;
        //             filter = [];
        //         }];
        //         let eventRelay = {
        //             id = 1;
        //             timestamp = 0;
        //             namespace = test_namespace;
        //             source = test_publisher;
        //             data = #Nat(1);
        //             headers = null;
        //             prevId = ?0;
        //         };
        //         let result = await pub.publishEventToSubscribers(subscribers, eventRelay);
        //         Debug.print("publishEventToSubscribers result size: " # Nat.toText(result.size()));
        //         assert (result.size() == subscribers.size()); // количество отправленных событий должно быть равно количеству подписчиков
        //     },
        // );

        // Negative tests

        await test(
            "removePublication with invalid namespace",
            func() : async () {
                let result = await pub.removePublication(test_publisher, "invalid_namespace");
                Debug.print("removePublication with invalid namespace result: " # Bool.toText(result));
                assert (result == false);
            },
        );

        await test(
            "unregisterPublisher that does not exist",
            func() : async () {
                let result = await pub.unregisterPublisher(Principal.fromText(broadcaster));
                Debug.print("unregisterPublisher that does not exist result: " # Bool.toText(result));
                assert (result == false);
            },
        );

        await test(
            "getPublicationsByNamespace with invalid namespace",
            func() : async () {
                let result = await pub.getPublicationsByNamespace(test_publisher, "invalid_namespace");
                // Debug.print("getPublicationsByNamespace with invalid namespace result: " # Option.toText(result));
                assert (result == null);
            },
        );
    },
);
