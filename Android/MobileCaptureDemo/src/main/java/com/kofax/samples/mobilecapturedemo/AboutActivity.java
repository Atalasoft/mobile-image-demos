package com.kofax.samples.mobilecapturedemo;

import android.content.res.Configuration;
import android.os.Bundle;
import android.preference.EditTextPreference;
import android.preference.PreferenceScreen;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Base64;
import android.view.MenuItem;
import android.view.View;
import android.webkit.WebView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.Toast;

import com.kofax.kmc.kut.utilities.SdkVersion;

public class AboutActivity extends AppCompatActivity {
    private LinearLayout mLayoutPortrait;
    private LinearLayout mLayoutLandscape;

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        mLayoutPortrait.setVisibility(newConfig.orientation == Configuration.ORIENTATION_PORTRAIT ? View.VISIBLE : View.GONE);
        mLayoutLandscape.setVisibility(newConfig.orientation == Configuration.ORIENTATION_LANDSCAPE ? View.VISIBLE : View.GONE);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_about);
        Toolbar toolbar = (Toolbar) findViewById(R.id.about_toolbar);
        setSupportActionBar(toolbar);

        String sdkVer = SdkVersion.getSdkVersion();

        String aboutStr = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\">\n" +
                "<HTML>\n" +
                "<HEAD>\n" +
                "<META HTTP-EQUIV=\"CONTENT-TYPE\" CONTENT=\"text/html; charset=us-ascii\">\n" +
                "<TITLE></TITLE>\n" +
                "<STYLE TYPE=\"text/css\">\n" +
                "\t<!--\n" +
                "\t\t@page { margin: 0.5in }\n" +
                "\t\tP { margin-bottom: 0.08in }\n" +
                "\t\tA:link { so-language: zxx }\n" +
                "\t-->\n" +
                "\t</STYLE>\n" +
                "</HEAD>\n" +
                "<BODY LANG=\"en-US\" DIR=\"LTR\" STYLE=\"border: none; padding: 0in\">\n" +
                "<P STYLE=\"margin-top: 0.07in; margin-bottom: 0.07in\"><FONT SIZE=2>\n" +
                "<p>This app shows developers what they could build with the Atalasoft MobileImage Capture SDK. When the user opens the camera, the software can guide them to take the image at the right angle. Access to the camera torch is enabled. Finally, the image taken is processed and cleaned up with eVRS and ready for a backend server process like OCR or storage.</p>\n" +
                "<p>To build your own document capture, processing, or viewing app - visit Atalasoft and grab a 30-day evaluation copy for yourself. We'll provide the tools and the support you need to get started!</p>\n" +
                "<h3 style=\"color: #2e6c80;\">About information:</h3>\n" +
                "<ol style=\"list-style: none; font-size: 14px; line-height: 32px; font-weight: bold;\">\n" +
                "<li style=\"clear: both;\">MobileImage - document capture SDK from Atalasoft.</li>\n" +
                "<li style=\"clear: both;\">Version: " + Constants.VERSION + "</li>\n" +
                "<li style=\"clear: both;\">MobileSDK Version: " + sdkVer + "</li>\n" +
                "<li style=\"clear: both;\"><a href=\"mailto:sales@atalasoft.com\">sales@atalasoft.com</a></li>\n" +
                "<li style=\"clear: both;\"><a title=\"Atalasoft\" href=\"http://hubs.ly/H03pzS80\">Atalasoft</a></li>\n" +
                "<li style=\"clear: both;\"><a title=\"Online Privacy Policy Tungsten Automation\" href=\"https://www.tungstenautomation.com/legal/privacy\">Online Privacy Policy Tungsten Automation</a></li>\n" +
                "</ol>\n" +
                "</FONT></P>\n" +
                "</BODY>\n" + "</HTML>";

        WebView aboutWebViewPortrait  = (WebView) findViewById(R.id.about_text_portrait);
        String encodedAboutStr = Base64.encodeToString(aboutStr.getBytes(), Base64.NO_PADDING);
        aboutWebViewPortrait.loadData(encodedAboutStr, "text/html; charset=utf-8", "base64");

        WebView aboutWebViewLandscape = (WebView) findViewById(R.id.about_text_landscape);
        aboutWebViewLandscape.loadData(encodedAboutStr, "text/html; charset=utf-8", "base64");

        mLayoutPortrait = (LinearLayout) findViewById(R.id.about_portrait_layout);
        mLayoutPortrait.setVisibility(getResources().getConfiguration().orientation == Configuration.ORIENTATION_PORTRAIT ? View.VISIBLE : View.GONE);

        mLayoutLandscape = (LinearLayout) findViewById(R.id.about_landscape_layout);
        mLayoutLandscape.setVisibility(getResources().getConfiguration().orientation == Configuration.ORIENTATION_LANDSCAPE ? View.VISIBLE : View.GONE);

        // these 2 lines enable back button
//        getSupportActionBar().setHomeButtonEnabled(true);
//        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();
        if (id == android.R.id.home) {
            finish();
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

}
