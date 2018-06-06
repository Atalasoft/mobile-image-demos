package com.kofax.samples.mobilecapturedemo;

import android.Manifest;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;

import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;

import android.provider.MediaStore;
import android.support.design.widget.FloatingActionButton;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;
import android.widget.Toast;

import com.kofax.kmc.ken.engines.data.DocumentDetectionSettings;
import com.kofax.kmc.ken.engines.data.Image;
import com.kofax.kmc.kui.uicontrols.CameraInitializationEvent;
import com.kofax.kmc.kui.uicontrols.CameraInitializationFailedEvent;
import com.kofax.kmc.kui.uicontrols.CameraInitializationFailedListener;
import com.kofax.kmc.kui.uicontrols.CameraInitializationListener;
import com.kofax.kmc.kui.uicontrols.ImageCaptureView;
import com.kofax.kmc.kui.uicontrols.ImageCapturedEvent;
import com.kofax.kmc.kui.uicontrols.ImageCapturedListener;
import com.kofax.kmc.kui.uicontrols.captureanimations.DocumentCaptureExperience;
import com.kofax.kmc.kui.uicontrols.captureanimations.DocumentCaptureExperienceCriteriaHolder;
import com.kofax.kmc.kui.uicontrols.data.Flash;
import com.kofax.kmc.kut.utilities.AppContextProvider;
import com.kofax.kmc.kut.utilities.Licensing;

import com.kofax.samples.common.PermissionsManager;
import com.kofax.samples.common.License;

public class CaptureActivity extends AppCompatActivity
        implements ActivityCompat.OnRequestPermissionsResultCallback, CameraInitializationListener, ImageCapturedListener, CameraInitializationFailedListener {

    private static final String TAG = CaptureActivity.class.getSimpleName();
    private static final String[] PERMISSIONS = {
            Manifest.permission.CAMERA
    };

    private final PermissionsManager mPermissionsManager = new PermissionsManager(this);

    private boolean mTorchFlag = false;
    private FloatingActionButton mFabTorch;

    private ImageCaptureView mImageCaptureView;
    private FloatingActionButton mForceCapture;
    private DocumentCaptureExperience mDocumentCaptureExperience;

    public ProgressDialog mProgressDialog;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        AppContextProvider.setContext(getApplicationContext());
        Licensing.setMobileSDKLicense(License.PROCESS_PAGE_SDK_LICENSE);

        if (!mPermissionsManager.isGranted(PERMISSIONS)) {
            mPermissionsManager.request(PERMISSIONS);
        }

        setUp();
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] results) {
        if (mPermissionsManager.isGranted(PERMISSIONS)) {
            setUp();
        } else {
            new AlertDialog.Builder(this)
                    .setMessage(R.string.permissions_rationale)
                    .setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            finish();
                        }
                    })
                    .setCancelable(false)
                    .show();
        }
    }

    private void setUp() {
        setContentView(R.layout.activity_capture);

        mImageCaptureView = (ImageCaptureView) findViewById(R.id.view_capture);

        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

        mImageCaptureView.addCameraInitializationListener(this);

        SettingsHelperClass.DeviceDeclinationResult declinationPitchRes = SettingsHelperClass.getDeviceDeclinationPitch(this);
        if (declinationPitchRes.result) mImageCaptureView.setDeviceDeclinationPitch(declinationPitchRes.value);

        SettingsHelperClass.DeviceDeclinationResult declinationRollRes = SettingsHelperClass.getDeviceDeclinationRoll(this);
        if (declinationRollRes.result) mImageCaptureView.setDeviceDeclinationRoll(declinationRollRes.value);

        mDocumentCaptureExperience = new DocumentCaptureExperience(mImageCaptureView);
        DocumentCaptureExperienceCriteriaHolder criteriaHolder = new DocumentCaptureExperienceCriteriaHolder();

        DocumentDetectionSettings settings = new DocumentDetectionSettings();
        settings.setTargetFramePaddingPercent(8.0);
        criteriaHolder.setDetectionSettings(settings);
        mDocumentCaptureExperience.setCaptureCriteria(criteriaHolder);

        mDocumentCaptureExperience.addOnImageCapturedListener(this);

        mDocumentCaptureExperience.takePicture();

        mForceCapture = (FloatingActionButton) findViewById(R.id.fab_force_capture);
        mForceCapture.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mImageCaptureView.forceTakePicture();
            }
        });

        if (Constants.IS_TORCH_SUPPORTED) {
            mFabTorch = (FloatingActionButton) findViewById(R.id.fab_torch);

            mFabTorch.setVisibility(View.VISIBLE);

            mFabTorch.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    mFabTorch.setImageDrawable(ContextCompat.getDrawable(getApplicationContext(), (mTorchFlag) ? R.drawable.torchoff : R.drawable.torchon));
                    mImageCaptureView.setFlash((mTorchFlag) ? Flash.OFF : Flash.TORCH);
                    mTorchFlag = !mTorchFlag;
                }
            });
        }

        FloatingActionButton fabGallery = (FloatingActionButton) findViewById(R.id.fab_gallery);

        if (SettingsHelperClass.isGalleryEnabled(this)) {
            fabGallery.setVisibility(View.VISIBLE);
            fabGallery.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {

                    String[] GALLERY_PERMISSIONS_REQUIRED = {Manifest.permission.READ_EXTERNAL_STORAGE, Manifest.permission.CAMERA};

                    if (mPermissionsManager.isGranted(GALLERY_PERMISSIONS_REQUIRED)) {
                        Intent photoPickerIntent = new Intent(Intent.ACTION_PICK);
                        photoPickerIntent.setType("image/*");
                        startActivityForResult(photoPickerIntent, Constants.GALLERY_IMPORT_REQUEST_ID);
                    } else {
                        mPermissionsManager.request(GALLERY_PERMISSIONS_REQUIRED);
                    }
                }
            });
        } else {
            fabGallery.setVisibility(View.GONE);
        }
    }

    @Override
    protected void onResume() {
        super.onResume();

        mForceCapture.setVisibility(View.GONE);

        int manualCaptureTimeVal = SettingsHelperClass.getManualCaptureTime(this);
        if (manualCaptureTimeVal == -1) manualCaptureTimeVal = Constants.DEFAULT_MANUAL_CAPTURE_TIME;

        final Handler handler = new Handler();
        handler.postDelayed(new Runnable() {
            @Override
            public void run() {
                mForceCapture.setVisibility(View.VISIBLE);
            }
        }, manualCaptureTimeVal*1000);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        if (mDocumentCaptureExperience != null) {
            mDocumentCaptureExperience.removeOnImageCapturedListener(this);
            mDocumentCaptureExperience.destroy();
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        switch (requestCode) {
            case Constants.GALLERY_IMPORT_REQUEST_ID:
                if (resultCode == RESULT_OK && data != null) {
                    Constants.RESULT_IMAGE = decodeImageFromIntent(data);

                    if (Constants.RESULT_IMAGE == null)
                    {
                        new AlertDialog.Builder(this)
                                .setTitle("Error")
                                .setMessage( "Gallery image is not selected" )
                                .setPositiveButton(android.R.string.ok, null)
                                .setCancelable(true)
                                .setIcon(R.drawable.error)
                                .show();
                    }
                    else {
                        Intent intent = new Intent(getApplicationContext(), com.kofax.samples.mobilecapturedemo.PreviewActivity.class);
                        startActivityForResult(intent, Constants.PROCESSED_IMAGE_REQUEST_ID);
                    }
                }
                break;

            case Constants.PROCESSED_IMAGE_REQUEST_ID:
                if (resultCode == RESULT_OK || resultCode == Constants.PROCESSED_IMAGE_ACCEPT_RESPONSE_ID) {
                    finish();

                    Intent intent = new Intent(getApplicationContext(), com.kofax.samples.mobilecapturedemo.ProcessImageActivity.class);
                    startActivity(intent);
                }
                break;
        }
    }

    private Image decodeImageFromIntent(Intent data) {
        Uri selectedImage = data.getData();
        String[] filePathColumn = {MediaStore.Images.Media.DATA};

        if (selectedImage == null) return null;

        Cursor cursor = getContentResolver().query(selectedImage, filePathColumn, null, null, null);

        if (cursor == null) return null;

        cursor.moveToFirst();
        int columnIndex = cursor.getColumnIndex(filePathColumn[0]);
        String filePath = cursor.getString(columnIndex);
        cursor.close();
        Bitmap bitmap = BitmapFactory.decodeFile(filePath);
        if(bitmap == null) {
            return null;
        }
        return new Image(bitmap);
    }


    @Override
    public void onCameraInitialized(CameraInitializationEvent arg0) {
        mImageCaptureView.setUseVideoFrame(true);
        mImageCaptureView.setFlash(Flash.OFF);

        if (mProgressDialog.isShowing()) mProgressDialog.dismiss();
    }

    @Override
    public void onImageCaptured(final ImageCapturedEvent imageCapturedEvent) {
        if (imageCapturedEvent != null) {
            if (imageCapturedEvent.getImage() != null) {
                Constants.RESULT_IMAGE = imageCapturedEvent.getImage();

                Intent intent = new Intent(getApplicationContext(), com.kofax.samples.mobilecapturedemo.PreviewActivity.class);
                startActivityForResult(intent, Constants.PROCESSED_IMAGE_REQUEST_ID);
            } else {
                onBackPressed();
            }
        }
    }

    @Override
    public void onCameraInitializationFailed(CameraInitializationFailedEvent event) {
        String message = event.getCause().getMessage();
        if (message == null || message.equals("")) {
            message = getResources().getString(R.string.camera_unavailable);
        }
        Toast.makeText(CaptureActivity.this, message, Toast.LENGTH_LONG).show();
        onBackPressed();
    }
}
