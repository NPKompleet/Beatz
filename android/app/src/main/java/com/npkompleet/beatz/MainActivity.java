package com.npkompleet.beatz;

import android.Manifest;
import android.app.LoaderManager;
import android.content.CursorLoader;
import android.content.Loader;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.os.Build;
import android.os.Bundle;
import android.provider.MediaStore.Audio.Media;
import android.provider.MediaStore.Audio.Albums;
import android.util.Log;

import com.google.gson.Gson;
import com.npkompleet.beatz.models.Album;
import com.npkompleet.beatz.models.AudioMedia;

import java.util.ArrayList;
import java.util.HashMap;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity implements LoaderManager.LoaderCallbacks<Cursor>{
    private static final String CHANNEL = "com.npkompleet.beatz";
    private static final String FETCH_ALBUMS_METHOD = "fetchAlbums";
    private static final String FETCH_SONGS_FROM_ALBUM_METHOD = "fetchSongsFromAlbum";
    private static final int ALBUM_LIST_LOADER_ID = 100;
    private static final int ALBUM_SONGS_LIST_LOADER_ID = 101;
    Result channelResult;
    Loader loader;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);
        
        new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
                new MethodChannel.MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, Result result) {
                        channelResult = result;
                        handleMethodCall(call, result);
                    }
                });
    }

    private void handleMethodCall(MethodCall call, Result result){
        if (call.method.equals(FETCH_ALBUMS_METHOD)){
            fetchAlbums();
        }else if (call.method.equals(FETCH_SONGS_FROM_ALBUM_METHOD)){
            HashMap<String, Integer> arguments= (HashMap<String, Integer>) call.arguments;
            Bundle b= new Bundle();
            b.putInt("albumId", arguments.get("albumId"));
            Log.e("FLUTTER",arguments.get("albumId") + "ALBUMID" );
            fetchSongsFromAlbum(b);
        }
    }

    private void fetchAlbums(){
        loader= null;
        getLoaderManager().initLoader(ALBUM_LIST_LOADER_ID, null, this);
    }

    private void fetchSongsFromAlbum(Bundle bundle){
        getLoaderManager().restartLoader(ALBUM_SONGS_LIST_LOADER_ID, bundle, this);
    }

    @Override
    public Loader<Cursor> onCreateLoader(int loaderId, Bundle bundle) {
        Loader<Cursor> loader = null;
        String[] projection;
        String selection;
        String[] selectionArgs;
        switch (loaderId){
            case ALBUM_LIST_LOADER_ID:
                projection = new String[] { Albums._ID, Albums.ALBUM, Albums.ARTIST,
                        Albums.ALBUM_ART, Albums.NUMBER_OF_SONGS };
                String sortOrder = Media.ALBUM + " ASC";
                loader = new CursorLoader(this, Albums.EXTERNAL_CONTENT_URI, projection,
                        null, null, sortOrder);
                break;

            case ALBUM_SONGS_LIST_LOADER_ID:
                projection = new String[] { Media.DATA,
                        Media._ID,
                        Media.TITLE,
                        Media.DISPLAY_NAME,
                        Media.ARTIST,
                        Media.DURATION,
                        Media.TRACK,
                        Media.MIME_TYPE};
                selection = Media.ALBUM_ID + "=?";
                System.out.print(bundle.getInt("albumId") + "");
                selectionArgs = new String[]{bundle.getInt("albumId") + ""};
                Log.e("FLUTTER",bundle.getInt("albumId") + "" );
                sortOrder = Media.TRACK + " ASC";
                loader = new CursorLoader(this, Media.EXTERNAL_CONTENT_URI, projection,
                        selection, selectionArgs, sortOrder);
                break;
        }
        return loader;
    }

    @Override
    public void onLoadFinished(Loader<Cursor> loader, Cursor cursor) {
        Gson gson = new Gson();
        switch(loader.getId()){
            case ALBUM_LIST_LOADER_ID:
                ArrayList<Album> albumList = new ArrayList<>();
                if (cursor.moveToFirst()) {
                    // Loop through the table
                    do {
                        Album album = new Album();
                        album.setId(cursor.getInt(0));
                        album.setAlbum(cursor.getString(1));
                        album.setArtist(cursor.getString(2));
                        album.setAlbumArt(cursor.getString(3));
                        album.setNumOfSongs(cursor.getInt(4));

                        // Add album to list
                        albumList.add(album);
                    } while (cursor.moveToNext());
                }
                channelResult.success(gson.toJson(albumList));
                break;

            case ALBUM_SONGS_LIST_LOADER_ID:
                ArrayList<AudioMedia> albumSongsList = new ArrayList<>();
                if (cursor.moveToFirst()) {
                    // Loop through the table
                    do {
                        AudioMedia media = new AudioMedia();
                        media.setId(cursor.getInt(0));
                        media.setTitle(cursor.getString(1));
                        media.setDisplayName(cursor.getString(2));
                        media.setArtist(cursor.getString(3));
                        media.setDuration(cursor.getInt(4));
                        media.setTrack(cursor.getInt(5));

                        // Add media to list
                        albumSongsList.add(media);
                    } while (cursor.moveToNext());
                }
                channelResult.success(gson.toJson(albumSongsList));
                break;

        }

    }

    @Override
    public void onLoaderReset(Loader<Cursor> loader) {
    }
}
