import PublicationStats "../stats/PublicationStats";
import SubStats "../stats/SubscriptionStats";
import BalanceManager "../balance/BalanceManager";
import AllowListManager "../allowlist/AllowListManager";
import PublisherManager "../publications/PublisherManager";
import SubscriptionManager "../subscriptions/SubscriptionManager";
import RejectedHandler "../stats/RejectedResponsesHandler";

module {
    public class AppContext() {
        public let publicationStats = PublicationStats.PublicationStats();
        public let balanceManager = BalanceManager.BalanceManager();
        public let subscriptionManager = SubscriptionManager.SubscriptionManager();
        public let allowListManager = AllowListManager.AllowListManager(subscriptionManager, balanceManager);
        public let publisherManager = PublisherManager.PublisherManager(allowListManager);
        public let subscriptionStats = SubStats.SubscriptionStats();
        public let rejectHandler = RejectedHandler.RejectedResponsesHandler(publicationStats);

    };
};
