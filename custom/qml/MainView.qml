import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.Controllers
import QGroundControl.FactControls
import QGroundControl.FactSystem
import QGroundControl.Palette
import QGroundControl.ScreenTools
import QGroundControl.FlightDisplay
import QGroundControl.FlightMap
import QGroundControl.Vehicle
import "HUD"
import "Video"

ApplicationWindow {
    id: mainWindow
    visible: true
    title: QGroundControl.appName
    width: ScreenTools.isMobile ? Screen.width : Math.min(Screen.width, 1280)
    height: ScreenTools.isMobile ? Screen.height : Math.min(Screen.height, 800)
    onClosing: Qt.quit()

    readonly property var activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
    property bool showCustomSettingsPanel: false
    property bool showPipUrlPanel: false
    readonly property bool _hasVideoHandler: typeof videoHandler !== "undefined" && videoHandler !== null
    readonly property bool _displaySwapped: _hasVideoHandler ? videoHandler.displaySwapped : false
    readonly property bool _pipVisible: _hasVideoHandler && videoHandler.subUrl !== ""
    readonly property real _topHudInset: ScreenTools.isMobile ? ScreenTools.defaultFontPixelHeight * 0.6 : 0
    readonly property real _topHudExtraHeight: ScreenTools.isMobile ? ScreenTools.defaultFontPixelHeight * 0.4 : 0
    readonly property real _topHudHeight: ScreenTools.toolbarHeight + _topHudExtraHeight
    readonly property real _topHudOffset: _topHudInset + _topHudHeight
    readonly property real _topHudSideInset: ScreenTools.isMobile ? ScreenTools.defaultFontPixelWidth * 1.2 : 0

    QGCPalette { id: qgcPal; colorGroupEnabled: true }

    // Globals used by stock widgets and controllers
    QtObject {
        id: globals
        readonly property var activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
        readonly property real defaultTextHeight: ScreenTools.defaultFontPixelHeight
        readonly property real defaultTextWidth: ScreenTools.defaultFontPixelWidth
        property int validationErrorCount: 0
        property bool commingFromRIDIndicator: false
    }

    function allowViewSwitch() { return true }
    function showIndicatorDrawer(component, indicatorItem) {
        indicatorDrawer.sourceComponent = component
        indicatorDrawer.indicatorItem = indicatorItem
        indicatorDrawer.open()
    }
    function closeIndicatorDrawer() { indicatorDrawer.close() }
    function closeCustomSettingsPanel() {
        showCustomSettingsPanel = false
        showPipUrlPanel = false
    }
    function showToolSelectDialog() {
        if (allowViewSwitch()) {
            showIndicatorDrawer(toolSelectComponent, null)
        }
    }
    function showTool(toolTitle, toolSource, settingsPage) {
        if (!allowViewSwitch()) {
            return
        }
        rootStack.push(toolPageComponent, {
            toolTitle: toolTitle,
            toolSource: toolSource,
            initialSettingsPage: settingsPage ? settingsPage : ""
        })
    }
    function showAnalyzeTool() {
        showTool(qsTr("Analyze Tools"), "qrc:/qml/AnalyzeView.qml")
    }
    function showVehicleConfig() {
        showTool(qsTr("Vehicle Configuration"), "qrc:/qml/SetupView.qml")
    }
    function showSettingsTool(settingsPage) {
        showTool(qsTr("Application Settings"), "qrc:/qml/AppSettings.qml", settingsPage)
    }
    function showPlanView() {
        showTool(qsTr("Plan Flight"), "qrc:/qml/PlanView.qml")
    }

    function showMessageDialog(dialogTitle, dialogText, buttons = Dialog.Ok, acceptFunction = null, closeFunction = null) {
        simpleMessageDialogComponent.createObject(mainWindow, {
            title: dialogTitle,
            text: dialogText,
            buttons: buttons,
            acceptFunction: acceptFunction,
            closeFunction: closeFunction
        }).open()
    }

    function _showMessageDialog(dialogTitle, dialogText) {
        showMessageDialog(dialogTitle, dialogText)
    }

    Component {
        id: simpleMessageDialogComponent

        QGCSimpleMessageDialog {
        }
    }

    function recStatColor(recStatValue) {
        switch (recStatValue) {
        case 0:
            return "#ff4d4f"
        case 1:
        case 2:
        case 9:
        case 10:
            return "#f5c542"
        case 3:
        case 4:
        case 5:
            return "#3bc46b"
        case 6:
        case 7:
        case 8:
            return "#ff4d4f"
        default:
            return "#9aa5b1"
        }
    }
    function recStatDisplayText(recStatValue) {
        switch (recStatValue) {
        case 1:
            return qsTr("ソフトウェアの初期化中です")
        case 2:
            return qsTr("時刻を同期中です")
        case 3:
            return qsTr("録画可能です")
        case 4:
            return qsTr("録画が可能です")
        case 5:
            return qsTr("録画しています")
        case 6:
            return qsTr("空き容量が不足しています")
        case 7:
            return qsTr("ストレージ確認に失敗しました")
        case 8:
            return qsTr("ソフトウェアが停止しています")
        case 9:
            return qsTr("録画準備処理中です")
        case 10:
            return qsTr("録画停止処理中です")
        case 0:
        default:
            return qsTr("録画状態がわかりません")
        }
    }
    function recStatShortText(recStatValue) {
        switch (recStatValue) {
        case 4:
            return qsTr("録画可能")
        case 5:
            return qsTr("録画中")
        case 9:
            return qsTr("録画準備中")
        case 10:
            return qsTr("録画停止中")
        case 6:
        case 7:
        case 8:
            return qsTr("録画不可")
        case 0:
            return qsTr("録画不可")
        case 3:
            return qsTr("録画可能")
        case 1:
        case 2:
        default:
            return qsTr("録画待機")
        }
    }
    function recStatCompactColor(recStatValue) {
        switch (recStatValue) {
        case 9:
        case 10:
            return "#f5c542"
        case 3:
        case 4:
            return "#3bc46b"
        case 5:
            return "#ff4d4f"
        case 0:
        case 1:
        case 2:
        case 6:
        case 7:
        case 8:
        default:
            return "#ffffff"
        }
    }
    function recStatCompactText(recStatValue) {
        switch (recStatValue) {
        case 3:
        case 4:
            return qsTr("録画可能")
        case 5:
            return qsTr("録画中")
        case 9:
            return qsTr("録画準備中")
        case 10:
            return qsTr("録画停止中")
        case 0:
        case 1:
        case 2:
        case 6:
        case 7:
        case 8:
        default:
            return qsTr("録画不可")
        }
    }

    Component {
        id: toolPageComponent
        Rectangle {
            anchors.fill: parent
            color: qgcPal.window

            property string toolTitle: ""
            property var toolSource
            property string initialSettingsPage: ""

            function _applyInitialSettingsPage() {
                if (initialSettingsPage !== "" && toolLoader.item && toolLoader.item.showSettingsPage) {
                    toolLoader.item.showSettingsPage(initialSettingsPage)
                    initialSettingsPage = ""
                }
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: 0
                Rectangle {
                    Layout.fillWidth: true
                    height: ScreenTools.toolbarHeight
                    color: qgcPal.toolbarBackground
                    RowLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.leftMargin: ScreenTools.defaultFontPixelWidth
                        spacing: ScreenTools.defaultFontPixelWidth

                        QGCLabel {
                            font.pointSize: ScreenTools.largeFontPointSize
                            text: "<"
                            color: qgcPal.text
                        }

                        QGCLabel {
                            text: qsTr("Exit") + " " + toolTitle
                            font.pointSize: ScreenTools.largeFontPointSize
                            color: qgcPal.text
                        }
                    }
                    QGCMouseArea {
                        anchors.fill: parent
                        onClicked: rootStack.pop()
                    }
                }
                Loader {
                    id: toolLoader
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    source: typeof toolSource === "string" ? toolSource : ""
                    sourceComponent: typeof toolSource === "string" ? null : toolSource
                    onLoaded: _applyInitialSettingsPage()
                }
            }
        }
    }

    Component {
        id: toolSelectComponent

        ToolIndicatorPage {
            id: toolSelectDialog

            property real _toolButtonHeight: ScreenTools.defaultFontPixelHeight * 3
            property real _margins: ScreenTools.defaultFontPixelWidth

            contentComponent: Component {
                ColumnLayout {
                    spacing: ScreenTools.defaultFontPixelWidth

                    SubMenuButton {
                        height: toolSelectDialog._toolButtonHeight
                        Layout.fillWidth: true
                        text: qsTr("Plan Flight")
                        imageResource: "/qmlimages/Plan.svg"
                        onClicked: {
                            if (allowViewSwitch()) {
                                closeIndicatorDrawer()
                                showPlanView()
                            }
                        }
                    }

                    SubMenuButton {
                        height: toolSelectDialog._toolButtonHeight
                        Layout.fillWidth: true
                        text: qsTr("Analyze Tools")
                        imageResource: "/qmlimages/Analyze.svg"
                        onClicked: {
                            if (allowViewSwitch()) {
                                closeIndicatorDrawer()
                                showAnalyzeTool()
                            }
                        }
                    }

                    SubMenuButton {
                        height: toolSelectDialog._toolButtonHeight
                        Layout.fillWidth: true
                        text: qsTr("Vehicle Configuration")
                        imageResource: "/qmlimages/Gears.svg"
                        onClicked: {
                            if (allowViewSwitch()) {
                                closeIndicatorDrawer()
                                showVehicleConfig()
                            }
                        }
                    }

                    SubMenuButton {
                        height: toolSelectDialog._toolButtonHeight
                        Layout.fillWidth: true
                        text: qsTr("Application Settings")
                        imageResource: "/res/QGCLogoFull.svg"
                        imageColor: "transparent"
                        onClicked: {
                            if (allowViewSwitch()) {
                                closeIndicatorDrawer()
                                showSettingsTool()
                            }
                        }
                    }

                    SubMenuButton {
                        height: toolSelectDialog._toolButtonHeight
                        Layout.fillWidth: true
                        text: qsTr("Close %1").arg(QGroundControl.appName)
                        imageResource: "/res/cancel.svg"
                        visible: true
                        onClicked: Qt.quit()
                    }

                    Item { Layout.fillWidth: true; Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 0.5 }

                    ColumnLayout {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.fillWidth: true
                        spacing: 0

                        QGCLabel {
                            text: qsTr("%1 Version").arg(QGroundControl.appName)
                            font.pointSize: ScreenTools.smallFontPointSize
                            wrapMode: QGCLabel.WordWrap
                            Layout.maximumWidth: parent.width
                            Layout.alignment: Qt.AlignHCenter
                            horizontalAlignment: Text.AlignHCenter
                        }
                        QGCLabel {
                            text: QGroundControl.qgcVersion
                            font.pointSize: ScreenTools.smallFontPointSize
                            wrapMode: QGCLabel.WrapAnywhere
                            Layout.maximumWidth: parent.width
                            Layout.alignment: Qt.AlignHCenter
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }
        }
    }

    Popup {
        id: indicatorDrawer
        x: calcXPosition()
        y: _topHudOffset + _margins
        leftInset: 0
        rightInset: 0
        topInset: 0
        bottomInset: 0
        padding: _margins * 2
        visible: false
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        property var sourceComponent
        property var indicatorItem
        property bool _expanded: false
        property real _margins: ScreenTools.defaultFontPixelHeight / 4

        function calcXPosition() {
            if (indicatorItem) {
                var xCenter = indicatorItem.mapToItem(mainWindow.contentItem, indicatorItem.width / 2, 0).x
                return Math.max(_margins, Math.min(xCenter - (contentItem.implicitWidth / 2), mainWindow.contentItem.width - contentItem.implicitWidth - _margins - (indicatorDrawer.padding * 2) - (ScreenTools.defaultFontPixelHeight / 2)))
            } else {
                return _margins
            }
        }

        onOpened: {
            _expanded = false
            indicatorDrawerLoader.sourceComponent = indicatorDrawer.sourceComponent
        }
        onClosed: {
            _expanded = false
            indicatorItem = undefined
            indicatorDrawerLoader.sourceComponent = undefined
        }

        background: Item {
            Rectangle {
                id: backgroundRect
                anchors.fill: parent
                color: qgcPal.window
                radius: indicatorDrawer._margins
                opacity: 0.85
            }

            Rectangle {
                anchors.horizontalCenter: backgroundRect.right
                anchors.verticalCenter: backgroundRect.top
                width: ScreenTools.largeFontPixelHeight
                height: width
                radius: width / 2
                color: qgcPal.button
                border.color: qgcPal.buttonText
                visible: indicatorDrawerLoader.item && indicatorDrawerLoader.item.showExpand && !indicatorDrawer._expanded

                QGCLabel {
                    anchors.centerIn: parent
                    text: ">"
                    color: qgcPal.buttonText
                }

                QGCMouseArea {
                    fillItem: parent
                    onClicked: indicatorDrawer._expanded = true
                }
            }
        }

        contentItem: QGCFlickable {
            id: indicatorDrawerLoaderFlickable
            implicitWidth: Math.min(mainWindow.contentItem.width - (2 * indicatorDrawer._margins) - (indicatorDrawer.padding * 2), indicatorDrawerLoader.width)
            implicitHeight: Math.min(mainWindow.contentItem.height - _topHudOffset - (2 * indicatorDrawer._margins) - (indicatorDrawer.padding * 2), indicatorDrawerLoader.height)
            contentWidth: indicatorDrawerLoader.width
            contentHeight: indicatorDrawerLoader.height

            Loader {
                id: indicatorDrawerLoader

                Binding {
                    target: indicatorDrawerLoader.item
                    property: "expanded"
                    value: indicatorDrawer._expanded
                }

                Binding {
                    target: indicatorDrawerLoader.item
                    property: "drawer"
                    value: indicatorDrawer
                }
            }
        }
    }

    StackView {
        id: rootStack
        anchors.fill: parent
        initialItem: mainPageComponent
    }

    Rectangle {
        id: statusTextOverlay
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: _topHudOffset + ScreenTools.defaultFontPixelHeight * 0.5
        z: 100
        visible: typeof customApp !== "undefined" && customApp.statusOverlayVisible
        color: Qt.rgba(0.84, 0, 0, 0.55)
        radius: 0
        width: Math.min(parent.width * 0.84, Math.max(ScreenTools.defaultFontPixelWidth * 32, statusTextOverlayLabel.implicitWidth + ScreenTools.defaultFontPixelWidth * 3))
        height: statusTextOverlayLabel.implicitHeight + ScreenTools.defaultFontPixelHeight

        QGCLabel {
            id: statusTextOverlayLabel
            anchors.centerIn: parent
            width: parent.width - ScreenTools.defaultFontPixelWidth * 2
            text: typeof customApp !== "undefined" ? customApp.statusOverlayMessage : ""
            color: "#ffffff"
            font.pixelSize: ScreenTools.defaultFontPixelHeight * 1.08
            font.bold: true
            textFormat: Text.PlainText
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WrapAnywhere
        }
    }

    Component {
        id: mainPageComponent
        Rectangle {
            anchors.fill: parent
            color: qgcPal.window

            property bool _videoSurfacesBound: false
            readonly property real _hudEdgeInset: ScreenTools.defaultFontPixelHeight * 1.5
            readonly property real _leftHudTopMargin: ScreenTools.defaultFontPixelHeight * 0.7
            readonly property real _leftHudClusterSpacing: ScreenTools.defaultFontPixelHeight * 1.5
            readonly property real _compassWidgetSize: (ScreenTools.defaultFontPixelHeight * 5 + 80) * 0.62
            readonly property real _attitudeWidgetSize: _compassWidgetSize * 0.9
            readonly property real _pipAspectRatio: 4 / 3
            readonly property real _pipInfoHeight: ScreenTools.defaultFontPixelHeight * 2.3
            readonly property real _pipMaxHeight: parent.height * 0.36
            readonly property real _pipWidth: Math.min(parent.width * 0.25, (_pipMaxHeight - _pipInfoHeight) * _pipAspectRatio)
            readonly property real _pipFrameHeight: _pipWidth / _pipAspectRatio
            readonly property real _pipHeight: _pipFrameHeight + _pipInfoHeight
            readonly property real _pipLeftShift: Screen.pixelDensity * 5
            readonly property real _pipDownShift: Screen.pixelDensity * 5
            function _tryBindVideoSurfaces() {
                if (_videoSurfacesBound || !_hasVideoHandler || !mainVideo || !pipVideo) {
                    return
                }
                if (!mainVideo.surfaceItem || !mainVideo.surfaceItem.window) {
                    videoBindRetry.start()
                    return
                }
                videoHandler.bindSurfaces(mainVideo.surfaceItem, pipVideo.surfaceItem)
                _videoSurfacesBound = true
            }

            Component.onCompleted: _tryBindVideoSurfaces()

            Timer {
                id: videoBindRetry
                interval: 200
                repeat: false
                onTriggered: _tryBindVideoSurfaces()
            }

            Connections {
                target: mainVideo ? mainVideo.surfaceItem : null
                function onWindowChanged() { _tryBindVideoSurfaces() }
            }

            Connections {
                target: pipVideo ? pipVideo.surfaceItem : null
                function onWindowChanged() { _tryBindVideoSurfaces() }
            }

                // Top HUD / toolbar (fixed height)
                Item {
                    id: topHUD
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.topMargin: _topHudInset
                    height: _topHudHeight
                    z: 15

                    FlyViewToolBar {
                        id: flyToolbar
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        contentLeftMargin: _topHudSideInset
                    }
                }

                // Main video area
                VideoMain {
                    id: mainVideo
                    anchors.top: topHUD.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    url: _hasVideoHandler ? (_displaySwapped ? videoHandler.subUrl : videoHandler.mainUrl) : ""
                    receiver: _hasVideoHandler ? (_displaySwapped ? videoHandler.subReceiver : videoHandler.mainReceiver) : null
                    label: _displaySwapped ? qsTr("PiP") : qsTr("Main")
                    z: 0
                }

                // HUD overlay layer on top of video
                Item {
                    id: hudLayer
                    anchors.fill: mainVideo
                    z: 10

                    // Compass only cluster
                    Row {
                        id: leftHudCluster
                        spacing: ScreenTools.defaultFontPixelWidth * 3
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.margins: _hudEdgeInset
                        anchors.leftMargin: _hudEdgeInset
                        anchors.topMargin: _leftHudTopMargin

                        IntegratedCompassAttitude {
                            id: compass
                            vehicle: mainWindow.activeVehicle
                            width: _compassWidgetSize
                            height: _compassWidgetSize
                            headingFontScale: 0.74
                            compassBorder: 1
                            compassRadius: _compassWidgetSize / 2 - 6
                            attitudeSize: ScreenTools.defaultFontPixelWidth * 0.8
                            attitudeSpacing: attitudeSize * 0.6
                        }
                    }

                    ReversedAttitudeWidget {
                        id: attitudeIndicator
                        anchors.left: parent.left
                        anchors.leftMargin: _hudEdgeInset
                        anchors.top: leftHudCluster.bottom
                        anchors.topMargin: _leftHudClusterSpacing
                        size: _attitudeWidgetSize
                        vehicle: mainWindow.activeVehicle
                        showHeading: false
                        visible: !!mainWindow.activeVehicle
                    }

                        Rectangle {
                            id: localPositionBadge
                            anchors.left: attitudeIndicator.left
                            anchors.leftMargin: -Screen.pixelDensity * 5 + ScreenTools.defaultFontPixelWidth * 2
                            anchors.top: attitudeIndicator.bottom
                            anchors.topMargin: ScreenTools.defaultFontPixelHeight * 1.55
                            visible: !!mainWindow.activeVehicle
                        radius: ScreenTools.defaultFontPixelHeight * 0.42
                        color: "transparent"
                        border.width: 0
                        clip: true

                        readonly property var _localPosition: mainWindow.activeVehicle ? mainWindow.activeVehicle.localPosition : null
                        readonly property bool _hasLocalPosition: !!_localPosition && _localPosition.telemetryAvailable
                        readonly property real _badgeLeftPadding: ScreenTools.defaultFontPixelWidth * 0.4
                        readonly property real _badgeRightPadding: ScreenTools.defaultFontPixelWidth * 0.18
                        readonly property real _badgeVerticalPadding: ScreenTools.defaultFontPixelHeight * 0.24
                        readonly property real _columnSpacing: ScreenTools.defaultFontPixelWidth * 0.72
                        readonly property real _valueFontPixelSize: ScreenTools.defaultFontPixelHeight * 0.68
                        readonly property real _fallbackWidth: Math.max(ScreenTools.defaultFontPixelWidth * 26, _attitudeWidgetSize * 1.95)
                        readonly property real _preferredWidth: cpuTempBadge.visible
                                                                    ? Math.max(_fallbackWidth, cpuTempBadge.x + cpuTempBadge.width - x + ScreenTools.defaultFontPixelWidth * 4)
                                                                    : _fallbackWidth
                        readonly property real _maxAllowedWidth: Math.min(parent.width - x - _hudEdgeInset, _preferredWidth)

                        function _factValue(fact) {
                            if (!_hasLocalPosition || !fact) {
                                return NaN
                            }

                            const numeric = Number(fact.value)
                            return isFinite(numeric) ? numeric : NaN
                        }

                        function _formatValue(value, unit) {
                            return isFinite(value) ? value.toFixed(1) + unit : "--"
                        }

                        function _horizontalDistanceValue() {
                            const x = _factValue(_localPosition ? _localPosition.x : null)
                            const y = _factValue(_localPosition ? _localPosition.y : null)
                            return isFinite(x) && isFinite(y) ? Math.sqrt(x * x + y * y) : NaN
                        }

                        function _horizontalSpeedValue() {
                            const vx = _factValue(_localPosition ? _localPosition.vx : null)
                            const vy = _factValue(_localPosition ? _localPosition.vy : null)
                            return isFinite(vx) && isFinite(vy) ? Math.sqrt(vx * vx + vy * vy) : NaN
                        }

                        function _heightValue() {
                            const z = _factValue(_localPosition ? _localPosition.z : null)
                            return isFinite(z) ? -z : NaN
                        }

                        width: Math.min(_maxAllowedWidth, localPositionGrid.width + _badgeLeftPadding + _badgeRightPadding)
                        implicitHeight: localPositionGrid.implicitHeight + _badgeVerticalPadding * 2

                        TextMetrics {
                            id: localPositionMetrics
                            font.pixelSize: localPositionBadge._valueFontPixelSize
                            font.bold: true
                            readonly property real speedWidth: speedMetric.advanceWidth
                            readonly property real distanceWidth: distanceMetric.advanceWidth
                            readonly property real heightWidth: heightMetric.advanceWidth
                        }

                        TextMetrics {
                            id: speedMetric
                            font.pixelSize: localPositionBadge._valueFontPixelSize
                            font.bold: true
                            text: qsTr("S: -000.0m/s")
                        }

                        TextMetrics {
                            id: distanceMetric
                            font.pixelSize: localPositionBadge._valueFontPixelSize
                            font.bold: true
                            text: qsTr("D: -000.0m")
                        }

                        TextMetrics {
                            id: heightMetric
                            font.pixelSize: localPositionBadge._valueFontPixelSize
                            font.bold: true
                            text: qsTr("H: -000.0m")
                        }

                        Row {
                            id: localPositionGrid
                            anchors.left: parent.left
                            anchors.leftMargin: localPositionBadge._badgeLeftPadding
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: localPositionBadge._columnSpacing
                            readonly property real speedColumnWidth: Math.ceil(localPositionMetrics.speedWidth)
                            readonly property real distanceColumnWidth: Math.ceil(localPositionMetrics.distanceWidth)
                            readonly property real heightColumnWidth: Math.ceil(localPositionMetrics.heightWidth)
                            width: speedColumnWidth + distanceColumnWidth + heightColumnWidth + localPositionBadge._columnSpacing * 2

                            QGCLabel {
                                id: speedLabel
                                width: localPositionGrid.speedColumnWidth
                                text: qsTr("S: %1").arg(localPositionBadge._formatValue(localPositionBadge._horizontalSpeedValue(), "m/s"))
                                color: qgcPal.text
                                font.pixelSize: localPositionBadge._valueFontPixelSize
                                font.bold: true
                            }

                            QGCLabel {
                                id: distanceLabel
                                width: localPositionGrid.distanceColumnWidth
                                text: qsTr("D: %1").arg(localPositionBadge._formatValue(localPositionBadge._horizontalDistanceValue(), "m"))
                                color: qgcPal.text
                                font.pixelSize: localPositionBadge._valueFontPixelSize
                                font.bold: true
                            }

                            QGCLabel {
                                id: heightLabel
                                width: localPositionGrid.heightColumnWidth
                                text: qsTr("H: %1").arg(localPositionBadge._formatValue(localPositionBadge._heightValue(), "m"))
                                color: qgcPal.text
                                font.pixelSize: localPositionBadge._valueFontPixelSize
                                font.bold: true
                            }
                        }
                    }

                    Rectangle {
                        id: cpuTempBadge
                        anchors.left: attitudeIndicator.right
                        anchors.top: leftHudCluster.top
                        anchors.topMargin: ScreenTools.defaultFontPixelHeight * 0.12
                        anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 1.3
                        visible: !!mainWindow.activeVehicle && mainWindow.activeVehicle.cpuTempAvailable
                        radius: ScreenTools.defaultFontPixelHeight * 0.42
                        color: Qt.rgba(0, 0, 0, 0.42)
                        border.width: 0
                        implicitWidth: cpuTempColumn.implicitWidth + ScreenTools.defaultFontPixelWidth * 1.8
                        implicitHeight: cpuTempColumn.implicitHeight + ScreenTools.defaultFontPixelHeight * 0.7

                        Column {
                            id: cpuTempColumn
                            anchors.centerIn: parent
                            spacing: ScreenTools.defaultFontPixelHeight * 0.08

                            QGCLabel {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: qsTr("CPU:")
                                color: qgcPal.text
                                font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.62
                                font.bold: true
                            }

                            QGCLabel {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: qsTr("%1°C").arg(mainWindow.activeVehicle ? Number(mainWindow.activeVehicle.cpuTempCelsius).toFixed(1) : "--")
                                color: qgcPal.text
                                font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.72
                                font.bold: true
                            }
                        }
                    }

                    // Temporary top-right storage-only badge while camera UI is being rebuilt.
                    Item {
                        id: cameraStorageBadge
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: ScreenTools.defaultFontPixelHeight * 1.5
                        z: 20
                        readonly property var activeVehicle: globals.activeVehicle
                        readonly property var cameraManager: globals.activeVehicle ? globals.activeVehicle.cameraManager : null
                        readonly property var activeCamera: cameraManager ? cameraManager.currentCameraInstance : null
                        property bool recStatusPopupVisible: false
                        readonly property real badgeHorizontalPadding: ScreenTools.defaultFontPixelWidth * 0.9
                        readonly property real cameraIconOffsetX: -ScreenTools.defaultFontPixelWidth * 0.18
                        readonly property real cameraIconOffsetY: 0
                        readonly property real cameraControlExtraWidth: Screen.pixelDensity * 6
                        readonly property real cameraControlExtraHeight: Screen.pixelDensity * 2.5
                        readonly property string brakeParamName: "CP_DIST"
                        readonly property bool brakeParamControllerActive: !!activeVehicle && activeVehicle.parameterManager && activeVehicle.parameterManager.parametersReady
                        readonly property var brakeParamController: brakeParamControllerLoader.item ? brakeParamControllerLoader.item.controller : null
                        property Fact brakeParamFact: brakeParamController && brakeParamController.parameterExists(-1, brakeParamName) ? brakeParamController.getParameterFact(-1, brakeParamName, false) : null
                        readonly property bool brakeParamAvailable: brakeParamFact !== null
                        readonly property bool brakeEnabled: brakeParamAvailable && Number(brakeParamFact.rawValue) >= 0
                        readonly property color brakeActiveBackground: "#f5c84c"
                        readonly property color brakeInactiveBackground: Qt.rgba(0.34, 0.34, 0.34, 0.88)
                        readonly property color brakeActiveTextColor: "#1f1f1f"
                        readonly property color brakeInactiveTextColor: Qt.rgba(255, 255, 255, 0.48)
                        readonly property real brakeMinimumWidth: ScreenTools.defaultFontPixelWidth * 14.4
                        readonly property real brakeInnerMargin: ScreenTools.defaultFontPixelHeight * 0.34
                        readonly property real brakeLabelWidth: ScreenTools.defaultFontPixelWidth * 3.5
                        readonly property real badgeWidth: Math.max(
                            storageLabel.implicitWidth + badgeHorizontalPadding * 2 + ScreenTools.defaultFontPixelWidth * 0.3,
                            recStatusRow.implicitWidth + badgeHorizontalPadding * 2,
                            cameraControlRow.implicitWidth + badgeHorizontalPadding * 2 + cameraControlExtraWidth,
                            brakeMinimumWidth
                        )
                        visible: !!activeCamera
                        width: badgeWidth
                        height: badgeStack.implicitHeight

                        Loader {
                            id: brakeParamControllerLoader
                            active: cameraStorageBadge.brakeParamControllerActive
                            sourceComponent: brakeParamControllerComponent
                        }

                        Component {
                            id: brakeParamControllerComponent

                            Item {
                                property alias controller: brakeParamController

                                FactPanelController { id: brakeParamController }
                            }
                        }

                        Column {
                            id: badgeStack
                            anchors.right: parent.right
                            anchors.top: parent.top
                            spacing: ScreenTools.defaultFontPixelHeight * 0.3
                            width: cameraStorageBadge.badgeWidth

                            Rectangle {
                                id: storageBadgeBackground
                                width: cameraStorageBadge.badgeWidth
                                radius: ScreenTools.defaultFontPixelHeight * 0.45
                                color: Qt.rgba(0, 0, 0, 0.42)
                                border.width: 1
                                border.color: Qt.rgba(255, 255, 255, 0.28)
                                implicitHeight: storageLabel.implicitHeight + ScreenTools.defaultFontPixelHeight * 0.55

                                QGCLabel {
                                    id: storageLabel
                                    anchors.left: parent.left
                                    anchors.leftMargin: cameraStorageBadge.badgeHorizontalPadding
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: qsTr("空き容量: %1").arg(cameraStorageBadge.activeCamera ? cameraStorageBadge.activeCamera.storageFreeStr : "--")
                                    color: qgcPal.text
                                    font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.72
                                    font.bold: true
                                }
                            }

                            Rectangle {
                                id: recStatusBackground
                                width: cameraStorageBadge.badgeWidth
                                radius: ScreenTools.defaultFontPixelHeight * 0.45
                                color: Qt.rgba(0, 0, 0, 0.42)
                                border.width: 1
                                border.color: Qt.rgba(255, 255, 255, 0.28)
                                readonly property bool isRecording: !!cameraStorageBadge.activeVehicle && cameraStorageBadge.activeVehicle.recStatValue === 5
                                implicitHeight: recStatusColumn.implicitHeight + ScreenTools.defaultFontPixelHeight * 0.55

                                Column {
                                    id: recStatusColumn
                                    anchors.centerIn: parent
                                    spacing: ScreenTools.defaultFontPixelHeight * 0.12

                                    Row {
                                        id: recStatusRow
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        spacing: ScreenTools.defaultFontPixelWidth * 0.45

                                        QGCColoredImage {
                                            id: recStatusIcon
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: ScreenTools.defaultFontPixelHeight * 0.95
                                            height: width
                                            source: "/qmlimages/camera_video.svg"
                                            color: recStatCompactColor(cameraStorageBadge.activeVehicle ? cameraStorageBadge.activeVehicle.recStatValue : 0)
                                        }

                                        QGCLabel {
                                            id: recStatusLabel
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: recStatCompactText(cameraStorageBadge.activeVehicle ? cameraStorageBadge.activeVehicle.recStatValue : 0)
                                            color: recStatCompactColor(cameraStorageBadge.activeVehicle ? cameraStorageBadge.activeVehicle.recStatValue : 0)
                                            font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.72
                                            font.bold: true
                                        }
                                    }

                                    QGCLabel {
                                        id: recStatusElapsedLabel
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        visible: recStatusBackground.isRecording
                                        text: cameraStorageBadge.activeVehicle ? cameraStorageBadge.activeVehicle.recStatRecordingElapsedText : ""
                                        color: "#ff4d4f"
                                        font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.64
                                        font.bold: true
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: cameraStorageBadge.recStatusPopupVisible = !cameraStorageBadge.recStatusPopupVisible
                                }
                            }

                            Rectangle {
                                id: cameraControlBackground
                                width: cameraStorageBadge.badgeWidth
                                radius: ScreenTools.defaultFontPixelHeight * 0.45
                                color: Qt.rgba(0, 0, 0, 0.42)
                                border.width: 1
                                border.color: Qt.rgba(255, 255, 255, 0.28)
                                visible: cameraStorageBadge.activeCamera && cameraStorageBadge.activeCamera.capturesPhotos
                                implicitHeight: cameraControlRow.implicitHeight + ScreenTools.defaultFontPixelHeight * 0.45 + cameraStorageBadge.cameraControlExtraHeight

                                Row {
                                    id: cameraControlRow
                                    anchors.centerIn: parent
                                    spacing: ScreenTools.defaultFontPixelWidth * 1.2

                                    Rectangle {
                                        id: cameraIconContainer
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: ScreenTools.defaultFontPixelHeight * 1.45
                                        height: width
                                        radius: ScreenTools.defaultFontPixelHeight * 0.22
                                        color: Qt.rgba(0, 0, 0, 0)

                                        QGCColoredImage {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            anchors.horizontalCenterOffset: cameraStorageBadge.cameraIconOffsetX
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.verticalCenterOffset: cameraStorageBadge.cameraIconOffsetY
                                            width: parent.width * 0.74
                                            height: width
                                            source: "/qmlimages/camera_photo.svg"
                                            color: qgcPal.colorGreen
                                        }
                                    }

                                    Rectangle {
                                        id: shutterButtonOuter
                                        anchors.verticalCenter: parent.verticalCenter
                                        property bool clickPulseActive: false
                                        readonly property real innerButtonBaseSize: width * 0.74
                                        width: ScreenTools.defaultFontPixelHeight * 1.95
                                        height: width
                                        radius: width * 0.5
                                        color: Qt.rgba(0, 0, 0, 0)
                                        border.width: 2
                                        border.color: "#ffffff"

                                        Rectangle {
                                            id: shutterButtonInner
                                            anchors.centerIn: parent
                                            width: shutterButtonOuter.clickPulseActive ? shutterButtonOuter.innerButtonBaseSize * 0.82 : shutterButtonOuter.innerButtonBaseSize
                                            height: width
                                            radius: width * 0.5
                                            color: "#ffffff"

                                            Behavior on width {
                                                NumberAnimation {
                                                    duration: shutterButtonOuter.clickPulseActive ? 70 : 150
                                                    easing.type: shutterButtonOuter.clickPulseActive ? Easing.OutQuad : Easing.OutBack
                                                }
                                            }

                                            Behavior on height {
                                                NumberAnimation {
                                                    duration: shutterButtonOuter.clickPulseActive ? 70 : 150
                                                    easing.type: shutterButtonOuter.clickPulseActive ? Easing.OutQuad : Easing.OutBack
                                                }
                                            }
                                        }

                                        Timer {
                                            id: shutterButtonPulseTimer
                                            interval: 110
                                            repeat: false
                                            onTriggered: shutterButtonOuter.clickPulseActive = false
                                        }

                                        MouseArea {
                                            id: shutterButtonMouseArea
                                            anchors.fill: parent
                                            enabled: !!cameraStorageBadge.activeCamera
                                            onPressed: {
                                                shutterButtonOuter.clickPulseActive = true
                                                shutterButtonPulseTimer.restart()
                                            }
                                            onClicked: {
                                                cameraStorageBadge.activeCamera.setCameraModePhoto()
                                                if (cameraStorageBadge.activeCamera.photoCaptureStatus === MavlinkCameraControl.PHOTO_CAPTURE_INTERVAL_IN_PROGRESS) {
                                                    cameraStorageBadge.activeCamera.stopTakePhoto()
                                                } else {
                                                    cameraStorageBadge.activeCamera.takePhoto()
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                id: brakeStatusBackground
                                width: cameraStorageBadge.badgeWidth
                                radius: ScreenTools.defaultFontPixelHeight * 0.45
                                color: Qt.rgba(0, 0, 0, 0.42)
                                border.width: 1
                                border.color: Qt.rgba(255, 255, 255, 0.28)
                                visible: cameraControlBackground.visible
                                implicitHeight: storageLabel.implicitHeight + ScreenTools.defaultFontPixelHeight * 0.55

                                QGCLabel {
                                    id: brakeStatusLabel
                                    anchors.left: parent.left
                                    anchors.leftMargin: cameraStorageBadge.badgeHorizontalPadding
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: cameraStorageBadge.brakeLabelWidth
                                    text: qsTr("BRK")
                                    color: qgcPal.text
                                    font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.68
                                    font.bold: true
                                }

                                Item {
                                    id: brakeSegments
                                    anchors.left: brakeStatusLabel.right
                                    anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 0.75
                                    anchors.right: parent.right
                                    anchors.rightMargin: cameraStorageBadge.brakeInnerMargin
                                    anchors.top: parent.top
                                    anchors.topMargin: cameraStorageBadge.brakeInnerMargin
                                    anchors.bottom: parent.bottom
                                    anchors.bottomMargin: cameraStorageBadge.brakeInnerMargin

                                    Rectangle {
                                        id: brakeOnSegment
                                        anchors.left: parent.left
                                        anchors.right: parent.horizontalCenter
                                        anchors.top: parent.top
                                        anchors.bottom: parent.bottom
                                        readonly property bool selected: cameraStorageBadge.brakeParamAvailable && cameraStorageBadge.brakeEnabled
                                        radius: ScreenTools.defaultFontPixelHeight * 0.2
                                        color: selected ? cameraStorageBadge.brakeActiveBackground : cameraStorageBadge.brakeInactiveBackground

                                        QGCLabel {
                                            anchors.centerIn: parent
                                            text: qsTr("ON")
                                            color: brakeOnSegment.selected ? cameraStorageBadge.brakeActiveTextColor : cameraStorageBadge.brakeInactiveTextColor
                                            font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.64
                                            font.bold: brakeOnSegment.selected
                                        }
                                    }

                                    QGCLabel {
                                        id: brakeSeparator
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: qsTr("｜")
                                        color: Qt.rgba(255, 255, 255, 0.58)
                                        font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.66
                                        font.bold: true
                                        z: 1
                                    }

                                    Rectangle {
                                        id: brakeOffSegment
                                        anchors.left: parent.horizontalCenter
                                        anchors.right: parent.right
                                        anchors.top: parent.top
                                        anchors.bottom: parent.bottom
                                        readonly property bool selected: cameraStorageBadge.brakeParamAvailable && !cameraStorageBadge.brakeEnabled
                                        radius: ScreenTools.defaultFontPixelHeight * 0.2
                                        color: selected ? cameraStorageBadge.brakeActiveBackground : cameraStorageBadge.brakeInactiveBackground

                                        QGCLabel {
                                            anchors.centerIn: parent
                                            text: qsTr("OFF")
                                            color: brakeOffSegment.selected ? cameraStorageBadge.brakeActiveTextColor : cameraStorageBadge.brakeInactiveTextColor
                                            font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.64
                                            font.bold: brakeOffSegment.selected
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            id: recStatusPopup
                            z: 21
                            visible: cameraStorageBadge.recStatusPopupVisible
                            x: recStatusBackground.x - width - ScreenTools.defaultFontPixelWidth * 0.6
                            y: recStatusBackground.y + (recStatusBackground.height - height) / 2
                            readonly property real horizontalPadding: ScreenTools.defaultFontPixelHeight * 0.38
                            readonly property real verticalPadding: ScreenTools.defaultFontPixelHeight * 0.3
                            width: Math.min(hudLayer.width * 0.34, recStatusPopupText.implicitWidth + horizontalPadding * 2)
                            height: recStatusPopupText.implicitHeight + verticalPadding * 2
                            radius: ScreenTools.defaultFontPixelHeight * 0.45
                            color: Qt.rgba(0, 0, 0, 0.58)
                            border.width: 1
                            border.color: recStatCompactColor(cameraStorageBadge.activeVehicle ? cameraStorageBadge.activeVehicle.recStatValue : 0)

                            QGCLabel {
                                id: recStatusPopupText
                                anchors.centerIn: parent
                                width: parent.width - recStatusPopup.horizontalPadding * 2
                                text: recStatDisplayText(cameraStorageBadge.activeVehicle ? cameraStorageBadge.activeVehicle.recStatValue : 0)
                                color: qgcPal.text
                                font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.82
                                font.bold: true
                                wrapMode: Text.WrapAnywhere
                                horizontalAlignment: Text.AlignRight
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        z: 19
                        visible: cameraStorageBadge.visible && cameraStorageBadge.recStatusPopupVisible
                        enabled: visible
                        onClicked: cameraStorageBadge.recStatusPopupVisible = false
                    }

                    // ToF distance
                    ToFSensor {
                        id: tofSensor
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: ScreenTools.defaultFontPixelHeight * 1.5
                        vehicle: mainWindow.activeVehicle
                    }

                }

                // PiP window
                VideoPiP {
                    id: pipVideo
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: ScreenTools.defaultFontPixelHeight * 1.1
                    anchors.rightMargin: ScreenTools.defaultFontPixelWidth * 1.8 + _pipLeftShift
                    anchors.bottomMargin: Math.max(0, ScreenTools.defaultFontPixelHeight * 1.1 - _pipDownShift)
                    width: _pipWidth
                    height: _pipHeight
                    url: _hasVideoHandler ? (_displaySwapped ? videoHandler.mainUrl : videoHandler.subUrl) : ""
                    receiver: _hasVideoHandler ? (_displaySwapped ? videoHandler.mainReceiver : videoHandler.subReceiver) : null
                    label: _displaySwapped ? qsTr("Main") : qsTr("PiP")
                    z: 5

                    onSwapRequested: customApp.swapCamera()
                }

                MouseArea {
                    anchors.fill: parent
                    visible: showCustomSettingsPanel
                    enabled: visible
                    z: 899
                    onClicked: closeCustomSettingsPanel()
                }

                Item {
                    id: customSettingsContainer
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.rightMargin: ScreenTools.defaultFontPixelWidth * 4
                    anchors.bottomMargin: _pipVisible
                                          ? _pipHeight + ScreenTools.defaultFontPixelHeight * 2.0
                                          : ScreenTools.defaultFontPixelHeight * 1.5
                    width: Math.min(mainWindow.width - ScreenTools.defaultFontPixelWidth * 4,
                                    ScreenTools.defaultFontPixelWidth * 46)
                    height: settingsToggleButton.height + (showCustomSettingsPanel ? settingsPanel.height + panelSpacing : 0)
                    z: 900

                    property real panelSpacing: ScreenTools.defaultFontPixelHeight * 0.7

                    QGCButton {
                        id: settingsToggleButton
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        text: qsTr("設定")
                        width: ScreenTools.defaultFontPixelWidth * 14
                        height: ScreenTools.defaultFontPixelHeight * 2.4
                        padding: 0
                        onClicked: {
                            showCustomSettingsPanel = !showCustomSettingsPanel
                            if (!showCustomSettingsPanel) {
                                closeCustomSettingsPanel()
                            } else if (_hasVideoHandler) {
                                pipUrlInput.text = videoHandler.subUrl
                            }
                        }
                    }

                    Rectangle {
                        id: settingsPanel
                        visible: showCustomSettingsPanel
                        anchors.right: parent.right
                        anchors.bottom: settingsToggleButton.top
                        anchors.bottomMargin: customSettingsContainer.panelSpacing
                        width: parent.width
                        height: settingsPanelContent.implicitHeight + ScreenTools.defaultFontPixelHeight
                        radius: 8
                        color: "#202020"
                        border.color: "#4a4a4a"
                        border.width: 1
                        opacity: 0.95
                        z: 999

                        ColumnLayout {
                            id: settingsPanelContent
                            anchors.fill: parent
                            anchors.margins: ScreenTools.defaultFontPixelHeight * 0.55
                            spacing: ScreenTools.defaultFontPixelHeight * 0.35

                            RowLayout {
                                Layout.fillWidth: true

                                QGCLabel {
                                    text: qsTr("設定")
                                    color: qgcPal.text
                                    font.bold: true
                                    font.pointSize: ScreenTools.defaultFontPointSize
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                Rectangle {
                                    color: "#343434"
                                    radius: 5
                                    border.color: "#5a5a5a"
                                    border.width: 1
                                    Layout.preferredWidth: ScreenTools.defaultFontPixelHeight * 1.75
                                    Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.75
                                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                                    QGCLabel {
                                        anchors.fill: parent
                                        text: qsTr("×")
                                        color: qgcPal.text
                                        font.bold: true
                                        font.pixelSize: ScreenTools.defaultFontPixelHeight * 1.05
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: closeCustomSettingsPanel()
                                    }
                                }
                            }

                            Rectangle {
                                color: "#3d3d3d"
                                height: 1
                                Layout.fillWidth: true
                            }

                            Rectangle {
                                color: "#262626"
                                radius: 6
                                border.color: "#555555"
                                border.width: 1
                                Layout.fillWidth: true
                                Layout.preferredHeight: Math.max(primaryLinkColumn.implicitHeight + ScreenTools.defaultFontPixelHeight * 1.25,
                                                                 ScreenTools.defaultFontPixelHeight * 4.2)

                                ColumnLayout {
                                    id: primaryLinkColumn
                                    anchors.fill: parent
                                    anchors.margins: ScreenTools.defaultFontPixelHeight * 0.65
                                    spacing: ScreenTools.defaultFontPixelHeight * 0.25

                                    QGCLabel {
                                        text: qsTr("通信リンク")
                                        color: "#b0bec5"
                                        font.pointSize: ScreenTools.defaultFontPointSize
                                        Layout.fillWidth: true
                                    }

                                    QGCLabel {
                                        text: customApp.primaryLinkEndpoint && customApp.primaryLinkEndpoint.length > 0
                                              ? customApp.primaryLinkEndpoint
                                              : qsTr("未接続")
                                        color: customApp.primaryLinkEndpoint && customApp.primaryLinkEndpoint.length > 0
                                               ? qgcPal.text
                                               : "#ffcc80"
                                        font.bold: true
                                        font.pointSize: ScreenTools.mediumFontPointSize
                                        wrapMode: QGCLabel.WrapAnywhere
                                        Layout.fillWidth: true
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: ScreenTools.defaultFontPixelWidth

                                QGCButton {
                                    text: showPipUrlPanel ? qsTr("RTSP設定を閉じる") : qsTr("RTSP設定")
                                    enabled: _hasVideoHandler
                                    Layout.fillWidth: true
                                    onClicked: {
                                        showPipUrlPanel = !showPipUrlPanel
                                        if (showPipUrlPanel && _hasVideoHandler) {
                                            pipUrlInput.text = videoHandler.subUrl
                                        }
                                    }
                                }

                                QGCButton {
                                    text: qsTr("PiPをクリア")
                                    visible: _hasVideoHandler && videoHandler.subUrl !== ""
                                    Layout.fillWidth: true
                                    onClicked: {
                                        videoHandler.subUrl = ""
                                        pipUrlInput.text = ""
                                        showPipUrlPanel = false
                                    }
                                }
                            }

                            ColumnLayout {
                                visible: showPipUrlPanel
                                Layout.fillWidth: true
                                spacing: ScreenTools.defaultFontPixelHeight * 0.45

                                QGCLabel {
                                    text: qsTr("PiP URL")
                                    color: "#b0bec5"
                                    Layout.fillWidth: true
                                }

                                TextField {
                                    id: pipUrlInput
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 2.5
                                    text: _hasVideoHandler ? videoHandler.subUrl : ""
                                    placeholderText: qsTr("rtsp://...")
                                    color: qgcPal.text
                                    selectByMouse: true
                                    onAccepted: {
                                        if (_hasVideoHandler) {
                                            videoHandler.subUrl = text
                                            showPipUrlPanel = false
                                        }
                                    }
                                    background: Rectangle {
                                        radius: 6
                                        color: "#222222"
                                        border.color: "#555555"
                                    }
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: ScreenTools.defaultFontPixelWidth

                                    QGCButton {
                                        text: qsTr("適用")
                                        Layout.fillWidth: true
                                        onClicked: {
                                            if (_hasVideoHandler) {
                                                videoHandler.subUrl = pipUrlInput.text
                                            }
                                            showPipUrlPanel = false
                                        }
                                    }

                                    QGCButton {
                                        text: qsTr("キャンセル")
                                        Layout.fillWidth: true
                                        onClicked: {
                                            if (_hasVideoHandler) {
                                                pipUrlInput.text = videoHandler.subUrl
                                            }
                                            showPipUrlPanel = false
                                        }
                                    }
                                }
                            }

                            QGCButton {
                                text: customApp.safeShutdownPending ? qsTr("確認中...") : qsTr("VOXLをシャットダウン")
                                enabled: activeVehicle !== null && !customApp.safeShutdownPending
                                Layout.fillWidth: true
                                onClicked: {
                                    showMessageDialog(
                                        qsTr("VOXLシャットダウン"),
                                        qsTr("シャットダウンします。飛行中や作業中でないことを確認してください。"),
                                        Dialog.Ok | Dialog.Cancel,
                                        function() { customApp.requestSafeShutdown() }
                                    )
                                }
                            }

                            Rectangle {
                                visible: customApp.safeShutdownStatus && customApp.safeShutdownStatus.length > 0
                                color: "#202020"
                                radius: 6
                                border.width: 1
                                border.color: customApp.safeShutdownStatusError
                                              ? "#ff8a80"
                                              : (customApp.safeShutdownPending ? "#ffd166" : "#8bd49c")
                                Layout.fillWidth: true
                                Layout.preferredHeight: safeShutdownStatusLabel.implicitHeight + ScreenTools.defaultFontPixelHeight

                                QGCLabel {
                                    id: safeShutdownStatusLabel
                                    anchors.fill: parent
                                    anchors.margins: ScreenTools.defaultFontPixelHeight * 0.5
                                    text: customApp.safeShutdownStatus
                                    color: customApp.safeShutdownStatusError
                                           ? "#ff8a80"
                                           : (customApp.safeShutdownPending ? "#ffd166" : "#8bd49c")
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    wrapMode: QGCLabel.WordWrap
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }
                    }
                }

            }
        }
    }
