package com.npkompleet.beatz.models;

public class Album {
    private long id;
    private String album;
    private String artist;
    private String albumArt="";
    private int numOfSongs;

    public Album(){}

    public Album(int id, String album, String artist, String albumArt, int numOfSongs){
        this.id = id;
        this.album = album;
        this.artist = artist;
        this.albumArt = albumArt;
        this.numOfSongs = numOfSongs;
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String getAlbum() {
        return album;
    }

    public void setAlbum(String album) {
        this.album = album;
    }

    public String getArtist() {
        return artist;
    }

    public void setArtist(String artist) {
        this.artist = artist;
    }

    public String getAlbumArt() {
        return albumArt;
    }

    public void setAlbumArt(String albumArt) {
        this.albumArt = albumArt;
    }

    public int getNumOfSongs() {
        return numOfSongs;
    }

    public void setNumOfSongs(int numOfSongs) {
        this.numOfSongs = numOfSongs;
    }
}
