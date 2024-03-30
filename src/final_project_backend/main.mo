import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Float "mo:base/Float";
import Text "mo:base/Text";

actor NearbyNotificationPlatform {

  type User = {
    id: Nat;
    name: Text;
    location: {latitude: Float; longitude: Float};
  };

  type Notification = {
    id: Nat;
    message: Text;
    senderId: Nat;
  };

  let users : [User] = [];
  let notifications : [Notification] = [];

  public func addUser(id: Nat, name: Text, latitude: Float, longitude: Float) : async () {
    let newUser = { id = id; name = name; location = {latitude = latitude; longitude = longitude}; };
    users := Array.append<User>(users, [newUser]);
  };

  public func sendNotification(senderId: Nat, message: Text) : async () {
    let newNotification = { id = Nat32.toNat(Array.size<Notification>(notifications)); message = message; senderId = senderId; };
    notifications := Array.append<Notification>(notifications, [newNotification]);
  };

  public func sendNotificationToNearbyUsers(senderId: Nat, message: Text, radius: Float) : async {
    let sender = newUser.findUserById(senderId.id);
    switch (sender) {
      case (null) {};
      case (?senderUser) {
        let nearbyUsers = Array.filter<User>(users, func(u : User) : Bool {
          return distance(u.location, senderUser.location) <= radius && u.id != senderId;
        });
        Array.iter<Notification>(nearbyUsers, func(user : User) {
          ignore sendNotification(user.id, message);
        });
      };
    };
  }

  func findUserById(id: Nat) : ?User {
    return Array.find<User>(users, func(u : User) : Bool { u.id == id });
  }

  func distance(location1: {latitude: Float; longitude: Float}, location2: {latitude: Float; longitude: Float}) : Float {
    let latDiff = location1.latitude - location2.latitude;
    let longDiff = location1.longitude - location2.longitude;
    return Math.sqrt(Float.add(Float.mul(latDiff, latDiff), Float.mul(longDiff, longDiff)));
  }
}
