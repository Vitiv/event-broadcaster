import Time "mo:base/Time";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Buffer "mo:base/Buffer";
import PublicationStats "./PublicationStats";

module {
    public type Reason = Text;
    public type RejectedResponse = (Principal, Nat, Reason);

    public class RejectedResponsesHandler(publicationStats : PublicationStats.PublicationStats) {
        private let THREE_DAYS_NANOS : Int = 3 * 24 * 60 * 60 * 1_000_000_000;

        public func handleRejectedResponses(msg : Principal, publicationId : Nat, rejectedResponses : [RejectedResponse]) : async [(Principal, Nat, Bool)] {
            let results = Buffer.Buffer<(Principal, Nat, Bool)>(rejectedResponses.size());

            for ((subscriber, responseId, reason) in rejectedResponses.vals()) {
                let lastResponseTimestamp = publicationStats.getLastResponseTimestamp(publicationId);

                switch (lastResponseTimestamp) {
                    case null {
                        results.add((subscriber, responseId, false));
                    };
                    case (?timestamp) {
                        if (Time.now() - timestamp <= THREE_DAYS_NANOS) {
                            publicationStats.recordRejectedResponse(publicationId);
                            results.add((subscriber, responseId, true));
                        } else {
                            results.add((subscriber, responseId, false));
                        };
                    };
                };
            };

            Buffer.toArray(results);
        };
    };
};
