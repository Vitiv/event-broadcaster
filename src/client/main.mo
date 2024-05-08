import Client "./ICRC72Client";
import Candy "mo:candy/conversion";
import t "mo:candy/types";
import Debug "mo:base/Debug";
import Int "mo:base/Int";

actor {
  public query func greet(name : Text) : async Text {
    return "Hello, " # name # "!";
  };

  public func test() : async [(Text, Bool)] {
    let subscription : Client.SubscriptionRegistration = {
      namespace = "test";
      config = [("key", #Int(1234))];
      filter = null;
      skip = null;
      stopped = false;
    };
    let c = subscription.config[0].1;
    Debug.print("Client config: " # Int.toText(Candy.candySharedToInt(c)));

    let actual = await Client.register_subscription([subscription]);
    assert (actual[0].1 == true);
    actual;
  };
};
