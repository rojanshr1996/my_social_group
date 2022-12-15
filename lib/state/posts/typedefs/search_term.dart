typedef SearchTerm = String;

class SearchModel {
  String userId;
  String searchTerm;

  SearchModel({required this.searchTerm, required this.userId});
}
