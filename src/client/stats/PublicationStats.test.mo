import Debug "mo:base/Debug";
import PublicationStats "PublicationStats";
import Principal "mo:base/Principal";
import Result "mo:base/Result";

actor {
    let stats = PublicationStats.PublicationStats();

    func registerPublication(id: Nat, namespace: Text) : async Result.Result<Nat, Text>  {
        await stats.registerPublication(id, { namespace = namespace });
    };

    func recordEvent(id: Nat, timestamp: Nat, source: Principal, dataSize: Nat) : async () {
        stats.recordEvent(id, { timestamp = timestamp; source = source; dataSize = dataSize });
    };

    func updateSubscribers(id: Nat, change: Int) : async () {
        stats.updateSubscribers(id, change);
    };

    func increment(id: Nat, field: Text) : async () {
        stats.increment(id, field);
    };

    func get(id: Nat, field: Text) : async ?Nat {
        stats.get(id, field)
    };

    func getAll(id: Nat) : async ?[(Text, Nat)] {
        stats.getAll(id)
    };

    // Tests
   public func runTests() : async () {
        Debug.print("Running corrected tests...");

        // Тест 1: Register new publication
        ignore await registerPublication(1, "test.namespace");
        switch (await get(1, "eventCount")) {
            case (?count) {
                assert(count == 0);
                Debug.print("Test 1 passed: Publication registered successfully");
            };
            case null {
                Debug.print("Test 1 failed: Publication not registered");
            };
        };


        // Тест 2: Save event for existing publication
        await recordEvent(1, 1000, Principal.fromText("aaaaa-aa"), 100);
        switch (await get(1, "eventCount")) {
            case (?count) {
                assert(count == 1);
                Debug.print("Test 3 passed: Event recorded successfully");
            };
            case null {
                Debug.print("Test 3 failed: Event not recorded");
            };
        };

        // Тест 3: Save event for non-existent publication
        await recordEvent(999, 2000, Principal.fromText("rvrj4-pyaaa-aaaal-ajluq-cai"), 200);
        switch (await get(999, "eventCount")) {
            case (?_) {
                Debug.print("Test 4 failed: Event recorded for non-existent publication");
            };
            case null {
                Debug.print("Test 4 passed: Event not recorded for non-existent publication");
            };
        };

        // Тест 4: Update subscribers
        await updateSubscribers(1, 5);
        switch (await get(1, "subscriberCount")) {
            case (?count) {
                assert(count == 5);
                Debug.print("Test 5 passed: Subscribers increased successfully");
            };
            case null {
                Debug.print("Test 5 failed: Subscribers not updated");
            };
        };

        // Тест 5: Decrease subscribers 
        await updateSubscribers(1, -2);
        switch (await get(1, "subscriberCount")) {
            case (?count) {
                assert(count == 3);
                Debug.print("Test 6 passed: Subscribers decreased successfully");
            };
            case null {
                Debug.print("Test 6 failed: Subscribers not updated");
            };
        };

        // Тест 6: incrementation of fields
        let fieldsToIncrement = ["eventsSent", "notifications", "confirmations", "errors"];
        for (field in fieldsToIncrement.vals()) {
            await increment(1, field);
            switch (await get(1, field)) {
                case (?count) {
                    assert(count == 1);
                    Debug.print("Test 8 passed for " # field # ": Field incremented successfully");
                };
                case null {
                    Debug.print("Test 8 failed for " # field # ": Field not incremented");
                };
            };
        };

        // Тест 7: Incrementation of nonexistent field
        await increment(1, "nonexistentField");
        switch (await get(1, "nonexistentField")) {
            case (?_) {
                Debug.print("Test 9 failed: Nonexistent field incremented");
            };
            case null {
                Debug.print("Test 9 passed: Nonexistent field not incremented");
            };
        };

        // Тест 8: Getting all stats for a publication
        switch (await getAll(1)) {
            case (?allStats) {
                assert(allStats.size() == 9);
                Debug.print("Test 10 passed: All stats retrieved successfully");
            };
            case null {
                Debug.print("Test 10 failed: Could not retrieve all stats");
            };
        };

        // Тест 9: Getting stats for a non-existent publication
        switch (await getAll(999)) {
            case (?_) {
                assert(false);
                Debug.print("Test 11 failed: Retrieved stats for non-existent publication");
            };
            case null {
                assert(true);
                Debug.print("Test 11 passed: No stats retrieved for non-existent publication");
            };
        };

        // Тест 10: Checking unique sources
        let source1 = Principal.fromText("rvrj4-pyaaa-aaaal-ajluq-cai");
        let source2 = Principal.fromText("mmt3g-qiaaa-aaaal-qi6ra-cai");
        await recordEvent(1, 3000, source1, 300);
        await recordEvent(1, 4000, source2, 400);
        await recordEvent(1, 5000, source1, 500);
        switch (await get(1, "uniqueSources")) {
            case (?count) {
                assert(count == 3);  // 2 новых источника + 1 из предыдущего теста
                Debug.print("Test 12 passed: Unique sources counted correctly");
            };
            case null {
                Debug.print("Test 12 failed: Unique sources not counted");
            };
        };

        Debug.print("All tests completed.");
    };
};
