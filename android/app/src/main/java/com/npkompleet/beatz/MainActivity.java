package com.npkompleet.beatz;

import android.Manifest;
import android.app.AlertDialog;
import android.app.LoaderManager;
import android.content.CursorLoader;
import android.content.DialogInterface;
import android.content.Loader;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.os.Build;
import android.os.Bundle;
import android.provider.MediaStore.Audio.Media;
import android.provider.MediaStore.Audio.Albums;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.util.Log;

import com.google.gson.Gson;
import com.npkompleet.beatz.models.Album;
import com.npkompleet.beatz.models.AudioMedia;

import java.io.IOException;
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
    private static final String PLAY_SONG_METHOD = "play";
    private static final String POSITION_METHOD = "position";
    private static final int ALBUM_LIST_LOADER_ID = 100;
    private static final int ALBUM_SONGS_LIST_LOADER_ID = 101;
    private static final int REQUEST_EXTERNAL_STORAGE= 200;
    Result channelResult;
    Loader loader;
    MediaPlayer mPlayer;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE)
                    != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.READ_EXTERNAL_STORAGE},
                        REQUEST_EXTERNAL_STORAGE);
            }
        }
        setUpMethodChannel();
    }

    private void setUpMethodChannel(){
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
        switch (call.method){
            case FETCH_ALBUMS_METHOD:
                fetchAlbums();
                break;
            case FETCH_SONGS_FROM_ALBUM_METHOD:
                HashMap<String, Integer> arguments= (HashMap<String, Integer>) call.arguments;
                Bundle b= new Bundle();
                b.putInt("albumId", arguments.get("albumId"));
                Log.e("FLUTTER",arguments.get("albumId") + "ALBUMID" );
                fetchSongsFromAlbum(b);
                break;
            case PLAY_SONG_METHOD:
                HashMap<String, String> songArg= (HashMap<String, String>) call.arguments;
                playSong(songArg.get("songUrl"));
                break;
            case POSITION_METHOD:
                getPlayBackPosition();
                break;
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
                projection = new String[] {
                        Albums._ID,
                        Albums.ALBUM,
                        Albums.ARTIST,
                        Albums.ALBUM_ART,
                        Albums.NUMBER_OF_SONGS };
                String sortOrder = Media.ALBUM + " ASC";
                loader = new CursorLoader(this, Albums.EXTERNAL_CONTENT_URI, projection,
                        null, null, sortOrder);
                break;

            case ALBUM_SONGS_LIST_LOADER_ID:
                projection = new String[] {
                        Media._ID,
                        Media.TITLE,
                        Media.DISPLAY_NAME,
                        Media.ARTIST,
                        Media.DURATION,
                        Media.TRACK,
                        Media.DATA,
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
                    // Loop through the table and add album to list
                    do {
                        Album album = new Album();
                        album.setId(cursor.getInt(0));
                        album.setAlbum(cursor.getString(1));
                        album.setArtist(cursor.getString(2));
                        album.setAlbumArt(cursor.getString(3));
                        album.setNumOfSongs(cursor.getInt(4));
                        albumList.add(album);
                    } while (cursor.moveToNext());
                }
                channelResult.success(gson.toJson(albumList));
                break;

            case ALBUM_SONGS_LIST_LOADER_ID:
                ArrayList<AudioMedia> albumSongsList = new ArrayList<>();
                if (cursor.moveToFirst()) {
                    // Loop through the table and add media to list
                    do {
                        AudioMedia media = new AudioMedia();
                        media.setId(cursor.getInt(0));
                        media.setTitle(cursor.getString(1));
                        media.setDisplayName(cursor.getString(2));
                        media.setArtist(cursor.getString(3));
                        media.setDuration(cursor.getLong(4));
                        media.setTrack(cursor.getInt(5));
                        media.setUri(cursor.getString(6));
                        media.setType(cursor.getString(7));
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

    private void playSong(String uri){
        if (mPlayer == null) {
            mPlayer = new MediaPlayer();
            mPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
            try {
                mPlayer.setDataSource(uri);
            } catch (IOException e) {
                e.printStackTrace();
            }
            mPlayer.prepareAsync();
        }

        mPlayer.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
            @Override
            public void onPrepared(MediaPlayer mediaPlayer) {
                mediaPlayer.start();
                channelResult.success("success");
            }
        });
    }

    private void getPlayBackPosition(){
        if(mPlayer.isPlaying()){
        channelResult.success(mPlayer.getCurrentPosition());
        }else{
            channelResult.success(0);
        }
    }


    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        if (requestCode == REQUEST_EXTERNAL_STORAGE) {
            if (grantResults[0] != PackageManager.PERMISSION_GRANTED) {
                if (ActivityCompat.shouldShowRequestPermissionRationale(this, Manifest.permission.READ_EXTERNAL_STORAGE)) {
                    //Show an explanation to the user
                    AlertDialog.Builder builder = new AlertDialog.Builder(this);
                    builder.setMessage("This permission is important to reread audio files from external storage.")
                            .setTitle("Important permission required");

                    builder.setPositiveButton("OK", new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int id) {
                            ActivityCompat.requestPermissions(MainActivity.this, new String[]{Manifest.permission.READ_EXTERNAL_STORAGE}, REQUEST_EXTERNAL_STORAGE);
                        }
                    });
                    ActivityCompat.requestPermissions(MainActivity.this, new String[]{Manifest.permission.READ_EXTERNAL_STORAGE}, REQUEST_EXTERNAL_STORAGE);
                }
            }
        }
    }

    @Override
    protected void onStop() {
        // Release resources when done using app
        if (mPlayer != null) mPlayer.release();
        super.onStop();
    }
}
