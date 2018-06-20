package com.kofax.samples.mobilebarcodedemo;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.res.Configuration;
import android.net.Uri;
import android.os.Bundle;
import android.os.SystemClock;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.text.Html;
import android.text.method.ScrollingMovementMethod;
import android.util.Base64;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.kofax.kmc.ken.engines.data.BarCodeDataFormat;
import com.kofax.kmc.kui.uicontrols.ImgReviewEditCntrl;
import com.kofax.kmc.kut.utilities.error.KmcException;

import java.nio.charset.StandardCharsets;

public class BarcodeInfoActivity extends AppCompatActivity {
    private LinearLayout mLayoutPortrait;
    private LinearLayout mLayoutLandscape;

    private String mBarcodeInfoStrHtml;
    private String mBarcodeValue;

    private long mLastClickTime = 0;

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);

        mLayoutPortrait.setVisibility(newConfig.orientation == Configuration.ORIENTATION_PORTRAIT ? View.VISIBLE : View.GONE);
        mLayoutLandscape.setVisibility(newConfig.orientation == Configuration.ORIENTATION_LANDSCAPE ? View.VISIBLE : View.GONE);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_barcode_info);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar_barcode_info);
        setSupportActionBar(toolbar);

        TextView barcodeInfoValueViewPortrait = (TextView) findViewById(R.id.barcode_info_portrait);
        barcodeInfoValueViewPortrait.setVerticalScrollBarEnabled(true);
        barcodeInfoValueViewPortrait.setMovementMethod(new ScrollingMovementMethod());

        TextView barcodeInfoValueViewLandscape = (TextView) findViewById(R.id.barcode_info_landscape);
        barcodeInfoValueViewLandscape.setVerticalScrollBarEnabled(true);
        barcodeInfoValueViewLandscape.setMovementMethod(new ScrollingMovementMethod());

        ImgReviewEditCntrl imgReviewEditCntrlLandscape = (ImgReviewEditCntrl) findViewById(R.id.view_review_landscape);
        ImgReviewEditCntrl imgReviewEditCntrlPortrait = (ImgReviewEditCntrl) findViewById(R.id.view_review_portrait);

        try {
            imgReviewEditCntrlPortrait.setImage( Constants.BARCODE_EVENT.getImage() );
        } catch (KmcException e) {
            new AlertDialog.Builder(this)
                    .setTitle("Error")
                    .setMessage( "Unable to show the captured image" )
                    .setPositiveButton(android.R.string.ok, null)
                    .setCancelable(true)
                    .setIcon(R.drawable.error)
                    .show();
            finish();
        }

        try {
            imgReviewEditCntrlLandscape.setImage( Constants.BARCODE_EVENT.getImage() );
        } catch (KmcException e) {
            new AlertDialog.Builder(this)
                    .setTitle("Error")
                    .setMessage( "Unable to show the captured image" )
                    .setPositiveButton(android.R.string.ok, null)
                    .setCancelable(true)
                    .setIcon(R.drawable.error)
                    .show();
            finish();
        }

        mBarcodeValue = Constants.BARCODE_EVENT.getBarCode().getValue();
        if (Constants.BARCODE_EVENT.getBarCode().getDataFormat() == BarCodeDataFormat.BASE_64){
            try {
                byte[] data = Base64.decode(mBarcodeValue, Base64.DEFAULT);
                mBarcodeValue = new String(data, StandardCharsets.UTF_8);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        mBarcodeInfoStrHtml = String.format("<h3><strong>Type</strong>:</h3> %s<hr /><h3><strong>Value</strong>:</h3>",
                Constants.BARCODE_EVENT.getBarCode().getType().toString());

        barcodeInfoValueViewPortrait.setText(Html.fromHtml(mBarcodeInfoStrHtml) + mBarcodeValue);
        barcodeInfoValueViewLandscape.setText(Html.fromHtml(mBarcodeInfoStrHtml) + mBarcodeValue);

        mLayoutPortrait = (LinearLayout) findViewById(R.id.barcode_info_portrait_layout);
        mLayoutPortrait.setVisibility(getResources().getConfiguration().orientation == Configuration.ORIENTATION_PORTRAIT ? View.VISIBLE : View.GONE);

        mLayoutLandscape = (LinearLayout) findViewById(R.id.barcode_info_landscape_layout);
        mLayoutLandscape.setVisibility(getResources().getConfiguration().orientation == Configuration.ORIENTATION_LANDSCAPE ? View.VISIBLE : View.GONE);

        FloatingActionButton fabRetake = (FloatingActionButton) findViewById(R.id.fab_retake);
        fabRetake.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                setResult(Constants.PROCESSED_IMAGE_RETAKE_RESPONSE_ID);
                finish();
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

                Intent emailIntent = new Intent(Intent.ACTION_SEND);

                emailIntent.setData(Uri.parse("mailto:"));
                emailIntent.setType("text/plain");
                emailIntent.putExtra(Intent.EXTRA_SUBJECT, "Barcode info");
                emailIntent.putExtra(Intent.EXTRA_TEXT, "Here is the result of MobileImage SDK Barcode sample:\n " + Html.fromHtml(mBarcodeInfoStrHtml) + mBarcodeValue);

                try {
                    startActivityForResult(Intent.createChooser(emailIntent, "Send mail..."), Constants.SEND_EMAIL_REQUEST_ID);
                } catch (android.content.ActivityNotFoundException ex) {
                    Snackbar.make(view, "Error in email sending", Snackbar.LENGTH_LONG)
                            .setAction("Action", null).show();
                }
            }

        });
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        setResult(Constants.PROCESSED_IMAGE_RETAKE_RESPONSE_ID);
        finish();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        switch (requestCode) {
            case Constants.SEND_EMAIL_REQUEST_ID:
                if (resultCode == RESULT_OK) {
                    new AlertDialog.Builder(this)
                            .setTitle("Info")
                            .setMessage( "Email is sent" )
                            .setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {
                                @Override
                                public void onClick(DialogInterface dialog, int which) {
                                    setResult(Constants.PROCESSED_IMAGE_EMAIL_IS_SENT_RESPONSE_ID);
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
}
