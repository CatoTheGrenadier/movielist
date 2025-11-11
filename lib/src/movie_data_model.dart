import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

String api_key = "";

class MovieResults{
  List<MovieItem> movies = [];
  bool cached = false;

  MovieResults({
    required this.movies,
  });

  Future<MovieResults> init() async {
    MovieResults newMovie = MovieResults(movies: []);
    if (!cached){
      cached = true;
      String jsonString = await fetchMovieResultJson();
      if (jsonString != Null){
        writeJsonToFile(jsonString, "assets\\JsonFiles\\movieDataCache.json");
        newMovie = MovieResults.fromJson(jsonString);
      }
    } else {
      String jsonString = await readJsonFromFile("assets/JsonFiles/movieDataCache.json");
      if (jsonString != Null){
        newMovie = MovieResults.fromJson(jsonString);
      }
    }
    return newMovie;
  }

  factory MovieResults.fromJson(String jsonString){
    Map<String,dynamic> jsonData = json.decode(jsonString);
    var results = jsonData['results'] as List;
    List<MovieItem> movies = results.map((movieJson) => MovieItem.fromJson(movieJson)).toList();
    return MovieResults(
      movies: movies,
    );
  }

  Future<String> fetchMovieResultJson() async {
    final response = await http.get(Uri.parse("https://api.themoviedb.org/3/movie/popular?api_key=$api_key"));
    if (response.statusCode == 200){
      return response.body;
    } else {
      throw Exception('Failed to load movie results');
    }
  }

  void writeJsonToFile(String jsonData, String fileName) async {
    Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    String filePath = '${appDocumentsDir.path}/$fileName';
    File file = File(filePath);
    await file.writeAsString(jsonData);
  }

  Future<String> readJsonFromFile(String filePath) async {
    try {
      String contents = await rootBundle.loadString(filePath);
      return contents;
    } catch (error) {
      throw Exception('Failed to read JSON from file: $error');
    }
  }
}

class MovieItem{
  int id = 0;
  String posterPath = "null";
  String title = "null";
  double voteAverage = 0.0;
  int voteCount = 0;
  String releaseDate = "null";
  String backdropPath = "null";
  String overview = "null";
  String originalTitle = "null";
  double popularity = 0.0;
  List<int> genresID = [];

  MovieItem({
    required this.id,
    required this.posterPath,
    required this.title,
    required this.voteAverage,
    required this.voteCount,
    required this.releaseDate,
    required this.backdropPath,
    required this.overview,
    required this.originalTitle,
    required this.popularity,
    required this.genresID,
  });

  factory MovieItem.fromJson(Map<String,dynamic> json){
    return MovieItem(
      id: json["id"] ?? 0,
      posterPath: json["poster_path"] ?? "",
      title: json["title"] ?? "",
      voteAverage: json["vote_average"] ?? 0.0,
      voteCount: json["vote_count"] ?? 0,
      releaseDate: json["release_date"] ?? "",
      backdropPath: json["backdrop_path"] ?? "",
      overview: json["overview"] ?? "",
      originalTitle: json["original_title"] ?? "",
      popularity: json["popularity"] ?? 0.0,
      genresID: (json['genre_ids'] as List<dynamic>).cast<int>(),
    );
  }
}

class MoviePics{
  List<PicItem> backdrops = [];
  List<PicItem> posters = [];
  List<PicItem> logos = [];

  MoviePics({
    required this.backdrops,
    required this.posters,
    required this.logos,
  });

  Future<MoviePics> init(int id) async {
    MoviePics newMoviePics = MoviePics(backdrops: [],posters: [], logos: []);
    String jsonString = await fetchMoviePicsJson(id);
    newMoviePics = MoviePics.fromJson(jsonString);
    return newMoviePics;
  }

  Future<String> fetchMoviePicsJson(int id) async {
    final response = await http.get(Uri.parse("https://api.themoviedb.org/3/movie/$id/images?api_key=$api_key"));
    if (response.statusCode == 200){
      return response.body;
    } else {
      throw Exception('Failed to load movie pics');
    }
  }
  
  factory MoviePics.fromJson(String jsonString){
    Map<String,dynamic> jsonData = json.decode(jsonString);
    var backdrops = jsonData['backdrops'] as List;
    var posters = jsonData['posters'] as List;
    var logos = jsonData['logos'] as List;
    List<PicItem> newBackdrops = backdrops.map((picJson) => PicItem.fromJson(picJson)).toList();
    List<PicItem> newPosters = posters.map((picJson) => PicItem.fromJson(picJson)).toList();
    List<PicItem> newLogos = logos.map((picJson) => PicItem.fromJson(picJson)).toList();
    return MoviePics(
      backdrops: newBackdrops,
      posters: newPosters,
      logos: newLogos,
    );
  }
}

class PicItem{
  String file_path = "null";

  PicItem({
    required this.file_path,
  });

  factory PicItem.fromJson(Map<String,dynamic> json){
    return PicItem(
      file_path: json["file_path"]
    );
  }
}

class MovieGenres{
  List<GenreItem> genres = [];

  MovieGenres({
    required this.genres
  });

  factory MovieGenres.fromJson(String jsonString){
    Map<String,dynamic> jsonData = json.decode(jsonString);
    var genres = jsonData['genres'] as List;
    List<GenreItem> newGenres = genres.map((genreJson) => GenreItem.fromJson(genreJson)).toList();
    return MovieGenres(
      genres: newGenres
    );
  }
}

class GenreItem{
  int id = 0;
  String name = "null";

  GenreItem({
    required this.id,
    required this.name,
  });

  factory GenreItem.fromJson(Map<String,dynamic> json){
    return GenreItem(
      id:json["id"],
      name: json["name"],
    );
  }
}

class GenresMap{
  Map<int,String> storedMap = {};

  Future<GenresMap> init() async {
    GenresMap newGenresMap = GenresMap();
    MovieGenres newMovieGenres = MovieGenres(genres: []);
    final response = await http.get(Uri.parse("https://api.themoviedb.org/3/genre/movie/list?api_key=$api_key"));
    if (response.statusCode == 200){
      newMovieGenres = MovieGenres.fromJson(response.body);
      newMovieGenres.genres.forEach((genre) { 
        newGenresMap.storedMap[genre.id] = genre.name;
      });
      return newGenresMap;
    } else {
      throw Exception('Failed to load movie pics');
    }
  }
}

class DeletedMovies{
  List<int> deleted = [];

  DeletedMovies({
    required this.deleted,
  });

  Map<String, dynamic> toJson() {
    return {
      'deleted': deleted,
    };
  }

  Future<DeletedMovies> init() async {
    DeletedMovies newDeletedMovies = DeletedMovies(deleted: []);
    String jsonString = await newDeletedMovies.readDeletedFromFile();
    newDeletedMovies = DeletedMovies.fromJson(jsonString);
    return newDeletedMovies;
  }

  factory DeletedMovies.fromJson(String jsonString){
    Map<String,dynamic> jsonData = json.decode(jsonString);
    List<int> newDeleted = (jsonData['deleted'] as List<dynamic>).cast<int>();
    return DeletedMovies(
      deleted: newDeleted,
    );
  }

  void encodeAndWriteDeletedToFile() async {
    String fileName = "assets\\JsonFiles\\deleted.json";
    String jsonData = jsonEncode(this);
    Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    String filePath = '${appDocumentsDir.path}/$fileName';
    File file = File(filePath);
    await file.writeAsString(jsonData);
  }

  Future<String> readDeletedFromFile() async {
    try {
      String filePath = "assets/JsonFiles/deleted.json";
      String contents = await rootBundle.loadString(filePath);
      return contents;
    } catch (error) {
      throw Exception('Failed to read JSON from file: $error');
    }
  }

  void deleteMovie(int id){
    this.deleted.add(id);
    return;
  }
}
