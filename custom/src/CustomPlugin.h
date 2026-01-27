/****************************************************************************
 *
 * (c) 2025 Custom VOXL GCS
 *
 ****************************************************************************/

#pragma once

#include "QGCCorePlugin.h"
#include "QGCOptions.h"
#include "QGCLoggingCategory.h"

class CustomOptions;

Q_DECLARE_LOGGING_CATEGORY(CustomPluginLog)

class CustomFlyViewOptions : public QGCFlyViewOptions
{
    Q_OBJECT
public:
    explicit CustomFlyViewOptions(QGCOptions *options, QObject *parent = nullptr);

protected:
    bool showInstrumentPanel() const final;
    bool showMapScale() const final;
};

class CustomOptions : public QGCOptions
{
    Q_OBJECT
public:
    explicit CustomOptions(QObject *parent = nullptr);

    bool multiVehicleEnabled() const final;
    bool enablePlanViewSelector() const final;
    const QGCFlyViewOptions *flyViewOptions() const final { return &_flyViewOptions; }

private:
    CustomFlyViewOptions _flyViewOptions;
};

class CustomPlugin : public QGCCorePlugin
{
    Q_OBJECT
public:
    explicit CustomPlugin(QObject *parent = nullptr);
    ~CustomPlugin() override = default;

    static QGCCorePlugin *instance();

    QGCOptions *options() final;
    QQmlApplicationEngine *createQmlApplicationEngine(QObject *parent) final;
    void createRootWindow(QQmlApplicationEngine *qmlEngine) final;

private:
    CustomOptions _options;
};
