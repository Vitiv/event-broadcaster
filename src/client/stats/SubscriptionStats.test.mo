import Debug "mo:base/Debug";
import SubscriptionStats "SubscriptionStats";
import Principal "mo:base/Principal";

actor {
    let stats = SubscriptionStats.SubscriptionStats();

    public func runTests() : async () {
        Debug.print("Running SubscriptionStats tests...");

        let subscriber1 = Principal.fromText("aaaaa-aa");
        let subscriber2 = Principal.fromText("rvrj4-pyaaa-aaaal-ajluq-cai");

        // Test 1: Register new subscriber
        switch (await stats.registerSubscriber(subscriber1)) {
            case (#ok(_)) {
                assert (true);
                Debug.print("Test 1 passed: Subscriber registered successfully");
            };
            case (#err(_)) {
                assert (false);
                Debug.print("Test 1 failed: Subscriber not registered");
            };
        };

        // Test 2: Register duplicate subscriber
        switch (await stats.registerSubscriber(subscriber1)) {
            case (#ok(_)) {
                assert (false);
                Debug.print("Test 2 failed: Duplicate subscriber registered");
            };
            case (#err(_)) {
                assert (true);
                Debug.print("Test 2 passed: Duplicate subscriber registration prevented");
            };
        };

        // Test 3: Record subscription
        stats.recordSubscription(subscriber1, 1000);
        switch (stats.get(subscriber1, "activeSubscriptions")) {
            case (?count) {
                assert (count == 1);
                Debug.print("Test 3 passed: Subscription recorded successfully");
            };
            case null {
                assert (false);
                Debug.print("Test 3 failed: Subscription not recorded");
            };
        };

        // Test 4: Record unsubscription
        stats.recordUnsubscription(subscriber1);
        switch (stats.get(subscriber1, "activeSubscriptions")) {
            case (?count) {
                assert (count == 0);
                Debug.print("Test 4 passed: Unsubscription recorded successfully");
            };
            case null {
                assert (false);
                Debug.print("Test 4 failed: Unsubscription not recorded");
            };
        };

        // Test 5: Record message received
        stats.recordMessageReceived(subscriber1, 100);
        switch (stats.get(subscriber1, "messagesReceived")) {
            case (?count) {
                assert (count == 1);
                Debug.print("Test 5 passed: Message received recorded successfully");
            };
            case null {
                assert (false);
                Debug.print("Test 5 failed: Message received not recorded");
            };
        };

        // Test 6: Record message confirmed
        stats.recordMessageConfirmed(subscriber1);
        switch (stats.get(subscriber1, "messagesConfirmed")) {
            case (?count) {
                assert (count == 1);
                Debug.print("Test 6 passed: Message confirmed recorded successfully");
            };
            case null {
                assert (false);
                Debug.print("Test 6 failed: Message confirmed not recorded");
            };
        };

        // Test 7: Record error
        stats.recordError(subscriber1);
        switch (stats.get(subscriber1, "errors")) {
            case (?count) {
                assert (count == 1);
                Debug.print("Test 7 passed: Error recorded successfully");
            };
            case null {
                assert (false);
                Debug.print("Test 7 failed: Error not recorded");
            };
        };

        // Test 8: Get non-existent field
        switch (stats.get(subscriber1, "nonexistentField")) {
            case (?_) {
                assert (false);
                Debug.print("Test 8 failed: Retrieved non-existent field");
            };
            case null {
                assert (true);
                Debug.print("Test 8 passed: Non-existent field not retrieved");
            };
        };

        // Test 9: Get all stats for a subscriber
        switch (stats.getAll(subscriber1)) {
            case (?allStats) {
                assert (allStats.size() == 7);
                Debug.print("Test 9 passed: All stats retrieved successfully");
            };
            case null {
                assert (false);
                Debug.print("Test 9 failed: Could not retrieve all stats");
            };
        };

        // Test 10: Get stats for a non-existent subscriber
        switch (stats.getAll(subscriber2)) {
            case (?_) {
                assert (false);
                Debug.print("Test 10 failed: Retrieved stats for non-existent subscriber");
            };
            case null {
                assert (true);
                Debug.print("Test 10 passed: No stats retrieved for non-existent subscriber");
            };
        };

        // Test 11: Get all subscribers
        let allSubscribers = stats.getAllSubscribers();
        assert (allSubscribers.size() == 1);
        assert (allSubscribers[0] == subscriber1);
        Debug.print("Test 11 passed: All subscribers retrieved successfully");

        Debug.print("All SubscriptionStats tests completed.");
    };
};
