package com.kofax.samples.mobilecapturedemo;

import com.kofax.kmc.ken.engines.data.Image;

public class Constants {
    static Image RESULT_IMAGE = null;
    final static String PHOTO_ALBUM_NAME = "KofaxMobileCapture";

    static boolean IS_TORCH_SUPPORTED = false;

    static String VERSION = "";

    final static int DEFAULT_MANUAL_CAPTURE_TIME = 0;
    final static int MONTHLY_LIMIT = 100;

    final static int GALLERY_IMPORT_REQUEST_ID   = 56;
    final static int PROCESSED_IMAGE_REQUEST_ID  = 57;
    final static int SEND_EMAIL_REQUEST_ID       = 58;

    final static int PROCESSED_IMAGE_RETAKE_RESPONSE_ID  = 156;
    final static int PROCESSED_IMAGE_ACCEPT_RESPONSE_ID  = 157;

    //activity state constants
    final static String IMAGE_GALLERY_PATH_NAME = "SavedImageGalleryPath";
    final static String IMAGE_EXTERNAL_PATH_NAME = "SavedImageExternalPath";
}

