package com.kofax.samples.mobilecapturedemo;

import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;

import com.kofax.kmc.ken.engines.processing.ColorDepth;
import com.kofax.kmc.ken.engines.processing.CropType;
import com.kofax.kmc.ken.engines.processing.DeskewType;
import com.kofax.kmc.ken.engines.processing.ImageProcessorConfiguration;
import com.kofax.kmc.ken.engines.processing.RotateType;

import java.util.Date;

class SettingsHelperClass {
    static final class DefaultSettings{
        static String pref_key_image_processing_basic_mode = "BW";
        static boolean pref_key_image_processing_auto_crop = true;
        static boolean pref_key_image_processing_auto_rotate = true;
        static String pref_key_deskew_type_basic_mode = "None";
        static int pref_key_image_processing_scale = 200;

        static boolean pref_key_show_gallery = true;
        static int pref_key_device_declination_value = 0;  // for pref_key_device_declination_roll and pref_key_device_declination_pitch
        static int pref_key_manual_capture_time = 10;
    }

    static final class SettingValues {
        String postfix = "";
        String prefix = "";
        int value = 0;

        void clear()
        {
            postfix = "";
            prefix = "";
            value = 0;
        }
    }

    static boolean isGalleryEnabled(Context context) {
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(context);
        return prefs.contains("pref_key_show_gallery") ? prefs.getBoolean("pref_key_show_gallery", false) : DefaultSettings.pref_key_show_gallery;
    }

    static boolean processEditTextPreference(String settingKey, String settingVal, SettingValues values) {
        values.clear();

        try {
            values.value = Integer.parseInt(settingVal);
        } catch (NumberFormatException e) {
            return false;
        }

        switch (settingKey) {
            case "pref_key_device_declination_pitch":
            case "pref_key_device_declination_roll":
                values.postfix = "°";
                return (values.value >= -180 && values.value <= 180);

            case "pref_key_manual_capture_time":
                values.postfix = " sec";
                return (values.value >= 0);

            default:
                return false;
        }
    }

    static void processListPreference(String settingKey, String settingVal, SettingValues values) {
        values.clear();
        if (settingKey.equals("pref_key_image_processing_scale") && !settingVal.equals("Auto")) {
            values.postfix = " dpi";
        }
    }

    static ImageProcessorConfiguration getImageProcessorConfiguration(Context context) {
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(context);
        ImageProcessorConfiguration imageProcessorConf = new ImageProcessorConfiguration();

        String deskewTypeStr = DefaultSettings.pref_key_deskew_type_basic_mode;
        if (prefs.contains("pref_key_deskew_type_basic_mode")) {
            deskewTypeStr = prefs.getString("pref_key_deskew_type_basic_mode", "");
        }
        switch (deskewTypeStr) {
            case "None":
                imageProcessorConf.deskewType = DeskewType.DESKEW_NONE;
                break;
            case "ByDocumentEdges":
                imageProcessorConf.deskewType = DeskewType.DESKEW_BY_DOCUMENT_EDGES;
                break;
            case "ByDocumentContent":
                imageProcessorConf.deskewType = DeskewType.DESKEW_BY_DOCUMENT_CONTENT;
                break;
        }

        if (prefs.contains("pref_key_image_processing_scale")) {
            String dpiStr = prefs.getString("pref_key_image_processing_scale", "");
            int val;
            try {
                val = Integer.parseInt(dpiStr);
                imageProcessorConf.outputDPI = val;
            } catch (NumberFormatException e) {
                // leave default outputDPI
            }
        } else {
            imageProcessorConf.outputDPI = DefaultSettings.pref_key_image_processing_scale;
        }

        if ((!prefs.contains("pref_key_image_processing_auto_rotate") && DefaultSettings.pref_key_image_processing_auto_rotate) ||
            (prefs.contains("pref_key_image_processing_auto_rotate") && prefs.getBoolean("pref_key_image_processing_auto_rotate", false))) {
            imageProcessorConf.rotateType = RotateType.ROTATE_AUTO;
        }

        if ((!prefs.contains("pref_key_image_processing_auto_crop") && DefaultSettings.pref_key_image_processing_auto_crop) ||
            (prefs.contains("pref_key_image_processing_auto_crop") && prefs.getBoolean("pref_key_image_processing_auto_crop", false))) {
            imageProcessorConf.cropType = CropType.CROP_AUTO;
        }

        String imageProcessingModeStr = DefaultSettings.pref_key_image_processing_basic_mode;
        if (prefs.contains("pref_key_image_processing_basic_mode")) {
            imageProcessingModeStr = prefs.getString("pref_key_image_processing_basic_mode", "");
        }
        switch (imageProcessingModeStr) {
            case "BW":
                imageProcessorConf.outputColorDepth = ColorDepth.BITONAL;
                break;
            case "Gray":
                imageProcessorConf.outputColorDepth = ColorDepth.GRAYSCALE;
                break;
            case "Color":
                imageProcessorConf.outputColorDepth = ColorDepth.COLOR;
                break;
        }

        return imageProcessorConf;
    }

    static int getManualCaptureTime(Context context) {
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(context);

        if (prefs.contains("pref_key_manual_capture_time")) {
            try {
                return Integer.parseInt(prefs.getString("pref_key_manual_capture_time", ""));
            } catch (NumberFormatException e) {
                return -1;
            }
        } else {
            return DefaultSettings.pref_key_manual_capture_time;
        }
    }

    static final class DeviceDeclinationResult {
        boolean result = false;
        int value = 0;

        DeviceDeclinationResult() {
            result = false;
            value = 0;
        }

        DeviceDeclinationResult(boolean res, int val) {
            result = res;
            value = val;
        }
    }

    private static DeviceDeclinationResult getDeviceDeclinationValue(Context context, String declinationKey) {
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(context);

        if (prefs.contains(declinationKey)) {
            try {
                return new DeviceDeclinationResult(true, Integer.parseInt(prefs.getString(declinationKey, "")));
            } catch (NumberFormatException e) {
                return new DeviceDeclinationResult();
            }
        } else {
            return new DeviceDeclinationResult(true, DefaultSettings.pref_key_device_declination_value);
        }
    }

    static DeviceDeclinationResult getDeviceDeclinationPitch(Context context) {
        return getDeviceDeclinationValue(context, "pref_key_device_declination_pitch");
    }

    static DeviceDeclinationResult getDeviceDeclinationRoll(Context context) {
        return getDeviceDeclinationValue(context, "pref_key_device_declination_roll");
    }

    static void initRestrictionPropertiesFields(SharedPreferences prefs)
    {
        SharedPreferences.Editor editor = prefs.edit();
        editor.putInt("pref_key_shots_count", 0);
        editor.putLong("pref_key_last_usage_date", new Date().getTime());
        editor.apply();
    }
}
