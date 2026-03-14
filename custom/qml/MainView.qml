import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.Controllers
import QGroundControl.Palette
import QGroundControl.ScreenTools
import QGroundControl.FlightDisplay
import QGroundControl.FlightMap
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
    property bool showPipAddPanel: false
    readonly property bool _hasVideoHandler: typeof videoHandler !== "undefined" && videoHandler !== null
    readonly property bool _displaySwapped: _hasVideoHandler ? videoHandler.displaySwapped : false
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
    function recStatColor(recStatValue) {
        switch (recStatValue) {
        case 0:
        case 1:
        case 2:
        case 3:
            return "#f5c542"
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
            return qsTr("アームを待機しています")
        case 4:
            return qsTr("録画が可能です")
        case 5:
            return qsTr("録画中")
        case 6:
            return qsTr("空き容量が不足しています")
        case 7:
            return qsTr("ストレージ確認に失敗しました")
        case 8:
            return qsTr("録画不可")
        case 0:
        default:
            return qsTr("録画状態がわかりません")
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

    Component {
        id: mainPageComponent
        Rectangle {
            anchors.fill: parent
            color: qgcPal.window

            property bool _videoSurfacesBound: false
            readonly property real _hudEdgeInset: ScreenTools.defaultFontPixelHeight * 1.5
            readonly property real _compassWidgetSize: (ScreenTools.defaultFontPixelHeight * 5 + 80) * 0.7
            readonly property real _attitudeWidgetSize: _compassWidgetSize * 0.95
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
                        spacing: ScreenTools.defaultFontPixelWidth * 3
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.margins: _hudEdgeInset
                        anchors.leftMargin: _hudEdgeInset
                        anchors.topMargin: ScreenTools.defaultFontPixelHeight * 1.2

                        IntegratedCompassAttitude {
                            id: compass
                            vehicle: mainWindow.activeVehicle
                            width: _compassWidgetSize
                            height: _compassWidgetSize
                            compassBorder: 1
                            compassRadius: width / 2 - 6
                            attitudeSize: ScreenTools.defaultFontPixelWidth * 0.8
                            attitudeSpacing: attitudeSize * 0.6
                        }
                    }

                    ReversedAttitudeWidget {
                        id: attitudeIndicator
                        anchors.left: parent.left
                        anchors.bottom: parent.bottom
                        anchors.leftMargin: _hudEdgeInset
                        anchors.bottomMargin: ScreenTools.defaultFontPixelHeight * 1.4
                        size: _attitudeWidgetSize
                        vehicle: mainWindow.activeVehicle
                        showHeading: false
                        visible: !!mainWindow.activeVehicle
                    }

                    // Default photo/video control widget (top-right)
                    Item {
                        id: recStatBadge
                        anchors.right: photoVideoControl.left
                        anchors.top: photoVideoControl.top
                        anchors.rightMargin: ScreenTools.defaultFontPixelWidth * 1.1
                        z: 20
                        width: recStatSummary.implicitWidth
                        height: recStatSummary.implicitHeight
                        visible: photoVideoControl.visible && !!mainWindow.activeVehicle

                        readonly property int recStatValue: mainWindow.activeVehicle ? mainWindow.activeVehicle.recStatValue : 0
                        property bool popupVisible: false

                        Rectangle {
                            id: recStatSummary
                            anchors.fill: parent
                            radius: ScreenTools.defaultFontPixelHeight * 0.45
                            color: Qt.rgba(0, 0, 0, 0.42)
                            border.width: 1
                            border.color: mainWindow.recStatColor(recStatBadge.recStatValue)
                            implicitWidth: recStatSummaryRow.implicitWidth + ScreenTools.defaultFontPixelWidth * 1.6
                            implicitHeight: recStatSummaryRow.implicitHeight + ScreenTools.defaultFontPixelHeight * 0.55

                            Row {
                                id: recStatSummaryRow
                                anchors.centerIn: parent
                                spacing: ScreenTools.defaultFontPixelWidth * 0.5

                                QGCColoredImage {
                                    id: recStatVideoIcon
                                    width: ScreenTools.defaultFontPixelHeight * 1.05
                                    height: width
                                    source: "/qmlimages/camera_video.svg"
                                    color: mainWindow.recStatColor(recStatBadge.recStatValue)
                                }

                                QGCLabel {
                                    text: qsTr("REC STAT")
                                    color: mainWindow.recStatColor(recStatBadge.recStatValue)
                                    font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.72
                                    font.bold: true
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: recStatBadge.popupVisible = !recStatBadge.popupVisible
                            }
                        }

                        Rectangle {
                            id: recStatPopup
                            z: 19
                            visible: recStatBadge.popupVisible
                            x: Math.min(0, recStatBadge.width - width)
                            y: recStatBadge.height + ScreenTools.defaultFontPixelHeight * 0.35
                            readonly property real horizontalPadding: ScreenTools.defaultFontPixelHeight * 0.32
                            readonly property real verticalPadding: ScreenTools.defaultFontPixelHeight * 0.32
                            width: Math.min(hudLayer.width * 0.34, recStatPopupText.implicitWidth + horizontalPadding * 2)
                            height: recStatPopupText.implicitHeight + ScreenTools.defaultFontPixelHeight * 0.95
                            radius: ScreenTools.defaultFontPixelHeight * 0.45
                            color: Qt.rgba(0, 0, 0, 0.58)
                            border.width: 1
                            border.color: mainWindow.recStatColor(recStatBadge.recStatValue)

                            QGCLabel {
                                id: recStatPopupText
                                anchors.top: parent.top
                                anchors.right: parent.right
                                anchors.topMargin: recStatPopup.verticalPadding
                                anchors.rightMargin: recStatPopup.horizontalPadding
                                width: parent.width - recStatPopup.horizontalPadding * 2
                                text: mainWindow.recStatDisplayText(recStatBadge.recStatValue)
                                color: qgcPal.text
                                font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.86
                                font.bold: true
                                wrapMode: Text.WrapAnywhere
                                horizontalAlignment: Text.AlignRight
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        z: 19
                        visible: recStatBadge.popupVisible
                        enabled: visible
                        onClicked: recStatBadge.popupVisible = false
                    }

                    PhotoVideoControl {
                        id: photoVideoControl
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: ScreenTools.defaultFontPixelHeight * 1.5
                        scale: 0.9
                        transformOrigin: Item.TopRight
                        visible: globals.activeVehicle && globals.activeVehicle.cameraManager
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

                // PiP非表示時の追加ボタン＋URL入力パネル
                Item {
                    id: pipAddContainer
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: ScreenTools.defaultFontPixelHeight * 1.5
                    anchors.rightMargin: ScreenTools.defaultFontPixelWidth * 8
                    visible: _hasVideoHandler && videoHandler.subUrl === ""
                    width: 340
                    // Sub URLのラベル/入力欄を入力欄2.5個分だけ下げる
                    property real subUrlInputHeight: ScreenTools.defaultFontPixelHeight * 2.5
                    property real subUrlDropHeight: subUrlInputHeight * 2.5
                    property real subUrlVerticalShift: ScreenTools.defaultFontPixelHeight * 0.5
                    property real panelBottomPadding: ScreenTools.defaultFontPixelHeight * 0.75
                    height: showPipAddPanel
                            ? pipAddPanel.height + pipAddPanel.anchors.bottomMargin + pipButtonRow.height + pipButtonRow.anchors.bottomMargin
                            : pipButtonRow.height + pipButtonRow.anchors.bottomMargin
                    z: 900

                    // 入力パネル背景（開いている間のみ表示）
                    Rectangle {
                        anchors.fill: parent
                        radius: 12
                        visible: showPipAddPanel
                        color: "#202020"
                        border.color: "#4a4a4a"
                        border.width: 1
                        opacity: 0.9
                        z: 0
                    }

                    Row {
                        id: pipButtonRow
                        property real buttonSizeScale: 0.55   // 少しだけ縮小
                        property real buttonFontScale: 0.6    // テキストサイズは従来のまま
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: ScreenTools.defaultFontPixelHeight * 0.8
                        anchors.rightMargin: ScreenTools.defaultFontPixelWidth * 4
                        spacing: ScreenTools.defaultFontPixelWidth * 2.5

                        QGCButton {
                            id: pipConfirmButton
                            text: qsTr("決定")
                            width: ScreenTools.defaultFontPixelWidth * 16 * pipButtonRow.buttonSizeScale
                            height: ScreenTools.defaultFontPixelHeight * 3.2 * pipButtonRow.buttonSizeScale
                            font.pointSize: ScreenTools.mediumFontPointSize * pipButtonRow.buttonFontScale * 1.1
                            visible: showPipAddPanel
                            padding: 0
                            contentItem: Text {
                                text: pipConfirmButton.text
                                anchors.centerIn: parent
                                color: pipConfirmButton.enabled ? qgcPal.text : qgcPal.buttonDisabledText
                                font: pipConfirmButton.font
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                if (_hasVideoHandler) {
                                    videoHandler.subUrl = subUrlInput.text
                                }
                                showPipAddPanel = false
                            }
                        }

                        QGCButton {
                            id: pipAddButton
                            text: qsTr("PiP追加")
                            width: ScreenTools.defaultFontPixelWidth * 16 * pipButtonRow.buttonSizeScale
                            height: ScreenTools.defaultFontPixelHeight * 3.2 * pipButtonRow.buttonSizeScale
                            font.pointSize: ScreenTools.mediumFontPointSize * pipButtonRow.buttonFontScale * 1.1
                            padding: 0
                            contentItem: Text {
                                text: pipAddButton.text
                                anchors.centerIn: parent
                                color: pipAddButton.enabled ? qgcPal.text : qgcPal.buttonDisabledText
                                font: pipAddButton.font
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: showPipAddPanel = !showPipAddPanel
                        }
                    }

                    Rectangle {
                        id: pipAddPanel
                        visible: showPipAddPanel
                        anchors.right: parent.right
                        anchors.bottom: pipButtonRow.top
                        anchors.bottomMargin: ScreenTools.defaultFontPixelHeight * 5 - pipAddContainer.subUrlDropHeight
                        width: 320
                        height: pipAddContent.implicitHeight + pipAddContent.anchors.topMargin + pipAddContainer.panelBottomPadding
                        radius: 10
                        color: "transparent"
                        border.color: "transparent"
                        z: 999
                        onVisibleChanged: {
                            if (!visible && _hasVideoHandler) {
                                // パネルを閉じるタイミングでも保存
                                videoHandler.subUrl = subUrlInput.text
                            }
                        }

                        ColumnLayout {
                            id: pipAddContent
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 14
                            anchors.topMargin: pipAddContainer.subUrlVerticalShift + 14
                            spacing: 8

                            QGCLabel {
                                text: qsTr("Sub URL")
                                color: qgcPal.text
                                Layout.fillWidth: true
                            }
                            TextField {
                                id: subUrlInput
                                Layout.fillWidth: true
                                Layout.preferredHeight: pipAddContainer.subUrlInputHeight
                                text: _hasVideoHandler ? videoHandler.subUrl : ""
                                placeholderText: qsTr("rtsp://...")
                                color: qgcPal.text
                                onAccepted: {
                                    if (_hasVideoHandler) {
                                        videoHandler.subUrl = text
                                    }
                                }
                                onEditingFinished: {
                                    if (_hasVideoHandler) {
                                        videoHandler.subUrl = text
                                    }
                                }
                                background: Rectangle {
                                    radius: 6
                                    color: "#222222"
                                    border.color: "#555555"
                                }
                            }

                            // 決定ボタンとの間隔を確保
                            Item { Layout.fillWidth: true; Layout.preferredHeight: ScreenTools.defaultFontPixelHeight }

                            // 下側に少し余白を確保（背景の縦サイズを抑えつつタップ余白を確保）
                            Item { Layout.fillWidth: true; Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.25 }
                        }
                    }
                }

            }
        }
    }
