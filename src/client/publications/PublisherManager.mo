import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Option "mo:base/Option";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import Hash "mo:base/Hash";
import Text "mo:base/Text";
import Types "../ICRC72Types";
import Utils "../Utils";

module {
    public class PublisherManager() = Self {
        type Namespace = Text;
        type PublicationId = (Principal, Namespace);

        func combineHashes(hash1 : Hash.Hash, hash2 : Hash.Hash) : Hash.Hash {
            return hash1 * 31 + hash2;
        };

        func hashPublicationId(pubId : PublicationId) : Hash.Hash {
            let hashPrincipal = Principal.hash(pubId.0);
            let hashNamespace = Text.hash(pubId.1);
            return combineHashes(hashPrincipal, hashNamespace);
        };

        func eqPublicationId(id1 : PublicationId, id2 : PublicationId) : Bool {
            Principal.equal(id1.0, id2.0) and Text.equal(id1.1, id2.1);
        };

        private var publications : HashMap.HashMap<Principal, [Types.PublicationInfo]> = HashMap.HashMap<Principal, [Types.PublicationInfo]>(10, Principal.equal, Principal.hash);
        private var publicationStats = HashMap.HashMap<PublicationId, HashMap.HashMap<Text, Types.ICRC16>>(10, eqPublicationId, hashPublicationId);

        public func register_single_publication(publisher : Principal, publication : Types.PublicationRegistration) : async (Namespace, Bool) {
            // Validate the publication
            if (publication.namespace == "") {
                return (publication.namespace, false);
            };
            let pub = await getPublicationsByNamespace(publisher, publication.namespace);
            switch (pub) {
                case (?(_)) {
                    // If the publication is already registered, return false
                    return (publication.namespace, false);
                };
                case (null) {
                    let publicationInfo : Types.PublicationInfo = {
                        namespace = publication.namespace;
                        stats = [];
                    };
                    var publication_list = publications.get(publisher);
                    switch (publication_list) {
                        case (null) {
                            publications.put(publisher, [publicationInfo]);
                        };
                        case (?list) {
                            let updatedList : [Types.PublicationInfo] = Utils.pushIntoArray(publicationInfo, list);
                            publications.put(publisher, updatedList);
                        };
                    };
                };
            };

            (publication.namespace, true);
        };

        public func register_publications(publisher : Principal, publications : [Types.PublicationRegistration]) : async [(Namespace, Bool)] {
            let result = Buffer.Buffer<(Namespace, Bool)>(publications.size());
            for (publication in publications.vals()) {
                let single_result = await register_single_publication(publisher, publication);
                result.add(single_result);
            };
            Buffer.toArray(result);
        };

        public func removePublication(publisher : Principal, namespace : Namespace) : async Bool {
            var publication_list = publications.get(publisher);
            switch (publication_list) {
                case (null) {
                    // If the publisher is not registered, return false
                    false;
                };
                case (?list) {
                    // Remove the publication from the publications map
                    let updatedList = Array.filter<Types.PublicationInfo>(
                        list,
                        func(item) {
                            item.namespace != namespace;
                        },
                    );
                    publications.put(publisher, updatedList);
                    true;
                };
            };
        };

        public func unregisterPublisher(publisher : Principal) : async Bool {
            var publication_list = publications.get(publisher);
            switch (publication_list) {
                case (null) {
                    // If the publisher is not registered, return false
                    false;
                };
                case (?list) {
                    // Remove the publication from the publications map
                    ignore publications.remove(publisher);
                    true;
                };
            };
        };

        public func getPublications(publisher : Principal) : async [Types.PublicationInfo] {
            Option.get(publications.get(publisher), []);
        };

        public func getPublishers() : async [Principal] {
            Iter.toArray(publications.keys());
        };

        public func getPublicationsByNamespace(publisher : Principal, namespace : Namespace) : async ?Types.PublicationInfo {
            var publication_list = publications.get(publisher);
            switch (publication_list) {
                case (null) {
                    // If the publisher is not registered, return an empty list
                    return null;
                };
                case (?list) {
                    // Get the publication by namespace
                    let publication = Array.find<Types.PublicationInfo>(
                        list,
                        func(item) {
                            item.namespace == namespace;
                        },
                    );
                    publication;
                };
            };
        };

        // Method to publish an event to all subscribers
        public func publishEventWithResponse(subscribers : [Types.Subscriber], event : Types.EventRelay) : async [(Principal, Types.Response)] {
            let buffer = Buffer.Buffer<(Principal, Types.Response)>(0);
            for (subscriber in subscribers.vals()) {
                let subscriber_actor : Types.SubscriberActor = actor (Principal.toText(subscriber.subscriber));
                let message : Types.Message = {
                    id = event.id;
                    namespace = event.namespace;
                    source = event.source;
                    timestamp = event.timestamp;
                    data = event.data;
                    filter = subscriber.filter;
                };
                Debug.print("PubManager.publishEventWithResponse: Sending message to subscriber: " # Principal.toText(subscriber.subscriber));
                let response = await subscriber_actor.icrc72_handle_notification_trusted([message]);
                buffer.add((subscriber.subscriber, response));
            };
            return Buffer.toArray(buffer);
        };

        public func publishEventToSubscribers(subscribers : [Types.Subscriber], event : Types.EventRelay) : async Bool {
            var result = false;
            // send event to all subscribers
            for (subscriber in subscribers.vals()) {
                let subscriber_actor : Types.SubscriberActor = actor (Principal.toText(subscriber.subscriber));
                let message : Types.Message = {
                    id = event.id;
                    namespace = event.namespace;
                    source = event.source;
                    timestamp = event.timestamp;
                    data = event.data;
                    filter = subscriber.filter;
                };

                await subscriber_actor.icrc72_handle_notification([message]);
                result := true;
            };
            result;
        };

        // Stats
        public func getPublicationStats(publisher : Principal, namespace : Text) : async [(Text, Types.ICRC16)] {
            let statMap = publicationStats.get((publisher, namespace));
            switch (statMap) {
                case (null) {
                    return [];
                };
                case (?stats) {
                    // HashMap <Text, ICRC16> to [(Text, ICRC16)]
                    let buffer = Buffer.Buffer<(Text, Types.ICRC16)>(stats.size());
                    for (stat in stats.entries()) {
                        buffer.add((stat.0, stat.1));
                    };
                    return Buffer.toArray(buffer);
                };
            };
        };

        // key = "messagesSent"
        public func increasePublicationMessagesSentStats(publisher : Principal, namespace : Text, key : Text) : async Nat {
            let statMap = publicationStats.get((publisher, namespace));
            switch (statMap) {
                case (null) {
                    let statHashMap : HashMap.HashMap<Text, Types.ICRC16> = HashMap.HashMap<Text, Types.ICRC16>(1, Text.equal, Text.hash);
                    statHashMap.put(key, #Nat(1));
                    publicationStats.put((publisher, namespace), statHashMap);
                };
                case (?stats) {
                    let stat = stats.get(key);
                    switch (stat) {
                        case (null) {
                            stats.put(key, #Nat(1));
                        };
                        case (?icrc16) {
                            switch (icrc16) {
                                case (#Nat(n)) {
                                    stats.put(key, #Nat(n + 1));
                                    return n + 1;
                                };
                                case (_) { stats.put(key, #Nat(1)) };
                            };

                        };
                    };
                };
            };
            return 1;
        };

        public func updatePublicationStats(publisher : Principal, namespace : Text, stats : [(Text, Types.ICRC16)]) : async () {
            let statHashMap : HashMap.HashMap<Text, Types.ICRC16> = HashMap.HashMap<Text, Types.ICRC16>(stats.size(), Text.equal, Text.hash);
            for (stat in stats.vals()) {
                statHashMap.put(stat.0, stat.1);
            };
            publicationStats.put((publisher, namespace), statHashMap);
        };
    };
};
