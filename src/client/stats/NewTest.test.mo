import Debug "mo:base/Debug";
import PublicationStats "./PublicationStats";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Error "mo:base/Error";
import Nat32 "mo:base/Nat32";
import Time "mo:base/Time";
import BalanceManager "../balance/BalanceManager";
import AllowListManager "../allowlist/AllowListManager";
import PublisherManager "../publications/PublisherManager";
import SubscriptionManager "../subscriptions/SubscriptionManager";
import T "../ICRC72Types";

actor {
    let publicationStats = PublicationStats.PublicationStats();
    let balanceManager = BalanceManager.BalanceManager();
    let allowListManager = AllowListManager.AllowListManager();
    let publisherManager = PublisherManager.PublisherManager();
    let subscriptionManager = SubscriptionManager.SubscriptionManager();
    public func runStatsTests() : async Text {
        var testsPassed = 0;
        var totalTests = 0;

        // Test 1: Register a new publication
        totalTests += 1;
        try {
            switch (await publicationStats.registerPublication(1, { namespace = "test.namespace" })) {
                case (#ok(_)) {
                    testsPassed += 1;
                    Debug.print("Test 1 passed: Publication registered successfully");
                };
                case (#err(e)) {
                    Debug.print("Test 1 failed: Could not register publication. Error: " # e);
                    assert false;
                };
            };
        } catch (e) {
            Debug.print("Test 1 failed with exception: " # Error.message(e));
            assert false;
        };

        // Test 2: Try to register the same publication again (should fail)
        totalTests += 1;
        try {
            switch (await publicationStats.registerPublication(1, { namespace = "test.namespace" })) {
                case (#err(_)) {
                    testsPassed += 1;
                    Debug.print("Test 2 passed: Duplicate registration failed as expected");
                };
                case (#ok(_)) {
                    Debug.print("Test 2 failed: Duplicate registration should have failed");
                    assert false;
                };
            };
        } catch (e) {
            Debug.print("Test 2 failed with exception: " # Error.message(e));
            assert false;
        };

        // Test 3: Record an event
        totalTests += 1;
        try {
            publicationStats.recordEvent(
                1,
                {
                    timestamp = Nat32.toNat(Nat32.fromIntWrap(Time.now()));
                    source = Principal.fromText("aaaaa-aa");
                    dataSize = 100;
                },
            );
            switch (publicationStats.get(1, "eventCount")) {
                case (?1) {
                    testsPassed += 1;
                    Debug.print("Test 3 passed: Event count is 1 as expected");
                };
                case (?other) {
                    Debug.print("Test 3 failed: Event count should be 1, but is " # debug_show (other));
                    assert false;
                };
                case (null) {
                    Debug.print("Test 3 failed: Event count is null");
                    assert false;
                };
            };
        } catch (e) {
            Debug.print("Test 3 failed with exception: " # Error.message(e));
            assert false;
        };

        // Test 4: Update subscribers
        totalTests += 1;
        try {
            publicationStats.updateSubscribers(1, 5);
            switch (publicationStats.get(1, "subscriberCount")) {
                case (?5) {
                    testsPassed += 1;
                    Debug.print("Test 4 passed: Subscriber count is 5 as expected");
                };
                case (?other) {
                    Debug.print("Test 4 failed: Subscriber count should be 5, but is " # debug_show (other));
                    assert false;
                };
                case (null) {
                    Debug.print("Test 4 failed: Subscriber count is null");
                    assert false;
                };
            };
        } catch (e) {
            Debug.print("Test 4 failed with exception: " # Error.message(e));
            assert false;
        };

        // Test 5: Increment various fields
        totalTests += 1;
        try {
            publicationStats.increment(1, "eventsSent");
            publicationStats.increment(1, "notifications");
            publicationStats.increment(1, "confirmations");
            publicationStats.increment(1, "errors");
            let stats = publicationStats.getAll(1);
            var allCorrect = true;
            for ((field, value) in stats.vals()) {
                if (
                    field == "eventsSent" or field == "notifications" or
                    field == "confirmations" or field == "errors"
                ) {
                    if (value != 1) {
                        allCorrect := false;
                        Debug.print("Test 5 partial fail: Field " # field # " should be 1, but is " # debug_show (value));
                    };
                };
            };
            assert allCorrect;
            if (allCorrect) {
                testsPassed += 1;
                Debug.print("Test 5 passed: All fields were incremented correctly");
            };

            // case (null) {
            //     Debug.print("Test 5 failed: Could not get stats");
            //     assert false;
            // };
            // };
        } catch (e) {
            Debug.print("Test 5 failed with exception: " # Error.message(e));
            assert false;
        };

        // Test 6: Test response handling
        totalTests += 1;
        try {
            let testSource = Principal.fromText("aaaaa-aa");
            let testNamespace = "test.namespace";
            let publicationID = publicationStats.getPublicationId(testNamespace, testSource);

            Debug.print("Test 6 - Using publicationID: " # debug_show (publicationID));

            let testEvent : T.Event = {
                id = 1;
                prevId = ?0;
                timestamp = Nat32.toNat(Nat32.fromIntWrap(Time.now()));
                namespace = testNamespace;
                source = testSource;
                data = #Text("test data");
                headers = ?("response", #Map([("source", #Text(Principal.toText(testSource))), ("namespace", #Text(testNamespace))]));
            };
            let testSubscription : T.SubscriptionInfo = {
                namespace = testNamespace;
                subscriber = testSource;
                active = true;
                filters = [];
                messagesReceived = 0;
                messagesRequested = 0;
                messagesConfirmed = 0;
            };
            let beforeUpdateTime = Time.now();
            publicationStats.updateStats(testEvent, testSubscription, 1);
            let afterUpdateTime = Time.now();

            // Check that the response was recorded
            let receivedCount = publicationStats.get(publicationID, "responsesReceived");
            let acceptedCount = publicationStats.get(publicationID, "responsesAccepted");
            let rejectedCount = publicationStats.get(publicationID, "responsesRejected");
            let lastResponseTimestamp = publicationStats.getLastResponseTimestamp(publicationID);

            Debug.print("Test 6 - responsesReceived: " # debug_show (receivedCount));
            Debug.print("Test 6 - responsesAccepted: " # debug_show (acceptedCount));
            Debug.print("Test 6 - responsesRejected: " # debug_show (rejectedCount));
            Debug.print("Test 6 - lastResponseTimestamp: " # debug_show (lastResponseTimestamp));

            switch (receivedCount, acceptedCount, rejectedCount, lastResponseTimestamp) {
                case (?received, ?accepted, ?rejected, ?timestamp) {
                    if (
                        received == 1 and accepted == 1 and rejected == 0 and
                        timestamp >= beforeUpdateTime and timestamp <= afterUpdateTime
                    ) {
                        testsPassed += 1;
                        Debug.print("Test 6 passed: Response stats updated correctly");
                    } else {
                        Debug.print(
                            "Test 6 failed: Unexpected values - received: " # debug_show (received) #
                            ", accepted: " # debug_show (accepted) #
                            ", rejected: " # debug_show (rejected) #
                            ", timestamp: " # debug_show (timestamp)
                        );
                        assert false;
                    };
                };
                case (_, _, _, _) {
                    Debug.print("Test 6 failed: Could not get response stats");
                    assert false;
                };
            };
        } catch (e) {
            Debug.print("Test 6 failed with exception: " # Error.message(e));
            assert false;
        };

        // Test 7: Test rejected response
        totalTests += 1;
        try {
            let testSource = Principal.fromText("aaaaa-aa");
            let testNamespace = "test.namespace";
            let publicationID = publicationStats.getPublicationId(testNamespace, testSource);

            let testEvent : T.Event = {
                id = 2;
                prevId = ?0;
                timestamp = Nat32.toNat(Nat32.fromIntWrap(Time.now()));
                namespace = testNamespace;
                source = testSource;
                data = #Text("test data");
                headers = ?("response", #Map([("source", #Text(Principal.toText(testSource))), ("namespace", #Text(testNamespace))]));
            };
            let testSubscription : T.SubscriptionInfo = {
                namespace = testNamespace;
                subscriber = testSource;
                active = true;
                filters = [];
                messagesReceived = 0;
                messagesRequested = 0;
                messagesConfirmed = 0;
            };
            publicationStats.updateStats(testEvent, testSubscription, 0);
            switch (publicationStats.get(publicationID, "responsesRejected")) {
                case (?1) {
                    testsPassed += 1;
                    Debug.print("Test 7 passed: Rejected responses incremented correctly");
                };
                case (?other) {
                    Debug.print("Test 7 failed: Rejected responses should be 1, but is " # debug_show (other));
                    assert false;
                };
                case (null) {
                    Debug.print("Test 7 failed: Rejected responses count is null");
                    assert false;
                };
            };
        } catch (e) {
            Debug.print("Test 7 failed with exception: " # Error.message(e));
            assert false;
        };

        // Test 8: Try to get stats for non-existent publication
        totalTests += 1;
        try {
            switch (publicationStats.get(999, "eventCount")) {
                case (null) {
                    testsPassed += 1;
                    Debug.print("Test 8 passed: Correctly returned null for non-existent publication");
                };
                case (?_) {
                    Debug.print("Test 8 failed: Should return null for non-existent publication");
                    assert false;
                };
            };
        } catch (e) {
            Debug.print("Test 8 failed with exception: " # Error.message(e));
            assert false;
        };

        // Test 9: Check last response timestamp
        totalTests += 1;
        try {
            let testSource = Principal.fromText("aaaaa-aa");
            let testNamespace = "test.namespace";
            let publicationID = publicationStats.getPublicationId(testNamespace, testSource);

            Debug.print("Test 9 - Checking last response timestamp for publicationID: " # debug_show (publicationID));

            switch (publicationStats.getLastResponseTimestamp(publicationID)) {
                case (?timestamp) {
                    assert (timestamp <= Time.now());
                    testsPassed += 1;
                    Debug.print("Test 9 passed: Last response timestamp is valid: " # debug_show (timestamp));
                };
                case (null) {
                    Debug.print("Test 9 failed: Last response timestamp should exist");
                    assert false;
                };
            };
        } catch (e) {
            Debug.print("Test 9 failed with exception: " # Error.message(e));
            assert false;
        };

        // Final result
        "Tests passed: " # debug_show (testsPassed) # " out of " # debug_show (totalTests);
    };

    // New test functions for BalanceManager
    public func testBalanceManager() : async () {
        Debug.print("Testing BalanceManager...");

        let user1 = Principal.toText(Principal.fromText("aaaaa-aa"));

        // Test updateBalance
        let updateResult = await balanceManager.updateBalance(user1, 100);
        assert (updateResult == 100);
        Debug.print("BalanceManager: updateBalance test passed");

        // Test getBalance
        let balance = await balanceManager.getBalance(user1);
        assert (balance == 100);
        Debug.print("BalanceManager: getBalance test passed");
    };

    // New test functions for AllowListManager
    public shared ({ caller }) func testAllowListManager() : async () {
        Debug.print("Testing AllowListManager...");

        // Test initAllowlist
        let deployer = Principal.fromText("bd3sg-teaaa-aaaaa-qaaba-cai");
        await allowListManager.initAllowlist(deployer);
        Debug.print("Test AllowListManager: initAllowlist completed");

        // Test getAllowList
        let allowList = await allowListManager.getAllowList();
        Debug.print("Test AllowListManager: getAllowList result: " # debug_show (allowList));
        assert (allowList.size() == 1);
        assert (allowList[0].0 == deployer);
        assert (allowList[0].1 == #Admin);
        Debug.print("Test AllowListManager: getAllowList test passed");

        // Test addToAllowList
        let user1 = "mls5s-5qaaa-aaaal-qi6rq-cai";
        Debug.print("Test AllowListManager: Updateing balance for user1");
        let updated = await balanceManager.updateBalance(user1, 100);
        Debug.print("Test AllowListManager: check balance: " # debug_show (updated));
        let addResult = await allowListManager.addToAllowList(caller, user1, #Read);
        Debug.print("Test AllowListManager: addToAllowList result: " # debug_show (addResult));
        assert (addResult == #ok(true));
        Debug.print("Test AllowListManager: addToAllowList test passed");

        // Test isUserInAllowList
        Debug.print("Test AllowListManager: isUserInAllowList starting..");
        let isInList = await allowListManager.isUserInAllowList(Principal.fromText(user1), #Read);
        assert (isInList);
        Debug.print("Test AllowListManager: isUserInAllowList test passed");

        // Final getAllowList check
        Debug.print("Test AllowListManager: final getAllowList starting..");
        let finalAllowList = await allowListManager.getAllowList();
        Debug.print("Test AllowListManager: final getAllowList result: " # debug_show (finalAllowList));
        assert (finalAllowList.size() == 2);

        Debug.print("All AllowListManager tests passed!");
    };

    // New test functions for PublisherManager
    public func testPublisherManager() : async () {
        Debug.print("Testing PublisherManager...");

        let publisher1 = Principal.fromText("aaaaa-aa");
        let namespace1 = "test.namespace";

        // Test register_single_publication
        let regResult = await publisherManager.register_single_publication(publisher1, { namespace = namespace1; config = [("key", #Text("value"))] });
        assert (regResult.1);
        Debug.print("PublisherManager: register_single_publication test passed");

        // Test getPublications
        let publications = await publisherManager.getPublications(publisher1);
        assert (publications.size() > 0);
        Debug.print("PublisherManager: getPublications test passed");

        // Test getPublishers
        let publishers = await publisherManager.getPublishers();
        assert (publishers.size() > 0);
        Debug.print("PublisherManager: getPublishers test passed");

        // Test removePublication
        let removeResult = await publisherManager.removePublication(publisher1, namespace1);
        assert (removeResult);
        Debug.print("PublisherManager: removePublication test passed");
    };

    // New test functions for SubscriptionManager
    public func testSubscriptionManager() : async () {
        Debug.print("Testing SubscriptionManager...");

        let subscriber1 = Principal.fromText("aaaaa-aa");
        let namespace1 = "test.namespace";

        let subscription : T.SubscriptionInfo = {
            namespace = namespace1;
            subscriber = subscriber1;
            active = true;
            filters = ["test"];
            messagesReceived = 0;
            messagesRequested = 0;
            messagesConfirmed = 0;
        };

        // Test icrc72_register_single_subscription
        let regResult = await subscriptionManager.icrc72_register_single_subscription(subscription);
        assert (regResult);
        Debug.print("SubscriptionManager: icrc72_register_single_subscription test passed");

        // Test getSubscribersByNamespace
        let subscribers = await subscriptionManager.getSubscribersByNamespace(namespace1);
        assert (subscribers.size() > 0);
        Debug.print("SubscriptionManager: getSubscribersByNamespace test passed");

        // Test getSubscriptionInfo
        let subscriptionInfo = await subscriptionManager.getSubscriptionInfo(subscriber1);
        assert (subscriptionInfo.size() > 0);
        Debug.print("SubscriptionManager: getSubscriptionInfo test passed");

        // Test unsubscribeByNamespace
        await subscriptionManager.unsubscribeByNamespace(subscriber1, namespace1);
        let updatedSubscriptionInfo = await subscriptionManager.getSubscriptionInfo(subscriber1);
        assert (updatedSubscriptionInfo.size() == 0);
        Debug.print("SubscriptionManager: unsubscribeByNamespace test passed");
    };

    public func runAllTests() : async () {
        let statTestResult = await runStatsTests();
        Debug.print("Stats tests: " # statTestResult);
        await testBalanceManager();
        await testPublisherManager();
        await testSubscriptionManager();
        await testAllowListManager();
        Debug.print("All tests completed.");
    };
};
