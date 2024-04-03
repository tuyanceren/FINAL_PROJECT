import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Float "mo:base/Float";
import Text "mo:base/Text";
import Debug "mo:base/Debug";
import Bool "mo:base/Bool";

actor NearbyNotificationPlatform {

  type User = {
    id : Nat;
    name : Text;
    location : { latitude : Float; longitude : Float };
  };

  type Notification = {
    id : Nat;
    message : Text;
    senderId : Nat;
    receiverId : Nat;
  };

  var users : [User] = [];
  var notifications : [Notification] = [];

  public func addUser(id : Nat, name : Text, latitude : Float, longitude : Float) : async Bool {
    let user = findUserById(id);
    if (user != null) {
      return false ;
    };

    let newUser = {
      id = id;
      name = name;
      location = { latitude = latitude; longitude = longitude };
    };
    users := Array.append<User>(users, [newUser]);
    return true;
  };
  // 
  func sendNotification(senderId : Nat, user : User, message : Text) : async () {
    let newNotification = {
      id = (Array.size<Notification>(notifications));
      message = message;
      senderId = senderId;
      receiverId = user.id;
    };
    notifications := Array.append<Notification>(notifications, [newNotification]);

  };

  public query func printNotification(): async Text{
    var output : Text = "NOTIFICATION";
    for (notif in notifications.vals()) {
      output #= "Notification sent from " # Nat.toText(notif.senderId) # " to " # Nat.toText(notif.receiverId) # ": " # notif.message;

    };
    return output;
  };
  public func sendNotificationToNearbyUsers(senderId : Nat, message : Text, radius : Float) : async () {
    let sender = findUserById(senderId);
    switch (sender) {
      case (null) {};
      case (?senderUser) {
        let nearbyUsers = Array.filter<User>(
          users,
          func(u : User) : Bool {
            return distance(u.location, senderUser.location) <= radius and u.id != senderId;
          },
        );
        for (user in nearbyUsers.vals()) {
          ignore sendNotification(senderId, user, message);
        };

      };
    };
  };

  func findUserById(id : Nat) : ?User {
    return Array.find<User>(users, func(u : User) : Bool { u.id == id });
  };
 // Euclidean distance between the user
  func distance(location1 : { latitude : Float; longitude : Float }, location2 : { latitude : Float; longitude : Float }) : Float {
    let latDiff = location1.latitude - location2.latitude;
    let longDiff = location1.longitude - location2.longitude;
    return Float.sqrt(latDiff * latDiff + longDiff * longDiff);
  };

};
