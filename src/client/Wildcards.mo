import Text "mo:base/Text";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";

actor NamespaceHandler {
    type Subscription = {
        pattern: Text;
        subscriber: Principal;
    };

    type TestResult = {
        description: Text;
        passed: Bool;
        namespace: Text;
        pattern: Text;
        expected: Bool;
        actual: Bool;
    };

    var subscriptions : [Subscription] = [];

    func splitNamespace(namespace : Text) : [Text] {
        Iter.toArray(Text.split(namespace, #char '.'));
    };

    func matchPattern(namespace : Text, pattern : Text) : Bool {
        let namespaceParts = splitNamespace(namespace);
        let patternParts = splitNamespace(pattern);

        func matchParts(np : [Text], pp : [Text]) : Bool {
            switch (np.size(), pp.size()) {
                case (0, 0) { true };
                case (_, 0) { false };
                case (_, _) {
                    if (pp[0] == "*") {
                        (np.size() > 0) and matchParts(Array.tabulate<Text>(np.size()-1, func(i : Nat) { np[i+1] }), 
                                                       Array.tabulate<Text>(pp.size()-1, func(i : Nat) { pp[i+1] }));
                    } else if (pp[0] == "**") {
                        matchParts(np, Array.tabulate<Text>(pp.size()-1, func(i : Nat) { pp[i+1] })) or
                        ((np.size() > 0) and matchParts(Array.tabulate<Text>(np.size()-1, func(i : Nat) { np[i+1] }), pp));
                    } else if (np.size() > 0 and np[0] == pp[0]) {
                        matchParts(Array.tabulate<Text>(np.size()-1, func(i : Nat) { np[i+1] }), 
                                   Array.tabulate<Text>(pp.size()-1, func(i : Nat) { pp[i+1] }));
                    } else {
                        false;
                    };
                };
            };
        };

        matchParts(namespaceParts, patternParts);
    };

    public shared(msg) func subscribe(pattern : Text) : async () {
        let subscriber = msg.caller;
        subscriptions := Array.append(subscriptions, [{pattern = pattern; subscriber = subscriber}]);
    };

    public func publish(namespace : Text, message : Text) : async () {
        for (sub in subscriptions.vals()) {
            if (matchPattern(namespace, sub.pattern)) {
                let subscriber : actor { notify : (Text) -> async () } = actor(Principal.toText(sub.subscriber));
                await subscriber.notify(message);
            };
        };
    };

    public func runTests() : async {passed: Nat; total: Nat; results: [TestResult]} {
        var testsPassed = 0;
        var totalTests = 0;
        var testResults : [TestResult] = [];

        func assertMatch(namespace : Text, pattern : Text, expected : Bool) : TestResult {
            totalTests += 1;
            let result = matchPattern(namespace, pattern);
            let passed = result == expected;
            if (passed) {
                testsPassed += 1;
            };
            {
                description = namespace # " " # (if (expected) "should match" else "should not match") # " " # pattern;
                passed = passed;
                namespace = namespace;
                pattern = pattern;
                expected = expected;
                actual = result;
            }
        };

        // Позитивные кейсы
        testResults := Array.append(testResults, [
            assertMatch("com.example.event", "com.example.event", true),
            assertMatch("com.example.event", "com.*.event", true),
            assertMatch("com.example.sub.event", "com.**.event", true),
            assertMatch("com.example.event", "com.example.*", true),
            assertMatch("com.example.event", "**.event", true),
            assertMatch("com.example.event", "com.**", true),
            assertMatch("com.example.sub.deep.event", "com.**.event", true),
            assertMatch("com.example", "com.*", true),
            assertMatch("com", "com", true)
        ]);

        // Негативные кейсы
        testResults := Array.append(testResults, [
            assertMatch("com.example.event", "org.example.event", false),
            assertMatch("com.example.subevent", "com.*.event", false),
            assertMatch("com.example.event.extra", "com.example.event", false),
            assertMatch("com.sample.event", "com.example.*", false),
            assertMatch("com.example.non_event", "**.event", false),
            assertMatch("org.example.event", "com.**", false),
            assertMatch("com", "com.*", false),
            assertMatch("", "com", false)
        ]);

        { passed = testsPassed; total = totalTests; results = testResults }
    };
};
