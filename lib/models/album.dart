class Album {
  int id;
  String album;
  String artist;
  String albumArt;
  int numOfSongs;

  Album(this.id, this.album, this.artist, this.albumArt, this.numOfSongs);

  Album.fromJson(Map<String, dynamic> json) {
    album = json['album'];
    albumArt = json['albumArt'];
    artist = json['artist'] == "<unknown>" ? "Unknown" : json['artist'];
    id = json['id'];
    numOfSongs = json['numOfSongs'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['album'] = this.album;
    data['albumArt'] = this.albumArt;
    data['artist'] = this.artist;
    data['id'] = this.id;
    data['numOfSongs'] = this.numOfSongs;
    return data;
  }
}
