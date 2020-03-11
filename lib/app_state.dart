import 'package:scoped_model/scoped_model.dart';

class AppState extends Model {
  var userID;
  var userAlias;
  bool isNewUser = true;
  List<String> favs = [];
  String distanceFilter;

  void setUserID(ID) { userID = ID;}
  void setUserAlias(alias) {userAlias = alias;}
  void setIsNewUser(isNew) {isNewUser = isNew;}
  void addFav(otherUserAlias) {favs.add(otherUserAlias);}
  void removeFav(otherUserAlias) {favs.remove(otherUserAlias);}
  void setDistanceFilter(dist) { distanceFilter = dist;}
}
