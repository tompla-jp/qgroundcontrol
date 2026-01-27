package org.mavlink.qgroundcontrol;

import android.content.ContentResolver;
import android.content.ContentValues;
import android.content.Context;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.provider.MediaStore;
import android.util.Log;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;

public final class QGCStartupLogger {
    private static final String TAG = "QGCStartupLogger";
    private static final String FILE_PREFIX = "qgc_startup_";
    private static final String FILE_SUFFIX = ".log";
    private static volatile Context sContext;
    private static volatile Uri sDownloadsUri;
    private static volatile String sFileName;

    private QGCStartupLogger() {
    }

    public static void setContext(Context context) {
        if (context != null) {
            sContext = context.getApplicationContext();
        }
    }

    public static void write(Context context, String message) {
        if (context != null) {
            setContext(context);
        }
        final Context ctx = (context != null) ? context : sContext;
        if (ctx == null) {
            Log.w(TAG, "write skipped: context missing");
            return;
        }
        final String line = "[" + System.currentTimeMillis() + "] " + message + "\n";
        writeToExternalMedia(ctx, line);
        writeToExternalFiles(ctx, line);
        writeToDownloads(ctx, line);
    }

    public static void writeFromNative(String message) {
        final Context ctx = sContext;
        if (ctx == null) {
            Log.w(TAG, "writeFromNative skipped: context missing");
            return;
        }
        write(ctx, message);
    }

    private static String getFileName() {
        if (sFileName == null) {
            sFileName = FILE_PREFIX + System.currentTimeMillis() + FILE_SUFFIX;
        }
        return sFileName;
    }

    private static void writeToExternalMedia(Context context, String line) {
        try {
            final File[] dirs = context.getExternalMediaDirs();
            if (dirs == null) {
                return;
            }
            for (File dir : dirs) {
                if (dir == null) {
                    continue;
                }
                append(new File(dir, getFileName()), line);
            }
        } catch (Exception e) {
            Log.e(TAG, "external media log failed", e);
        }
    }

    private static void writeToExternalFiles(Context context, String line) {
        try {
            final File dir = context.getExternalFilesDir(null);
            if (dir == null) {
                return;
            }
            append(new File(dir, getFileName()), line);
        } catch (Exception e) {
            Log.e(TAG, "external files log failed", e);
        }
    }

    private static void writeToDownloads(Context context, String line) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                final ContentResolver resolver = context.getContentResolver();
                final Uri collection = MediaStore.Downloads.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY);
                if (sDownloadsUri == null) {
                    final ContentValues values = new ContentValues();
                    values.put(MediaStore.MediaColumns.DISPLAY_NAME, getFileName());
                    values.put(MediaStore.MediaColumns.MIME_TYPE, "text/plain");
                    values.put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS);
                    sDownloadsUri = resolver.insert(collection, values);
                }
                if (sDownloadsUri != null) {
                    try (OutputStream os = resolver.openOutputStream(sDownloadsUri, "wa")) {
                        if (os != null) {
                            os.write(line.getBytes(StandardCharsets.UTF_8));
                        }
                    }
                } else {
                    Log.w(TAG, "downloads insert returned null");
                }
            } else {
                final File dir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS);
                append(new File(dir, getFileName()), line);
            }
        } catch (Exception e) {
            Log.e(TAG, "downloads log failed", e);
        }
    }

    private static void append(File file, String line) throws Exception {
        final File parent = file.getParentFile();
        if (parent != null && !parent.exists() && !parent.mkdirs()) {
            Log.w(TAG, "failed to create dir: " + parent.getAbsolutePath());
        }
        try (FileOutputStream fos = new FileOutputStream(file, true)) {
            fos.write(line.getBytes(StandardCharsets.UTF_8));
        }
    }
}
