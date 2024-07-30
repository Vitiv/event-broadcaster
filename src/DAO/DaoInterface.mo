import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Nat "mo:base/Nat";
import Text "mo:base/Text";

module {
    public type AccountInfo = {
        balance : Nat;
        stakingInfo : ?StakingInfo;
        votingPower : Nat;
    };

    public type StakingInfo = {
        amount : Nat;
        startTime : Time.Time;
        duration : Nat64;
        rewardRate : Nat;
    };

    public type Proposal = {
        id : Nat;
        proposer : Principal;
        description : Text;
        voteCounts : VoteCounts;
        status : ProposalStatus;
    };

    public type VoteCounts = {
        yes : Nat;
        no : Nat;
        abstain : Nat;
    };

    public type Vote = {
        #Yes;
        #No;
        #Abstain;
    };

    public type ProposalStatus = {
        #Active;
        #Passed;
        #Rejected;
        #Executed;
    };

    public type DAOStats = {
        totalUsers : Nat;
        totalStaked : Nat;
        totalProposals : Nat;
        treasuryBalance : Nat;
    };

    public type FundBalances = {
        stakingRewards : Nat;
        buyback : Nat;
        grants : Nat;
        reserve : Nat;
    };

    public type Service = {
        id : Nat;
        name : Text;
        description : Text;
        price : Nat;
    };

    public type Delegation = {
        from : Principal;
        to : Principal;
    };

    public type Transaction = {
        id : Nat;
        from : Principal;
        to : Principal;
        amount : Nat;
        transactionType : TransactionType;
        timestamp : Time.Time;
    };

    public type TransactionType = {
        #Stake;
        #Unstake;
        #Reward;
        #ServicePayment;
        #Exit;
        #Transfer;
    };

    public type Result<T> = {
        #Ok : T;
        #Err : Text;
    };

    // Методы (объявления функций)

    public type DAOInterface = actor {
        // Управление аккаунтом
        createAccount : (userId : Principal) -> async Result<()>;
        getAccountInfo : (userId : Principal) -> async Result<AccountInfo>;

        // Стейкинг
        stakeTokens : (userId : Principal, amount : Nat, duration : Nat64) -> async Result<()>;
        unstakeTokens : (userId : Principal) -> async Result<()>;
        getStakingInfo : (userId : Principal) -> async Result<StakingInfo>;

        // Управление токенами
        getTokenBalance : (userId : Principal) -> async Nat;
        transferTokens : (from : Principal, to : Principal, amount : Nat) -> async Result<()>;

        // Награды
        claimRewards : (userId : Principal) -> async Result<()>;
        getPendingRewards : (userId : Principal) -> async Nat;

        // Выход из ДАО
        exitDAO : (userId : Principal) -> async Result<()>;
        getExitPrice : (userId : Principal) -> async Nat;

        // Governance
        submitProposal : (userId : Principal, proposal : Proposal) -> async Result<()>;
        voteOnProposal : (userId : Principal, proposalId : Nat, vote : Vote) -> async Result<()>;
        getProposals : () -> async [Proposal];
        getProposalDetails : (proposalId : Nat) -> async Result<Proposal>;

        // Информация о ДАО
        getDAOStats : () -> async DAOStats;
        getFundBalances : () -> async FundBalances;

        // Услуги ДАО
        payForService : (userId : Principal, serviceId : Nat, amount : Nat) -> async Result<()>;
        getAvailableServices : () -> async [Service];

        // Делегирование голосов
        delegateVote : (from : Principal, to : Principal) -> async Result<()>;
        getDelegations : (userId : Principal) -> async [Delegation];

        // Аудит и прозрачность
        getTransactionHistory : (userId : Principal) -> async [Transaction];
        getGlobalTransactionHistory : () -> async [Transaction];
    };
};
