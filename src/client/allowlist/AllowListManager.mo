import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Hash "mo:base/Hash";
import Debug "mo:base/Debug";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import T "../ICRC72Types";
import SubscriptionManager "../subscriptions/SubscriptionManager";
import BalanceManager "../balance/BalanceManager";

module {
    public class AllowListManager(sm : SubscriptionManager.SubscriptionManager, bm : BalanceManager.BalanceManager) = Self {
        type Set<T> = HashMap.HashMap<T, Null>;

        type UserPermission = (Principal, T.Permission);

        var _deployer = Principal.fromText("bs3e6-4i343-voosn-wogd7-6kbdg-mctak-hn3ws-k7q7f-fye2e-uqeyh-yae");
        var _initialized = false;

        public func initAllowlist(deployer : Principal) : async () {
            let initResult = await setDeployer(deployer);
            switch (initResult) {
                case (#ok(_)) {
                    // Add deployer to the allow list with Admin permission
                    allowList.put((deployer, #Admin), null);
                    Debug.print("Deployer added to allow list: " # Principal.toText(deployer));
                };
                case (#err(e)) {
                    Debug.print("Failed to initialize allowlist: " # e);
                };
            };
            // create subscription to get $EVENT balance updates
            let subscription : T.SubscriptionInfo = {
                namespace = "event.hub.event.balance";
                filters = ["balance.update"];
                active = true;
                subscriber = _deployer;
                messagesReceived = 0;
                messagesRequested = 0;
                messagesConfirmed = 0;
            };
            let create_subscription = await sm.icrc72_register_single_subscription(subscription);
            if (not create_subscription) {
                Debug.print("Failed to create subscription");
            };

            Debug.print("AllowListManager: Initialized allowlist successfully");
        };

        private func setDeployer(deployer : Principal) : async Result.Result<Text, Text> {
            if (not _initialized) {
                _deployer := deployer;
                _initialized := true;
                return #ok("Deployer set to " # Principal.toText(deployer));
            } else {
                if (not Principal.equal(deployer, _deployer)) {
                    _deployer := deployer;
                    Debug.print("Deployer changed to " # Principal.toText(deployer));
                    return #ok("Deployer set to " # Principal.toText(deployer));
                };
            };
            #err("Do not allow change of deployer");
        };

        public var allowList : Set<UserPermission> = HashMap.HashMap<UserPermission, Null>(
            10,
            func(x : UserPermission, y : UserPermission) : Bool {
                return x == y; // Compare both Principal and Permission
            },
            func(x : UserPermission) : Hash.Hash {
                let principalHash = Principal.hash(x.0);
                let permissionHash = switch (x.1) {
                    case (#Admin) 1;
                    case (#Read) 2;
                    case (#Write) 3;
                };
                return principalHash ^ (Hash.hash(permissionHash) >> 1);
            },
        );

        // public func initStore(store : [(Principal, T.Permission)]) {
        //     for ((principal, permission) in store.vals()) {
        //         allowList.put((principal, permission), null);
        //     };
        // };

        // TODO Replace logic to checking $Event balance
        public func addToAllowList(caller : Principal, user : Text, permission : T.Permission) : async Result.Result<Bool, Text> {
            Debug.print("AllowListManager.addToAllowList AllowList: " # debug_show (await getAllowList()));
            let isAdmin = await isUserInAllowList(caller, #Admin);
            if (isAdmin) {
                allowList.put((Principal.fromText(user), permission), null);
                Debug.print("AllowListManager.addToAllowList User added to allow list: " # user);
                Debug.print("AllowListManager.addToAllowList AllowList: " # debug_show (await getAllowList()));
                return #ok true;
            } else {
                return #err("Only admins allowed");
            };
        };

        public func isUserInAllowList(user : Principal, permission : T.Permission) : async Bool {
            switch (allowList.get((user, permission))) {
                case (?_) true;
                case null {
                    let balance = await bm.getBalance(Principal.toText(user));
                    Debug.print("AllowListManager.isUserInAllowList balance: " # debug_show (balance));
                    if (balance > 0) {
                        allowList.put((user, permission), null);
                        return true;
                    } else return false;
                };
            };
        };

        public func getAllowList() : async [UserPermission] {
            return Iter.toArray(allowList.keys());
        };

        public func test() : async (Bool, Bool) {
            let user1 = Principal.fromText("mls5s-5qaaa-aaaal-qi6rq-cai");
            let user2 = Principal.fromText("aaaaa-aa");
            let user3 = Principal.fromText("mmt3g-qiaaa-aaaal-qi6ra-cai");

            allowList.put((user1, #Admin), null);
            allowList.put((user2, #Read), null);
            allowList.put((user3, #Write), null);

            let isUser1Admin = await isUserInAllowList(user1, #Admin); //  true
            let isUser3Writer = await isUserInAllowList(user3, #Read); //  false
            return (isUser1Admin, isUser3Writer);
        };
    };
};
