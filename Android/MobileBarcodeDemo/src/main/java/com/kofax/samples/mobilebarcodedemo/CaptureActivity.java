package com.kofax.samples.mobilebarcodedemo;

import android.Manifest;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.design.widget.FloatingActionButton;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
import android.view.WindowManager;
import android.widget.Toast;

import com.kofax.kmc.kui.uicontrols.BarCodeCaptureView;
import com.kofax.kmc.kui.uicontrols.BarCodeFoundEvent;
import com.kofax.kmc.kui.uicontrols.BarCodeFoundListener;
import com.kofax.kmc.kui.uicontrols.CameraInitializationEvent;
import com.kofax.kmc.kui.uicontrols.CameraInitializationFailedEvent;
import com.kofax.kmc.kui.uicontrols.CameraInitializationFailedListener;
import com.kofax.kmc.kui.uicontrols.CameraInitializationListener;
import com.kofax.kmc.kui.uicontrols.data.Flash;
import com.kofax.kmc.kui.uicontrols.data.GuidingLine;
import com.kofax.kmc.kui.uicontrols.data.Symbology;
import com.kofax.kmc.kut.utilities.AppContextProvider;
import com.kofax.kmc.kut.utilities.Licensing;
import com.kofax.samples.common.PermissionsManager;

import java.util.ArrayList;
import java.util.Date;

import com.kofax.samples.common.License;

public class CaptureActivity extends AppCompatActivity
        implements ActivityCompat.OnRequestPermissionsResultCallback, CameraInitializationListener, BarCodeFoundListener, /*ImageCapturedListener,*/ CameraInitializationFailedListener {

    private static final String[] PERMISSIONS = {
            Manifest.permission.CAMERA
    };

    private final PermissionsManager mPermissionsManager = new PermissionsManager(this);

    private boolean mTorchFlag = false;
    private FloatingActionButton mFabTorch;

    private BarCodeCaptureView mBarcodeCaptureView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        AppContextProvider.setContext(getApplicationContext());
        Licensing.setMobileSDKLicense(License.PROCESS_PAGE_SDK_LICENSE);

        if (mPermissionsManager.isGranted(PERMISSIONS)) {
            setUp();
        } else {
            mPermissionsManager.request(PERMISSIONS);
            setUp();
        }
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
        Constants.BARCODE_EVENT = null;

        setContentView(R.layout.activity_capture);

        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

        mBarcodeCaptureView = (BarCodeCaptureView) findViewById(R.id.barcode_capture);
        mBarcodeCaptureView.addCameraInitializationListener(this);
        mBarcodeCaptureView.addBarCodeFoundEventListener(this);
        mBarcodeCaptureView.setGuidingLine(GuidingLine.LANDSCAPE);

        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(this);

        ArrayList<Symbology> symbsList = new ArrayList<>();
        if (!prefs.contains("pref_key_code_39") || (prefs.contains("pref_key_code_39") && prefs.getBoolean("pref_key_code_39", false))) {
            symbsList.add(Symbology.CODE39);
        }
        if (!prefs.contains("pref_key_pdf_417") || (prefs.contains("pref_key_pdf_417") && prefs.getBoolean("pref_key_pdf_417", false))) {
            symbsList.add(Symbology.PDF417);
        }
        if (!prefs.contains("pref_key_qr") || (prefs.contains("pref_key_qr") && prefs.getBoolean("pref_key_qr", false))) {
            symbsList.add(Symbology.QR);
        }
        if (!prefs.contains("pref_key_datamatrix") || (prefs.contains("pref_key_datamatrix") && prefs.getBoolean("pref_key_datamatrix", false))) {
            symbsList.add(Symbology.DATAMATRIX);
        }
        if (!prefs.contains("pref_key_code_128") || (prefs.contains("pref_key_code_128") && prefs.getBoolean("pref_key_code_128", false))) {
            symbsList.add(Symbology.CODE128);
        }
        if (!prefs.contains("pref_key_code_25") || (prefs.contains("pref_key_code_25") && prefs.getBoolean("pref_key_code_25", false))) {
            symbsList.add(Symbology.CODE25);
        }
        if (!prefs.contains("pref_key_ean") || (prefs.contains("pref_key_ean") && prefs.getBoolean("pref_key_ean", false))) {
            symbsList.add(Symbology.EAN);
        }
        if (!prefs.contains("pref_key_upc") || (prefs.contains("pref_key_upc") && prefs.getBoolean("pref_key_upc", false))) {
            symbsList.add(Symbology.UPC);
        }
        if (!prefs.contains("pref_key_codabar") || (prefs.contains("pref_key_codabar") && prefs.getBoolean("pref_key_codabar", false))) {
            symbsList.add(Symbology.CODABAR);
        }
        if (!prefs.contains("pref_key_aztec") || (prefs.contains("pref_key_aztec") && prefs.getBoolean("pref_key_aztec", false))) {
            symbsList.add(Symbology.AZTEC);
        }
        if (!prefs.contains("pref_key_code_93") || (prefs.contains("pref_key_code_93") && prefs.getBoolean("pref_key_code_93", false))) {
            symbsList.add(Symbology.CODE93);
        }

        Symbology[] symbs = new Symbology[symbsList.size()];
        symbs = symbsList.toArray(symbs);

        mBarcodeCaptureView.setSymbologies(symbs);
        mBarcodeCaptureView.readBarcode();

        if (Constants.IS_TORCH_SUPPORTED) {
            mFabTorch = (FloatingActionButton) findViewById(R.id.fab_torch);

            mFabTorch.setVisibility(View.VISIBLE);

            mFabTorch.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    mFabTorch.setImageDrawable(ContextCompat.getDrawable(getApplicationContext(), (mTorchFlag) ? R.drawable.torchoff : R.drawable.torchon));
                    mBarcodeCaptureView.setFlash((mTorchFlag) ? Flash.OFF : Flash.TORCH);
                    mTorchFlag = !mTorchFlag;
                }
            });
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        Constants.BARCODE_EVENT = null;
        mBarcodeCaptureView.readBarcode();
    }

    @Override
    public void onCameraInitialized(CameraInitializationEvent arg0) {
        mBarcodeCaptureView.setUseVideoFrame(true);
        mBarcodeCaptureView.setFlash(Flash.OFF);
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

    @Override
    public void barCodeFound(BarCodeFoundEvent event) {
        if (Constants.BARCODE_EVENT != null)
            return;

        Constants.BARCODE_EVENT = event;

        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(this);
        if (!prefs.contains("pref_key_shots_count") || !prefs.contains("pref_key_last_usage_date")) {
            SharedPreferences.Editor editor = prefs.edit();
            editor.putInt("pref_key_shots_count", 0);
            editor.putLong("pref_key_last_usage_date", new Date().getTime());
            editor.apply();
        } else {
            SharedPreferences.Editor editor = prefs.edit();
            editor.putInt("pref_key_shots_count", (prefs.getInt("pref_key_shots_count", -1) + 1));
            editor.putLong("pref_key_last_usage_date", new Date().getTime());
            editor.apply();
        }

        Intent intent = new Intent(getApplicationContext(), com.kofax.samples.mobilebarcodedemo.BarcodeInfoActivity.class);
        startActivityForResult(intent, Constants.BARCODE_FOUND_REQUEST_ID);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        switch (requestCode) {
            case Constants.BARCODE_FOUND_REQUEST_ID:
                if (resultCode == RESULT_OK || resultCode == Constants.PROCESSED_IMAGE_EMAIL_IS_SENT_RESPONSE_ID) {
                    finish();
                }
                if (resultCode == RESULT_OK || resultCode == Constants.PROCESSED_IMAGE_RETAKE_RESPONSE_ID) {
                    Constants.BARCODE_EVENT = null;
                }
                break;
        }
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        finish();
    }
}
