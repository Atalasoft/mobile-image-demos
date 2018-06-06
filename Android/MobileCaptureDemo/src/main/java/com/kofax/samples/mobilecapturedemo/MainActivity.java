package com.kofax.samples.mobilecapturedemo;

import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.res.Configuration;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.design.widget.FloatingActionButton;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;

import java.text.SimpleDateFormat;
import java.util.Date;

public class MainActivity extends AppCompatActivity {
    private FloatingActionButton mfabCapture;
    private ProgressDialog mProgressDialog;

    private boolean mLimitExceeded = false;

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Toolbar toolbar = (Toolbar) findViewById(R.id.my_toolbar);
        setSupportActionBar(toolbar);
        checkTorchSupport();

        try {
            PackageInfo pInfo = this.getPackageManager().getPackageInfo(getPackageName(), 0);
            Constants.VERSION = pInfo.versionName;
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }

        mfabCapture = (FloatingActionButton) findViewById(R.id.fab_capture);

        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(this);
        if (!prefs.contains("pref_key_shots_count") || !prefs.contains("pref_key_last_usage_date")) {
            SettingsHelperClass.initRestrictionPropertiesFields(prefs);
            mfabCapture.setVisibility(View.VISIBLE);
        }
    }

    public void onCaptureClick(View view) {
        mProgressDialog = new ProgressDialog(this);
        mProgressDialog.setTitle("Please wait");
        mProgressDialog.setMessage("Initializing...");
        mProgressDialog.show();

        Intent intent = new Intent(this, CaptureActivity.class);
        startActivity(intent);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.toolbar, menu);
        menu.findItem(R.id.menu_item_settings).setEnabled(!mLimitExceeded);
        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public boolean onPrepareOptionsMenu(Menu menu) {
        menu.findItem(R.id.menu_item_settings).setEnabled(!mLimitExceeded);
        return super.onPrepareOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();

        if (id == R.id.menu_item_settings) {
            Intent intent = new Intent(this, SettingsActivity.class);
            startActivity(intent);
        } else if (id == R.id.menu_item_about) {
            Intent intent = new Intent(this, AboutActivity.class);
            startActivity(intent);
        } else if (id == R.id.menu_item_lic_agreement) {
            Intent intent = new Intent(this, LicenseAgreementActivity.class);
            startActivity(intent);
        }

        return super.onOptionsItemSelected(item);
    }

    private void checkTorchSupport() {
        Constants.IS_TORCH_SUPPORTED = getPackageManager().hasSystemFeature(PackageManager.FEATURE_CAMERA_FLASH);
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (mProgressDialog != null && mProgressDialog.isShowing()) mProgressDialog.dismiss();
    }

    @Override
    protected void onStart() {
        super.onStart();

        if (mProgressDialog != null && mProgressDialog.isShowing()) mProgressDialog.dismiss();

        boolean check = true;
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(this);
        if (prefs.contains("pref_key_shots_count") || prefs.contains("pref_key_last_usage_date")) {
            Date currentDate = new Date();
            long currentTime = currentDate.getTime();
            long lastUsage = prefs.getLong("pref_key_last_usage_date", -1);
            Date lastUsageDate = new Date(lastUsage);

            if (lastUsage != -1 && ((currentTime - lastUsage) >  60 * 60 * 24 * 31 * 1000L)) {
                // ok
                SharedPreferences.Editor editor = prefs.edit();
                editor.putInt("pref_key_shots_count", 0);
                editor.apply();
            } else {
                String currentMonthStr   = new SimpleDateFormat("MM").format(currentDate);
                String lastUsageMonthStr = new SimpleDateFormat("MM").format(lastUsageDate);

                if (currentMonthStr.equals(lastUsageMonthStr)) {
                    if (prefs.getInt("pref_key_shots_count", -1) >= Constants.MONTHLY_LIMIT) check = false;
                } else {
                    SharedPreferences.Editor editor = prefs.edit();
                    editor.putInt("pref_key_shots_count", 0);
                    editor.apply();
                }
            }
        } else {
            SettingsHelperClass.initRestrictionPropertiesFields(prefs);
        }

        if (!check) {
            mfabCapture.setVisibility(View.GONE);
            new AlertDialog.Builder(this)
                    .setTitle("Error")
                    .setMessage( String.format((String)getText(R.string.monthly_limit_exceeded_msg), Constants.MONTHLY_LIMIT) )
                    .setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                        }
                    })
                    .setCancelable(false)
                    .setIcon(R.drawable.error)
                    .show();

        } else {
            mfabCapture.setVisibility(View.VISIBLE);
        }

        mLimitExceeded = !check;
    }
}
