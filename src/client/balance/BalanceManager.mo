import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";

module {
    public class BalanceManager() = Self {
        private type Balance = Nat;
        private type UserId = Principal;
        private var balances = HashMap.HashMap<UserId, Balance>(
            0,
            Principal.equal,
            Principal.hash,
        );

        public func getBalance(userId : UserId) : async Balance {
            switch (balances.get(userId)) {
                case null return 0;
                case (?balance) return balance;
            };
        };

        public func updateBalance(userId : UserId, newBalance : Balance) : async Nat {
            balances.put(userId, newBalance);
            await getBalance(userId);
            //emitBalanceUpdatedEvent(userId, newBalance);
        };

        // public func emitBalanceUpdatedEvent(userId : UserId, newBalance : Balance) {
        //     // TODO
        // };
    };
};
