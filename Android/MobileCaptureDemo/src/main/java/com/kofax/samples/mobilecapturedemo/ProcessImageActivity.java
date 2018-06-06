package com.kofax.samples.mobilecapturedemo;

import android.Manifest;
import android.app.AlertDialog;
import android.content.ContentUris;
import android.content.ContentValues;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.os.PersistableBundle;
import android.os.SystemClock;
import android.provider.MediaStore;
import android.support.annotation.NonNull;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.FileProvider;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;

import com.kofax.kmc.kui.uicontrols.ImgReviewEditCntrl;
import com.kofax.kmc.kut.utilities.error.KmcException;

import java.io.File;
import java.io.FileOutputStream;
import java.text.SimpleDateFormat;
import java.util.Date;

import static android.provider.MediaStore.Images.*;

public class ProcessImageActivity extends AppCompatActivity
        implements ActivityCompat.OnRequestPermissionsResultCallback {

    final int REQUEST_EXTERNAL_STORAGE_FOR_GALLERY  = 1;
    final int REQUEST_EXTERNAL_STORAGE_FOR_EXTERNAL = 2;
    final String[] PERMISSIONS_STORAGE = {
            Manifest.permission.READ_EXTERNAL_STORAGE,
            Manifest.permission.WRITE_EXTERNAL_STORAGE
    };

    private ImgReviewEditCntrl mImgReviewEditCntrl;

    private String mSavedImageGalleryPath;
    private String mSavedImageExternalPath;

    private long mLastClickTime = 0;

    private boolean checkWritePermissions(final boolean isForGallery) {
        int permission = ActivityCompat.checkSelfPermission(ProcessImageActivity.this, Manifest.permission.WRITE_EXTERNAL_STORAGE);

        if (permission != PackageManager.PERMISSION_GRANTED) {
            new AlertDialog.Builder(ProcessImageActivity.this)
                    .setMessage(R.string.save_permissions_msg)
                    .setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            ActivityCompat.requestPermissions(
                                    ProcessImageActivity.this,
                                    PERMISSIONS_STORAGE,
                                    isForGallery ? REQUEST_EXTERNAL_STORAGE_FOR_GALLERY : REQUEST_EXTERNAL_STORAGE_FOR_EXTERNAL
                            );
                        }
                    })
                    .setCancelable(false)
                    .show();
        }
        return (permission == PackageManager.PERMISSION_GRANTED);
    }

    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions,
                                           @NonNull int[] grantResults) {
        if (grantResults.length == 2 && grantResults[0] == PackageManager.PERMISSION_GRANTED && grantResults[1] == PackageManager.PERMISSION_GRANTED) {
            if (requestCode == REQUEST_EXTERNAL_STORAGE_FOR_GALLERY) {
                saveToGallery(findViewById(R.id.view_processed_image));
            } else {
                saveToExternal(findViewById(R.id.view_processed_image));
                sendEmail();
            }
        } else {
            new AlertDialog.Builder(this)
                    .setTitle("Error")
                    .setMessage( "Permissions are not given" )
                    .setPositiveButton(android.R.string.ok, null)
                    .setCancelable(false)
                    .setIcon(R.drawable.error)
                    .show();
        }
    }

    private void showGalleryImagePath(View view) {
        new AlertDialog.Builder(this)
                .setTitle("Gallery save")
                .setMessage("Image is saved to the gallery: " + mSavedImageGalleryPath)
                .setPositiveButton(android.R.string.ok, null)
                .setCancelable(false)
                .setIcon(R.drawable.ic_info_black_24dp)
                .show();
    }

    private void saveToGallery(View view) {
        if (mSavedImageGalleryPath == null) {
            mSavedImageGalleryPath = Media.insertImage(getContentResolver(), mImgReviewEditCntrl.getImage().getImageBitmap(),
                    String.format("%s image", getResources().getString(R.string.app_name)),
                    String.format("Image created by %s application", getResources().getString(R.string.app_name)));

            if (mSavedImageGalleryPath != null) {
                Uri photoUri = Uri.parse(mSavedImageGalleryPath);
                ContentValues values = new ContentValues();
                values.put(MediaStore.Images.Media.DATE_ADDED, System.currentTimeMillis() / 1000);
                values.put(MediaStore.Images.Media.DATE_TAKEN, System.currentTimeMillis());
                this.getContentResolver().update(
                        MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                        values,
                        MediaStore.Images.Media._ID + "=?",
                        new String[]{ContentUris.parseId(photoUri) + ""});

                Intent scanFileIntent = new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, photoUri);
                view.getContext().sendBroadcast(scanFileIntent);
            } else {
                new android.support.v7.app.AlertDialog.Builder(this)
                        .setTitle("Error")
                        .setMessage( "Image cannot be saved to gallery" )
                        .setPositiveButton(android.R.string.ok, null)
                        .setCancelable(true)
                        .setIcon(R.drawable.error)
                        .show();
            }
        }

        if (mSavedImageGalleryPath != null) {
            showGalleryImagePath(view);
        }
    }

    private void saveToExternal(View view) {
        if (mSavedImageExternalPath == null) {
            File storageDir = new File(
                    Environment.getExternalStoragePublicDirectory(
                            Environment.DIRECTORY_PICTURES
                    ),
                    Constants.PHOTO_ALBUM_NAME
            );

            storageDir.mkdirs();

            SimpleDateFormat dateFormat = new SimpleDateFormat("ddMMyyyy_HHmmss");
            String dateStr = dateFormat.format(new Date());

            String saveImageName = "Image-" + dateStr + ".jpg";
            File file = new File(storageDir, saveImageName);

            if (file.exists()) file.delete();

            try {
                FileOutputStream out = new FileOutputStream(file);
                Bitmap bitmap = mImgReviewEditCntrl.getImage().getImageBitmap();
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, out);
                out.flush();
                out.close();

                mSavedImageExternalPath = FileProvider.getUriForFile(this, BuildConfig.APPLICATION_ID + ".provider", file).toString();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    private void sendEmail() {

        if (mSavedImageExternalPath != null) {
            try {
                Intent emailIntent = new Intent(Intent.ACTION_SEND);

                emailIntent.setFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
                emailIntent.setData(Uri.parse("mailto:"));
                emailIntent.setType("image/jpeg");
                emailIntent.putExtra(Intent.EXTRA_SUBJECT, "Processed image");
                emailIntent.putExtra(Intent.EXTRA_TEXT, String.format("Here is the result of Atalasoft %s", getResources().getString(R.string.app_name)));
                emailIntent.putExtra(Intent.EXTRA_STREAM, Uri.parse(mSavedImageExternalPath));

                startActivityForResult(Intent.createChooser(emailIntent, "Send mail..."), Constants.SEND_EMAIL_REQUEST_ID);
            } catch (android.content.ActivityNotFoundException ex) {
                Snackbar.make(this.findViewById(R.id.view_processed_image), "Error in email sending", Snackbar.LENGTH_LONG)
                        .setAction("Action", null).show();
            }
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_process_image);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar_process_image);
        setSupportActionBar(toolbar);

        mImgReviewEditCntrl = (ImgReviewEditCntrl) findViewById(R.id.view_processed_image);
        try {
            mImgReviewEditCntrl.setImage(Constants.RESULT_IMAGE);
        } catch (KmcException e) {
            new android.support.v7.app.AlertDialog.Builder(this)
                    .setTitle("Error")
                    .setMessage( "Image cannot be shown" )
                    .setPositiveButton(android.R.string.ok, null)
                    .setCancelable(true)
                    .setIcon(R.drawable.error)
                    .show();
        }

        FloatingActionButton fabSaveToGallery = (FloatingActionButton) findViewById(R.id.fab_save_to_gallery);
        fabSaveToGallery.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (mSavedImageGalleryPath != null) {
                    showGalleryImagePath(view);
                }  else if (checkWritePermissions(true)) {
                    saveToGallery(view);
                }
            }
        });

        FloatingActionButton fabSend = (FloatingActionButton) findViewById(R.id.fab_send);
        fabSend.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                // mis-clicking prevention, using threshold of 1000 ms
                if (SystemClock.elapsedRealtime() - mLastClickTime < 1000){
                    return;
                }
                mLastClickTime = SystemClock.elapsedRealtime();

                if (mSavedImageExternalPath != null) {
                    sendEmail();
                } else if (checkWritePermissions(false)) {
                    saveToExternal(view);
                    sendEmail();
                }
            }
        });
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        switch (requestCode) {
            case Constants.SEND_EMAIL_REQUEST_ID:
                if (resultCode == RESULT_OK) {
                    new AlertDialog.Builder(this)
                            .setTitle("Info")
                            .setMessage( "Email is sent" )
                            .setPositiveButton(android.R.string.ok, null)
                            .setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {
                                @Override
                                public void onClick(DialogInterface dialog, int which) {
                                    finish();
                                }
                            })
                            .setCancelable(true)
                            .setIcon(R.drawable.ic_info_black_24dp)
                            .show();
                } else {
                    new AlertDialog.Builder(this)
                            .setTitle("Error")
                            .setMessage( "Email is not sent" )
                            .setPositiveButton(android.R.string.ok, null)
                            .setCancelable(false)
                            .setIcon(R.drawable.error)
                            .show();
                }
                break;
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.toolbar_process_image, menu);
        return true;
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        finish();
        Intent intent = new Intent(this, CaptureActivity.class);
        startActivity(intent);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();
        if (id == R.id.menu_home) {
            finish();
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        if (mSavedImageGalleryPath != null) outState.putString(Constants.IMAGE_GALLERY_PATH_NAME, mSavedImageGalleryPath);
        if (mSavedImageExternalPath != null) outState.putString(Constants.IMAGE_EXTERNAL_PATH_NAME, mSavedImageExternalPath);
    }

    @Override
    public void onSaveInstanceState(Bundle outState, PersistableBundle outPersistentState) {
        super.onSaveInstanceState(outState, outPersistentState);
        if (mSavedImageGalleryPath != null) outState.putString(Constants.IMAGE_GALLERY_PATH_NAME, mSavedImageGalleryPath);
        if (mSavedImageExternalPath != null) outState.putString(Constants.IMAGE_EXTERNAL_PATH_NAME, mSavedImageExternalPath);
    }

    @Override
    public void onRestoreInstanceState(Bundle savedInstanceState) {
        super.onRestoreInstanceState(savedInstanceState);
        if (savedInstanceState.containsKey(Constants.IMAGE_GALLERY_PATH_NAME)) mSavedImageGalleryPath = savedInstanceState.getString(Constants.IMAGE_GALLERY_PATH_NAME);
        if (savedInstanceState.containsKey(Constants.IMAGE_EXTERNAL_PATH_NAME)) mSavedImageExternalPath = savedInstanceState.getString(Constants.IMAGE_EXTERNAL_PATH_NAME);
    }

    @Override
    public void onRestoreInstanceState(Bundle savedInstanceState, PersistableBundle outPersistentState) {
        super.onRestoreInstanceState(savedInstanceState, outPersistentState);
        if (savedInstanceState.containsKey(Constants.IMAGE_GALLERY_PATH_NAME)) mSavedImageGalleryPath = savedInstanceState.getString(Constants.IMAGE_GALLERY_PATH_NAME);
        if (savedInstanceState.containsKey(Constants.IMAGE_EXTERNAL_PATH_NAME)) mSavedImageExternalPath = savedInstanceState.getString(Constants.IMAGE_EXTERNAL_PATH_NAME);
    }
}
