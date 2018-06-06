package com.kofax.samples.mobilecapturedemo;

import android.app.ProgressDialog;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.design.widget.FloatingActionButton;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.view.View;

import com.kofax.kmc.ken.engines.ImageProcessor;
import com.kofax.kmc.ken.engines.data.Image;
import com.kofax.kmc.ken.engines.processing.ImageProcessorConfiguration;
import com.kofax.kmc.kui.uicontrols.ImgReviewEditCntrl;
import com.kofax.kmc.kut.utilities.error.ErrorInfo;
import com.kofax.kmc.kut.utilities.error.KmcException;

import java.util.Date;

public class PreviewActivity extends AppCompatActivity implements ImageProcessor.ImageOutListener {

    private ImgReviewEditCntrl mImgReviewEditCntrl;

    private FloatingActionButton mfabRetake;
    private FloatingActionButton mfabGoToProcessing;
    private ProgressDialog mProgressDialog;
    private boolean isProgressDialog;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_preview);

        processImage(Constants.RESULT_IMAGE);

        mImgReviewEditCntrl = (ImgReviewEditCntrl) findViewById(R.id.view_review1);

        mfabRetake = (FloatingActionButton) findViewById(R.id.fab_retake);
        mfabRetake.setVisibility(View.GONE);
        mfabRetake.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                setResult(Constants.PROCESSED_IMAGE_RETAKE_RESPONSE_ID);
                PreviewActivity.super.onBackPressed();
                finish();
            }
        });

        mfabGoToProcessing = (FloatingActionButton) findViewById(R.id.fab_go_to_processing);
        mfabGoToProcessing.setVisibility(View.GONE);
        mfabGoToProcessing.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
            Constants.RESULT_IMAGE = mImgReviewEditCntrl.getImage();

            setResult(Constants.PROCESSED_IMAGE_ACCEPT_RESPONSE_ID);
            finish();
            }
        });

        if (mProgressDialog == null) {
            isProgressDialog = true;
            mProgressDialog = new ProgressDialog(this);
            mProgressDialog.setTitle("Please wait");
            mProgressDialog.setMessage("Image is processing...");
            mProgressDialog.setCanceledOnTouchOutside(false);
            mProgressDialog.setCancelable(false);
            mProgressDialog.show();
        } else {
            if (isProgressDialog && !mProgressDialog.isShowing()) mProgressDialog.show();
        }
    }

    protected void onResume() {
        super.onResume();
        if (mProgressDialog != null && isProgressDialog && !mProgressDialog.isShowing()) mProgressDialog.show();
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
    }

    @Override
    public void onBackPressed() {
        setResult(Constants.PROCESSED_IMAGE_RETAKE_RESPONSE_ID);
        super.onBackPressed();
        finish();
    }

    private void processImage(Image srcImage) {
        ImageProcessor imageProcessor = new ImageProcessor();
        imageProcessor.addImageOutEventListener(this);
        ImageProcessorConfiguration imageProcessingConfiguration = SettingsHelperClass.getImageProcessorConfiguration(this);

        try {
            imageProcessor.processImage(srcImage, imageProcessingConfiguration);
        } catch (KmcException e) {
            new AlertDialog.Builder(this)
                    .setTitle("Error")
                    .setMessage( "Image processing failed" )
                    .setPositiveButton(android.R.string.ok, null)
                    .setCancelable(true)
                    .setIcon(R.drawable.error)
                    .show();
        }
    }

    @Override
    public void imageOut(ImageProcessor.ImageOutEvent event) {
        if (event.getStatus() == ErrorInfo.KMC_SUCCESS) {
            try {
                mImgReviewEditCntrl.setImage( event.getImage() );

                mfabRetake.setVisibility(View.VISIBLE);
                mfabGoToProcessing.setVisibility(View.VISIBLE);

                if (mProgressDialog != null && mProgressDialog.isShowing()) {
                    mProgressDialog.dismiss();
                    isProgressDialog = false;
                }

                SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(this);
                if (!prefs.contains("pref_key_shots_count") || !prefs.contains("pref_key_last_usage_date")) {
                    SettingsHelperClass.initRestrictionPropertiesFields(prefs);
                } else {
                    SharedPreferences.Editor editor = prefs.edit();
                    editor.putInt("pref_key_shots_count", (prefs.getInt("pref_key_shots_count", -1) + 1));
                    editor.putLong("pref_key_last_usage_date", new Date().getTime());
                    editor.apply();
                }

            } catch (KmcException e) {
                new AlertDialog.Builder(this)
                        .setTitle("Error")
                        .setMessage( "Image processing failed" )
                        .setPositiveButton(android.R.string.ok, null)
                        .setCancelable(true)
                        .setIcon(R.drawable.error)
                        .show();
            }
        }
    }
}
