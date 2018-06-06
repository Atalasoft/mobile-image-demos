package com.kofax.samples.mobilecapturedemo;


import android.support.design.widget.Snackbar;
import android.view.MenuItem;
import android.view.View;

import android.os.Bundle;
import android.preference.EditTextPreference;
import android.preference.ListPreference;
import android.preference.Preference;
import android.support.v7.app.ActionBar;
import android.preference.PreferenceFragment;
import android.preference.PreferenceManager;

import java.util.List;

public class SettingsActivity extends com.kofax.samples.mobilecapturedemo.AppCompatPreferenceActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setupActionBar();
    }

    private void setupActionBar() {
        ActionBar actionBar = getSupportActionBar();
        if (actionBar != null) {
            actionBar.setDisplayHomeAsUpEnabled(true);
        }
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        onBackPressed();
        return true;
    }

    @Override
    public void onBuildHeaders(List<Header> target) {
        loadHeadersFromResource(R.xml.pref_headers, target);
    }

    protected boolean isValidFragment(String fragmentName) {
        return PreferenceFragment.class.getName().equals(fragmentName) ||
               CameraPreferenceFragment.class.getName().equals(fragmentName) ||
               ImageProcessorPreferenceFragment.class.getName().equals(fragmentName);
    }

    public static class CustomPreferenceFragment extends PreferenceFragment {
        protected void bindPreferenceSummary(Preference preference, Preference.OnPreferenceChangeListener preferenceListener) {
            if (preference == null) return;
            preference.setOnPreferenceChangeListener(preferenceListener);
            preferenceListener.onPreferenceChange(preference,
                    PreferenceManager
                            .getDefaultSharedPreferences(preference.getContext())
                            .getString(preference.getKey(), ""));
        }

        protected Preference.OnPreferenceChangeListener mPrefChangeListener = new Preference.OnPreferenceChangeListener() {
            public boolean onPreferenceChange(Preference preference, Object value) {
                String stringValue = value.toString();

                if (preference instanceof EditTextPreference) {
                    EditTextPreference editPreference = (EditTextPreference) preference;

                    SettingsHelperClass.SettingValues prefValues = new SettingsHelperClass.SettingValues();
                    if (SettingsHelperClass.processEditTextPreference(editPreference.getKey(), stringValue, prefValues)) {
                        editPreference.setSummary(prefValues.prefix + Integer.toString(prefValues.value) + prefValues.postfix);
                    } else {
                        if (getView() != null) {
                            Snackbar.make(getView(), "Incorrect preference value", Snackbar.LENGTH_LONG)
                                    .setAction("OK", new View.OnClickListener() {
                                        @Override
                                        public void onClick(View view) {
                                        }
                                    }).show();
                        }
                        return false;
                    }
                } else if (preference instanceof ListPreference) {
                    ListPreference listPreference = (ListPreference) preference;
                    int index = listPreference.findIndexOfValue(stringValue);

                    if (index >= 0) {
                        String valueStr = (String)listPreference.getEntries()[index];
                        SettingsHelperClass.SettingValues prefValues = new SettingsHelperClass.SettingValues();
                        SettingsHelperClass.processListPreference(listPreference.getKey(), valueStr, prefValues);
                        listPreference.setSummary(prefValues.prefix + valueStr + prefValues.postfix);
                    } else {
                        listPreference.setSummary(null);
                    }
                } else {
                    preference.setSummary(stringValue);
                }
                return true;
            }
        };
    }

    public static class CameraPreferenceFragment extends CustomPreferenceFragment {
        @Override
        public void onCreate(Bundle savedInstanceState) {
            super.onCreate(savedInstanceState);
            addPreferencesFromResource(R.xml.pref_camera);
            setHasOptionsMenu(true);

            bindPreferenceSummary(findPreference("pref_key_device_declination_pitch"), mPrefChangeListener);
            bindPreferenceSummary(findPreference("pref_key_device_declination_roll"), mPrefChangeListener);
            bindPreferenceSummary(findPreference("pref_key_manual_capture_time"), mPrefChangeListener);
        }
    }

    public static class ImageProcessorPreferenceFragment extends CustomPreferenceFragment {
        @Override
        public void onCreate(Bundle savedInstanceState) {
            super.onCreate(savedInstanceState);
            addPreferencesFromResource(R.xml.pref_image_processor);
            setHasOptionsMenu(true);

            bindPreferenceSummary(findPreference("pref_key_image_processing_basic_mode"), mPrefChangeListener);
            bindPreferenceSummary(findPreference("pref_key_deskew_type_basic_mode"), mPrefChangeListener);
            bindPreferenceSummary(findPreference("pref_key_image_processing_scale"), mPrefChangeListener);
        }
    }
}