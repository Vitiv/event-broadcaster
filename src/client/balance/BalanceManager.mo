import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Debug "mo:base/Debug";
/*
TODO: - subscribe to DAO balance event
        - handle notification and get size of member's message package
        - set a limit on the size of the message package as user's balance
*/
module {
    public class BalanceManager() = Self {
        private type Balance = Nat;
        private type UserId = Text;
        private type SubscriberId = Text;
        public let balances = HashMap.HashMap<UserId, Balance>(
            0,
            Text.equal,
            Text.hash,
        );

        // type Ledger = actor {
        //     getBalance(UserId) : async Balance;
        // };

        // var balanceLedgerId = "2xdbt-dqaaa-aaaal-ajkja-cai";

        // public func initBalance(userId : UserId) : async () {
        //     // TODO get from balance ledger
        //     /*
        //     let balanceLedger : Ledger = actor(balanceLedgerId);
        //     let newBalance = await balanceLedger.getBalance(userId);
        //     */
        //     let newBalance = 10;
        //     balances.put(userId, newBalance);
        // };

        public func getBalance(userId : UserId) : async Balance {
            switch (balances.get(userId)) {
                case null {
                    Debug.print("BalanceManager.getBalance, user: " # userId # " has no balance");
                    return 0;
                };
                case (?balance) {
                    Debug.print("BalanceManager.getBalance, user: " # userId # " balance: " # debug_show (balance));
                    return balance;
                };
            };
        };

        public func updateBalance(userId : UserId, newBalance : Balance) : async Nat {
            balances.put(userId, newBalance);
            // emitBalanceUpdatedEvent(userId, newBalance);
            Debug.print("BalanceManager.updateBalance, user: " # userId # " newBalance: " # debug_show (newBalance));
            await getBalance(userId);
        };

        // public func setBalanceLedgerCanisterId(newBalanceLedgerId : Text) : async Bool {
        //     balanceLedgerId := newBalanceLedgerId;
        //     true;
        // };

        // public func emitBalanceUpdatedEvent(userId : UserId, newBalance : Balance) {
        //     // TODO

        // };
    };
};
