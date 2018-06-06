package com.kofax.samples.common;

import android.app.Activity;
import android.content.pm.PackageManager;
import android.support.v4.app.ActivityCompat;

import java.util.ArrayList;
import java.util.Collection;

public class PermissionsManager {
    private static final int DEFAULT_REQUEST_CODE = 0;

    private final Activity mActivity;

    public PermissionsManager(Activity activity) {
        mActivity = activity;
    }

    public void request(String... permissions) {
        request(DEFAULT_REQUEST_CODE, permissions);
    }

    public void request(int requestCode, String... permissions) {
        permissions = getNotGranted(permissions);
        ActivityCompat.requestPermissions(mActivity, permissions, requestCode);
    }

    public boolean isGranted(String... permissions) {
        for (String permission : permissions) {
            if (!isGranted(permission)) {
                return false;
            }
        }
        return true;
    }

    private String[] getNotGranted(String[] permissions) {
        Collection<String> notGranted = new ArrayList<>(permissions.length);
        for (String permission : permissions) {
            if (!isGranted(permission)) {
                notGranted.add(permission);
            }
        }
        return notGranted.toArray(new String[notGranted.size()]);
    }

    private boolean isGranted(String permission) {
        return ActivityCompat.checkSelfPermission(mActivity, permission)
                == PackageManager.PERMISSION_GRANTED;
    }
}
