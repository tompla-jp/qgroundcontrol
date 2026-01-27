/****************************************************************************
 *
 * (c) 2025 Custom VOXL GCS
 *
 ****************************************************************************/

#include "CustomPlugin.h"

#include "CustomQGCApplication.h"
#include "QVIOHandler.h"
#include "Video/VideoHandler.h"

#include "JoystickManager.h"
#include "QGCApplication.h"
#include "QGCPalette.h"

#include <QtCore/qapplicationstatic.h>
#include <QtCore/QTimer>
#include <QtQml/QQmlApplicationEngine>
#include <QtQml/QQmlContext>
#include <QtQuick/QQuickItem>
#include <QtQuick/QQuickWindow>

QGC_LOGGING_CATEGORY(CustomPluginLog, "gcs.custom.plugin")

Q_APPLICATION_STATIC(CustomPlugin, _customPluginInstance);

CustomFlyViewOptions::CustomFlyViewOptions(QGCOptions *options, QObject *parent)
    : QGCFlyViewOptions(options, parent)
{
}

bool CustomFlyViewOptions::showInstrumentPanel() const
{
    return false;
}

bool CustomFlyViewOptions::showMapScale() const
{
    return false;
}

CustomOptions::CustomOptions(QObject *parent)
    : QGCOptions(parent)
    , _flyViewOptions(this, this)
{
}

bool CustomOptions::multiVehicleEnabled() const
{
    return false;
}

bool CustomOptions::enablePlanViewSelector() const
{
    return false;
}

CustomPlugin::CustomPlugin(QObject *parent)
    : QGCCorePlugin(parent)
{
}

QGCCorePlugin *CustomPlugin::instance()
{
    return _customPluginInstance();
}

QGCOptions *CustomPlugin::options()
{
    return &_options;
}

QQmlApplicationEngine *CustomPlugin::createQmlApplicationEngine(QObject *parent)
{
    QQmlApplicationEngine *qmlEngine = QGCCorePlugin::createQmlApplicationEngine(parent);

    // Expose custom singletons to QML
    qmlEngine->rootContext()->setContextProperty(QStringLiteral("videoHandler"), VideoHandler::instance());
#ifdef QGC_CUSTOM_BUILD
    qmlEngine->rootContext()->setContextProperty(QStringLiteral("customApp"), qgcApp()->customApplication());
    qmlEngine->rootContext()->setContextProperty(QStringLiteral("qvioHandler"), qgcApp()->customApplication()->qvioHandler());
    qmlEngine->rootContext()->setContextProperty(QStringLiteral("tofHandler"), qgcApp()->customApplication()->tofHandler());
#endif

    return qmlEngine;
}

void CustomPlugin::createRootWindow(QQmlApplicationEngine *qmlEngine)
{
    qmlEngine->load(QUrl(QStringLiteral("qrc:/qml/MainView.qml")));

    if (qmlEngine->rootObjects().isEmpty()) {
        return;
    }

    auto window = qobject_cast<QQuickWindow*>(qmlEngine->rootObjects().first());
    if (!window) {
        return;
    }

    auto binder = new QTimer(window);
    binder->setInterval(200);
    binder->setSingleShot(false);
    QObject::connect(binder, &QTimer::timeout, window, [window, binder]() {
        auto mainSurface = window->findChild<QQuickItem*>(QStringLiteral("mainVideoSurface"));
        auto pipSurface = window->findChild<QQuickItem*>(QStringLiteral("pipVideoSurface"));
        if (!mainSurface || !pipSurface) {
            return;
        }
        VideoHandler::instance()->bindSurfaces(mainSurface, pipSurface);
        binder->stop();
        binder->deleteLater();
    });
    binder->start();
}
