import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Option "mo:base/Option";
import Time "mo:base/Time";
import Nat "mo:base/Nat";
import Result "mo:base/Result";
import Hash "mo:base/Hash";
import Nat64 "mo:base/Nat64";
import Int "mo:base/Int";

actor DAO {
    type AccountInfo = {
        balance : Nat;
        stakingInfo : ?StakingInfo;
        votingPower : Nat;
    };

    type StakingInfo = {
        amount : Nat;
        startTime : Time.Time;
        duration : Nat64;
        rewardRate : Nat;
    };

    type Proposal = {
        id : Nat;
        proposer : Principal;
        description : Text;
        voteCounts : VoteCounts;
        status : ProposalStatus;
    };

    type VoteCounts = {
        yes : Nat;
        no : Nat;
        abstain : Nat;
    };

    type Vote = {
        #Yes;
        #No;
        #Abstain;
    };

    type ProposalStatus = {
        #Active;
        #Passed;
        #Rejected;
        #Executed;
    };

    type DAOStats = {
        totalUsers : Nat;
        totalStaked : Nat;
        totalProposals : Nat;
        treasuryBalance : Nat;
    };

    type FundBalances = {
        stakingRewards : Nat;
        buyback : Nat;
        grants : Nat;
        reserve : Nat;
    };

    type Service = {
        id : Nat;
        name : Text;
        description : Text;
        price : Nat;
    };

    type Delegation = {
        from : Principal;
        to : Principal;
    };

    type Transaction = {
        id : Nat;
        from : Principal;
        to : Principal;
        amount : Nat;
        transactionType : TransactionType;
        timestamp : Time.Time;
    };

    type TransactionType = {
        #Stake;
        #Unstake;
        #Reward;
        #ServicePayment;
        #Exit;
        #Transfer;
    };

    type Result<T> = Result.Result<T, Text>;

    let accounts = HashMap.HashMap<Principal, AccountInfo>(10, Principal.equal, Principal.hash);
    let proposals = HashMap.HashMap<Nat, Proposal>(10, Nat.equal, Hash.hash);
    let services = HashMap.HashMap<Nat, Service>(10, Nat.equal, Hash.hash);
    let transactions = Array.init<Transaction>(
        1000,
        {
            id = 0;
            from = Principal.fromText("aaaaa-aa");
            to = Principal.fromText("aaaaa-aa");
            amount = 0;
            transactionType = #Transfer;
            timestamp = Time.now();
        },
    );
    var transactionCount : Nat = 0;
    var proposalCount : Nat = 0;

    public shared (msg) func createAccount() : async Result<()> {
        let caller = msg.caller;
        switch (accounts.get(caller)) {
            case (?_) { #err("Account already exists") };
            case null {
                let newAccount : AccountInfo = {
                    balance = 0;
                    stakingInfo = null;
                    votingPower = 0;
                };
                accounts.put(caller, newAccount);
                #ok(());
            };
        };
    };

    public query (msg) func getAccountInfo() : async Result<AccountInfo> {
        let caller = msg.caller;
        switch (accounts.get(caller)) {
            case (?account) { #ok(account) };
            case null { #err("Account not found") };
        };
    };

    public shared (msg) func stakeTokens(amount : Nat, duration : Nat64) : async Result<()> {
        let caller = msg.caller;
        switch (accounts.get(caller)) {
            case (?account) {
                if (account.balance < amount) {
                    return #err("Insufficient balance");
                };
                let newStakingInfo : StakingInfo = {
                    amount = amount;
                    startTime = Time.now();
                    duration = duration;
                    rewardRate = 1; // Simplified reward rate
                };
                let newAccount : AccountInfo = {
                    balance = account.balance - amount;
                    stakingInfo = ?newStakingInfo;
                    votingPower = account.votingPower + amount;
                };
                accounts.put(caller, newAccount);
                #ok(());
            };
            case null { #err("Account not found") };
        };
    };

    public shared (msg) func unstakeTokens() : async Result<()> {
        let caller = msg.caller;
        switch (accounts.get(caller)) {
            case (?account) {
                switch (account.stakingInfo) {
                    case (?stakingInfo) {
                        let end_time = stakingInfo.startTime + Nat64.toNat(stakingInfo.duration);
                        if (Time.now() < end_time) {
                            return #err("Staking period not finished");
                        };
                        let newAccount : AccountInfo = {
                            balance = account.balance + stakingInfo.amount;
                            stakingInfo = null;
                            votingPower = account.votingPower - stakingInfo.amount;
                        };
                        accounts.put(caller, newAccount);
                        #ok(());
                    };
                    case null { #err("No active staking") };
                };
            };
            case null { #err("Account not found") };
        };
    };

    public query (msg) func getStakingInfo() : async Result<StakingInfo> {
        let caller = msg.caller;
        switch (accounts.get(caller)) {
            case (?account) {
                switch (account.stakingInfo) {
                    case (?stakingInfo) { #ok(stakingInfo) };
                    case null { #err("No active staking") };
                };
            };
            case null { #err("Account not found") };
        };
    };

    public query (msg) func getTokenBalance() : async Nat {
        let caller = msg.caller;
        switch (accounts.get(caller)) {
            case (?account) { account.balance };
            case null { 0 };
        };
    };

    public shared (msg) func transferTokens(to : Principal, amount : Nat) : async Result<()> {
        let caller = msg.caller;
        switch (accounts.get(caller), accounts.get(to)) {
            case (?fromAccount, ?toAccount) {
                if (fromAccount.balance < amount) {
                    return #err("Insufficient balance");
                };
                let newFromAccount : AccountInfo = {
                    balance = fromAccount.balance - amount;
                    stakingInfo = fromAccount.stakingInfo;
                    votingPower = fromAccount.votingPower;
                };
                let newToAccount : AccountInfo = {
                    balance = toAccount.balance + amount;
                    stakingInfo = toAccount.stakingInfo;
                    votingPower = toAccount.votingPower;
                };
                accounts.put(caller, newFromAccount);
                accounts.put(to, newToAccount);
                #ok(());
            };
            case (_, _) { #err("Account not found") };
        };
    };

    //----------------------------------------

    public shared (msg) func claimRewards() : async Result<()> {
        let caller = msg.caller;
        switch (accounts.get(caller)) {
            case (?account) {
                switch (account.stakingInfo) {
                    case (?stakingInfo) {
                        let elapsedTime = Int.abs(Time.now() - stakingInfo.startTime);
                        let rewards = (stakingInfo.amount * stakingInfo.rewardRate * elapsedTime) / (365 * 24 * 3600 * 1_000_000_000);
                        let newAccount : AccountInfo = {
                            balance = account.balance + rewards;
                            stakingInfo = ?{
                                stakingInfo with startTime = Time.now()
                            };
                            votingPower = account.votingPower;
                        };
                        accounts.put(caller, newAccount);
                        #ok(());
                    };
                    case null { #err("No active staking") };
                };
            };
            case null { #err("Account not found") };
        };
    };

    public query (msg) func getPendingRewards() : async Nat {
        let caller = msg.caller;
        switch (accounts.get(caller)) {
            case (?account) {
                switch (account.stakingInfo) {
                    case (?stakingInfo) {
                        let elapsedTime = Int.abs(Time.now() - stakingInfo.startTime);
                        (stakingInfo.amount * stakingInfo.rewardRate * elapsedTime) / (365 * 24 * 3600 * 1_000_000_000);
                    };
                    case null { 0 };
                };
            };
            case null { 0 };
        };
    };

    public shared (msg) func exitDAO() : async Result<()> {
        let caller = msg.caller;
        switch (accounts.get(caller)) {
            case (?account) {
                let exitPrice = await getExitPrice();
                // Here you would transfer ICP to the user's account
                // For simplicity, we're just removing the account
                accounts.delete(caller);
                #ok(());
            };
            case null { #err("Account not found") };
        };
    };

    public query (msg) func getExitPrice() : async Nat {
        let caller = msg.caller;
        switch (accounts.get(caller)) {
            case (?account) {
                // This is a simplified calculation. In a real DAO, this would be more complex
                account.balance + Option.get(account.stakingInfo, { amount = 0 }).amount;
            };
            case null { 0 };
        };
    };

    public shared (msg) func voteOnProposal(proposalId : Nat, vote : Vote) : async Result<()> {
        let caller = msg.caller;
        switch (accounts.get(caller), proposals.get(proposalId)) {
            case (?account, ?proposal) {
                if (proposal.status != #Active) {
                    return #err("Proposal is not active");
                };
                let newVoteCounts = switch (vote) {
                    case (#Yes) {
                        {
                            proposal.voteCounts with yes = proposal.voteCounts.yes + account.votingPower
                        };
                    };
                    case (#No) {
                        {
                            proposal.voteCounts with no = proposal.voteCounts.no + account.votingPower
                        };
                    };
                    case (#Abstain) {
                        {
                            proposal.voteCounts with abstain = proposal.voteCounts.abstain + account.votingPower
                        };
                    };
                };
                let newProposal = { proposal with voteCounts = newVoteCounts };
                proposals.put(proposalId, newProposal);
                #ok(());
            };
            case (_, _) { #err("Account or proposal not found") };
        };
    };

    public query func getProposalDetails(proposalId : Nat) : async Result<Proposal> {
        switch (proposals.get(proposalId)) {
            case (?proposal) { #ok(proposal) };
            case null { #err("Proposal not found") };
        };
    };

    public query func getFundBalances() : async FundBalances {
        {
            stakingRewards = 1000; // These should be calculated based on actual DAO state
            buyback = 2000;
            grants = 3000;
            reserve = 4000;
        };
    };

    public shared (msg) func payForService(serviceId : Nat, amount : Nat) : async Result<()> {
        let caller = msg.caller;
        switch (accounts.get(caller), services.get(serviceId)) {
            case (?account, ?service) {
                if (account.balance < amount) {
                    return #err("Insufficient balance");
                };
                if (service.price != amount) {
                    return #err("Incorrect payment amount");
                };
                let newAccount : AccountInfo = {
                    balance = account.balance - amount;
                    stakingInfo = account.stakingInfo;
                    votingPower = account.votingPower;
                };
                accounts.put(caller, newAccount);
                // Here you would process the service payment
                // TODO : Process the service payment
                #ok(());
            };
            case (_, _) { #err("Account or service not found") };
        };
    };

    public query func getAvailableServices() : async [Service] {
        Iter.toArray(services.vals());
    };

    public shared (msg) func delegateVote(to : Principal) : async Result<()> {
        let caller = msg.caller;
        switch (accounts.get(caller), accounts.get(to)) {
            case (?fromAccount, ?toAccount) {
                let newFromAccount : AccountInfo = {
                    balance = fromAccount.balance;
                    stakingInfo = fromAccount.stakingInfo;
                    votingPower = 0;
                };
                let newToAccount : AccountInfo = {
                    balance = toAccount.balance;
                    stakingInfo = toAccount.stakingInfo;
                    votingPower = toAccount.votingPower + fromAccount.votingPower;
                };
                accounts.put(caller, newFromAccount);
                accounts.put(to, newToAccount);
                #ok(());
            };
            case (_, _) { #err("Account not found") };
        };
    };

    public query (msg) func getDelegations() : async [Delegation] {
        // This would require keeping track of all delegations
        // For simplicity, we're returning an empty array
        [];
    };

    public query (msg) func getTransactionHistory() : async [Transaction] {
        let caller = msg.caller;
        Array.filter<Transaction>(Array.freeze(transactions), func(t) { t.from == caller or t.to == caller });
    };

    public query func getGlobalTransactionHistory() : async [Transaction] {
        Array.freeze(transactions);
    };

    // Helper function to add a transaction to the history
    private func addTransaction(from : Principal, to : Principal, amount : Nat, transactionType : TransactionType) {
        let newTransaction : Transaction = {
            id = transactionCount;
            from = from;
            to = to;
            amount = amount;
            transactionType = transactionType;
            timestamp = Time.now();
        };
        transactions[transactionCount] := newTransaction;
        transactionCount += 1;
    };

    public shared (msg) func submitProposal(description : Text) : async Result<Bool> {
        let caller = msg.caller;
        let newProposal : Proposal = {
            id = proposalCount;
            proposer = caller;
            description = description;
            voteCounts = { yes = 0; no = 0; abstain = 0 };
            status = #Active;
        };
        proposals.put(proposalCount, newProposal);
        proposalCount += 1;
        #ok(true);
    };

    public query func getProposals() : async [Proposal] {
        Iter.toArray(proposals.vals());
    };

    public query func getDAOStats() : async DAOStats {
        {
            totalUsers = accounts.size();
            totalStaked = 0; // TODO: implement this
            totalProposals = proposalCount;
            treasuryBalance = 0; // TODO: implement this
        };
    };

};
