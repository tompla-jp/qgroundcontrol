package org.mavlink.qgroundcontrol;

import android.content.Context;

import org.qtproject.qt.android.bindings.QtApplication;

public class QGCApp extends QtApplication {
    @Override
    protected void attachBaseContext(Context base) {
        super.attachBaseContext(base);
        QGCStartupLogger.setContext(base);
        QGCStartupLogger.write(base, "QGCApp attachBaseContext");
    }

    @Override
    public void onCreate() {
        QGCStartupLogger.setContext(this);
        QGCStartupLogger.write(this, "QGCApp onCreate start");
        super.onCreate();
        QGCStartupLogger.write(this, "QGCApp onCreate end");
    }
}
