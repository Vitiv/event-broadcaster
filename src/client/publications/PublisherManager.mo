import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Option "mo:base/Option";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";
import Debug "mo:base/Debug";
import Types "../ICRC72Types";
import Utils "../Utils";

module {
    public class PublisherManager() = Self {
        type Namespace = Text;
        private var publications : HashMap.HashMap<Principal, [Types.PublicationInfo]> = HashMap.HashMap<Principal, [Types.PublicationInfo]>(10, Principal.equal, Principal.hash);

        public func register_single_publication(publisher : Principal, publication : Types.PublicationInfo) : async (Namespace, Bool) {
            // Validate the publication
            if (publication.namespace == "") {
                return (publication.namespace, false);
            };

            var publication_list = publications.get(publisher);
            switch (publication_list) {
                case (null) {
                    // Add the publication to the publications map
                    publications.put(publisher, [publication]);
                };
                case (?list) {
                    // Check if the publication already exists
                    let exists = Array.find<Types.PublicationInfo>(
                        list,
                        func(item) {
                            item.namespace == publication.namespace;
                        },
                    );
                    switch (exists) {
                        case (null) {
                            // If the publication does not exist, add it to the list
                            var updatedList : [Types.PublicationInfo] = Utils.pushIntoArray(publication, list);
                            publications.put(publisher, updatedList);
                        };
                        case (_) {
                            // if the publication already exists, return false
                            return (publication.namespace, true);
                        };
                    };
                };
            };
            return (publication.namespace, true);
        };

        public func register_publications(publisher : Principal, publications : [Types.PublicationInfo]) : async [(Namespace, Bool)] {
            let result = Buffer.Buffer<(Namespace, Bool)>(0);
            for (publication in publications.vals()) {
                let single_result = await register_single_publication(publisher, publication);
                result.add(single_result);
            };
            Buffer.toArray(result);
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
    };
};
