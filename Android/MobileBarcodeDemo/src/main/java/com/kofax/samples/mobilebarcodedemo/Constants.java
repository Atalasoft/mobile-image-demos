package com.kofax.samples.mobilebarcodedemo;

import com.kofax.kmc.kui.uicontrols.BarCodeFoundEvent;

public class Constants {
    static boolean IS_TORCH_SUPPORTED = false;
    final static int MONTHLY_LIMIT = 100;

    static String VERSION = "";

    static BarCodeFoundEvent BARCODE_EVENT = null;

    final static int SEND_EMAIL_REQUEST_ID  = 58;
    final static int BARCODE_FOUND_REQUEST_ID = 59;

    final static int PROCESSED_IMAGE_RETAKE_RESPONSE_ID  = 156;
    final static int PROCESSED_IMAGE_EMAIL_IS_SENT_RESPONSE_ID = 157;
}
