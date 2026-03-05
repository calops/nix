import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import "../services"
import "../components"

Scope {
    id: root

    PanelWindow {
        id: runnerWindow
        // Show on the first screen
        screen: Quickshell.screens[0]

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        
        // This is a full-screen transparent overlay
        color: "transparent"
        visible: AnyrunService.runnerVisible || runnerContainer.opacity > 0
        
        // Don't reserve space for other windows
        exclusionMode: ExclusionMode.Ignore

        // Request keyboard focus from the compositor
        focusable: true
        WlrLayershell.keyboardFocus: WlrLayershell.Exclusive

        onVisibleChanged: {
            if (visible) {
                searchInput.forceActiveFocus();
                searchInput.text = "";
                AnyrunService.query("");
            }
        }

        // The background click-to-dismiss overlay
        MouseArea {
            anchors.fill: parent
            onClicked: AnyrunService.toggleRunner(false)
        }

        // Animated blur mask region for the glassmorphic effect
        property var blurRegion
        property var mask

        function updateWaylandEffects() {
            if (!runnerWindow.visible) return;
            
            var blurStr = "import Quickshell; import Quickshell.Wayland; Region {\n" +
                          "    Region { item: glassBackground; radius: 10 }\n" +
                          "}";
            if (runnerWindow.BackgroundEffect.blurRegion) runnerWindow.BackgroundEffect.blurRegion.destroy();
            runnerWindow.BackgroundEffect.blurRegion = Qt.createQmlObject(blurStr, runnerWindow, "runnerBlurRegion");
            
            var maskStr = "import Quickshell; import Quickshell.Wayland; Region {\n" +
                          "    Region { item: glassBackground; radius: 10 }\n" +
                          "}";
            if (runnerWindow.mask) runnerWindow.mask.destroy();
            runnerWindow.mask = Qt.createQmlObject(maskStr, runnerWindow, "runnerMask");
        }

        Item {
            anchors.fill: parent
            focus: true
            
            onActiveFocusChanged: {
                if (!activeFocus && runnerWindow.visible) {
                    AnyrunService.toggleRunner(false);
                }
            }

            Item {
                id: runnerContainer
                opacity: AnyrunService.runnerVisible ? 1.0 : 0.0
                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.animationDurationFast
                        easing.type: Easing.InOutQuad
                    }
                }
                width: 600
                // Fixed large height to avoid surface reconfiguration
                height: 1200
                // Stay stationary at ~20% of screen height
                y: parent.height * 0.2
                anchors.horizontalCenter: parent.horizontalCenter
                
                // Track the "visible" height for the background and clipping
                // Base: 15 (top margin) + 44 (search bar) + 15 (bottom margin) = 74
                // Divider gap: 8 (spacing) + 1 (line) + 8 (spacing) = 17
                // Empty state gap: 8 (spacing) + 60 (text) = 68
                property real contentHeight: 74 
                    + (AnyrunService.runnerVisible && AnyrunService.resultsModel.count > 0 ? resultsList.contentHeight + 17 : 0)
                    + (AnyrunService.runnerVisible && AnyrunService.resultsModel.count === 0 && searchInput.text !== "" ? 68 : 0)
                
                property real targetBackgroundHeight: 80
                
                Timer {
                    id: heightDebounce
                    interval: 100
                    onTriggered: runnerContainer.targetBackgroundHeight = runnerContainer.contentHeight
                }
                
                onContentHeightChanged: {
                    if (contentHeight > targetBackgroundHeight || !AnyrunService.runnerVisible) {
                        targetBackgroundHeight = contentHeight;
                        heightDebounce.stop();
                    } else {
                        heightDebounce.restart();
                    }
                }
                
                // Glassmorphic background follows the target height
                ShaderEffect {
                    id: glassBackground
                    width: parent.width
                    height: runnerContainer.targetBackgroundHeight
                    
                    Behavior on height {
                        NumberAnimation {
                            duration: Theme.animationDuration
                            easing.type: Easing.OutQuad
                            onRunningChanged: if (!running) runnerWindow.updateWaylandEffects();
                        }
                    }
                    
                    onHeightChanged: runnerWindow.updateWaylandEffects();
                    
                    property real radius: 10
                    property color baseColor: Colors.alpha(Theme.backdropTint, Theme.backdropOpacity)
                    property real uWidth: width
                    property real uHeight: height

                    fragmentShader: Qt.resolvedUrl("../components/shaders/glass.frag.qsb")

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowColor: "black"
                        shadowBlur: 1.0
                        shadowOpacity: 0.5
                        shadowVerticalOffset: 2
                        shadowHorizontalOffset: 2
                    }
                }
                
                Item {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: glassBackground.height
                    clip: true
                    
                    ColumnLayout {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 15
                    // Fixed height to avoid jitter
                    height: 1200
                    clip: true
                    spacing: 8
                    
                    // Search field container
                    Rectangle {
                        id: searchField
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        radius: 12
                        color: Colors.alpha("#ffffff", 0.08)
                        border.width: 1
                        border.color: searchInput.activeFocus ? Colors.alpha("#ffffff", 0.25) : Colors.alpha("#ffffff", 0.15)
                        
                        Behavior on border.color { ColorAnimation { duration: 150 } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 12
                            
                            StyledText {
                                text: ""
                                font.pixelSize: 18
                                color: searchInput.text !== "" ? Colors.palette.text : Colors.palette.subtext0
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                            
                            TextInput {
                                id: searchInput
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                verticalAlignment: TextInput.AlignVCenter
                                font.pixelSize: 18
                                color: Colors.palette.text
                                selectionColor: Colors.palette.surface2
                                selectedTextColor: Colors.palette.text
                                clip: true
                                
                                StyledText {
                                    text: "Search anything..."
                                    font.pixelSize: 18
                                    color: Colors.palette.overlay0
                                    visible: searchInput.text === ""
                                    anchors.fill: parent
                                    verticalAlignment: Text.AlignVCenter
                                    opacity: 0.5
                                }

                                onTextChanged: {
                                    AnyrunService.query(text);
                                    resultsList.currentIndex = 0;
                                }
                                
                                Keys.onDownPressed: {
                                    if (resultsList.count > 0) {
                                        resultsList.currentIndex = (resultsList.currentIndex + 1) % resultsList.count;
                                    }
                                }
                                Keys.onUpPressed: {
                                    if (resultsList.count > 0) {
                                        resultsList.currentIndex = (resultsList.currentIndex - 1 + resultsList.count) % resultsList.count;
                                    }
                                }
                                Keys.onReturnPressed: {
                                    if (resultsList.count > 0 && resultsList.currentIndex >= 0) {
                                        const match = AnyrunService.resultsModel.get(resultsList.currentIndex);
                                        AnyrunService.execute(match.rawPlugin, match.rawMatch);
                                    }
                                }
                                Keys.onEscapePressed: {
                                    AnyrunService.toggleRunner(false);
                                }
                                Keys.onTabPressed: {
                                    if (resultsList.count > 0) {
                                        resultsList.currentIndex = (resultsList.currentIndex + 1) % resultsList.count;
                                    }
                                }
                                Keys.onBacktabPressed: {
                                    if (resultsList.count > 0) {
                                        resultsList.currentIndex = (resultsList.currentIndex - 1 + resultsList.count) % resultsList.count;
                                    }
                                }
                            }

                            StyledText {
                                text: ""
                                font.pixelSize: 14
                                color: Colors.palette.subtext0
                                visible: searchInput.text !== ""
                                
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        searchInput.text = "";
                                        searchInput.forceActiveFocus();
                                    }
                                }
                            }
                        }
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Colors.alpha("#ffffff", 0.1)
                        opacity: AnyrunService.resultsModel.count > 0 ? 1.0 : 0.0
                        Behavior on opacity { NumberAnimation { duration: 150 } }
                        visible: opacity > 0
                        // Match children margins
                        Layout.leftMargin: 12
                        Layout.rightMargin: 12
                    }

                    // Empty state
                    StyledText {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 60
                        text: "No results matched your search"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: Colors.palette.subtext0
                        visible: searchInput.text !== "" && AnyrunService.resultsModel.count === 0
                        font.pixelSize: 14
                        font.italic: true
                        opacity: 0.8
                    }
                    
                    ListView {
                        id: resultsList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        model: AnyrunService.resultsModel
                        clip: true
                        interactive: false
                        spacing: 4
                        
                        add: Transition {
                            NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: 150 }
                            NumberAnimation { property: "scale"; from: 0.8; to: 1.0; duration: 150; easing.type: Easing.OutBack }
                        }
                        
                        remove: Transition {
                            NumberAnimation { property: "opacity"; to: 0; duration: 150 }
                            NumberAnimation { property: "scale"; to: 0.8; duration: 150; easing.type: Easing.InBack }
                        }
                        
                        displaced: Transition {
                            NumberAnimation { properties: "x,y"; duration: 150; easing.type: Easing.OutQuad }
                        }
                        
                        addDisplaced: Transition {
                            NumberAnimation { properties: "x,y"; duration: 150; easing.type: Easing.OutQuad }
                        }
                        
                        moveDisplaced: Transition {
                            NumberAnimation { properties: "x,y"; duration: 150; easing.type: Easing.OutQuad }
                        }
                        
                        move: Transition {
                            NumberAnimation { properties: "x,y"; duration: 150; easing.type: Easing.OutQuad }
                        }
                        
                        delegate: Item {
                            id: delegateRoot
                            width: ListView.view.width
                            height: 48
                            
                            Rectangle {
                                id: delegateBg
                                anchors.fill: parent
                                radius: 8
                                
                                property bool isHovered: mouseArea.containsMouse
                                property bool isActive: delegateRoot.ListView.isCurrentItem
                                
                                // Glass highlights
                                color: Colors.alpha("#ffffff", isActive ? 0.2 : (isHovered ? 0.22 : 0.08))
                                
                                Behavior on color {
                                    ColorAnimation { duration: Theme.animationDurationFast }
                                }
                                
                                // Subtle white border
                                Rectangle {
                                    anchors.fill: parent
                                    radius: parent.radius
                                    color: "transparent"
                                    border.width: 1
                                    border.color: delegateBg.isActive ? Colors.alpha("#ffffff", 0.20) : (delegateBg.isHovered ? Colors.alpha("#ffffff", 0.15) : "transparent")
                                    
                                    Behavior on border.color {
                                        ColorAnimation { duration: Theme.animationDurationFast }
                                    }
                                }
                                
                                MouseArea {
                                    id: mouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: resultsList.currentIndex = index
                                    onClicked: {
                                        resultsList.currentIndex = index;
                                        const match = AnyrunService.resultsModel.get(index);
                                        AnyrunService.execute(match.rawPlugin, match.rawMatch);
                                    }
                                }
                                
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    spacing: 12
                                    
                                    Image {
                                        source: model.iconPath || ""
                                        Layout.preferredWidth: 24
                                        Layout.preferredHeight: 24
                                        sourceSize: Qt.size(24, 24)
                                        fillMode: Image.PreserveAspectFit
                                        visible: source != ""
                                    }
                                    
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2
                                        
                                        StyledText {
                                            Layout.fillWidth: true
                                            text: (model.title || "").replace(/&/g, '')
                                            font.pixelSize: 14
                                            color: Colors.palette.text
                                            elide: Text.ElideRight
                                        }
                                        
                                        StyledText {
                                            Layout.fillWidth: true
                                            text: (model.description || "").replace(/&/g, '')
                                            font.pixelSize: 11
                                            color: Colors.palette.subtext0
                                            visible: text !== ""
                                            elide: Text.ElideRight
                                        }
                                    }
                                    
                                    StyledText {
                                        text: model.pluginName
                                        font.pixelSize: 10
                                        color: Colors.palette.overlay0
                                    }
                                }
                            }
                        }
                    }
                    
                    // Spacer to push everything to the top of the ColumnLayout
                    Item {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                    }
                }
            }
            }
        }
    }
}
