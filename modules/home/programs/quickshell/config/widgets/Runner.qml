pragma Singleton
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import "../services"
import "../components"

Singleton {
    id: root

    property bool runnerVisible: false

    function toggleRunner(requestedState = !runnerVisible) {
        runnerVisible = requestedState;
        if (!runnerVisible)
            AnyrunService.clear();
    }

    PanelWindow {
        id: runnerWindow
        screen: Quickshell.screens[0]

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        color: "transparent"
        // Keep visible while the backdrop is still fading out
        visible: root.runnerVisible || runnerContainer.backdropOpacity > 0.01

        exclusionMode: ExclusionMode.Ignore

        focusable: true
        WlrLayershell.keyboardFocus: (root.runnerVisible && !runnerContainer.isExiting) ? WlrLayershell.Exclusive : WlrLayershell.None

        onVisibleChanged: {
            if (visible) {
                runnerContainer.chosenIndex = -1;
                runnerContainer.isExiting = false;
                searchInput.forceActiveFocus();
                searchInput.text = "";
                AnyrunService.query("");
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.toggleRunner(false)
        }

        // Offscreen anchor used as a "null" blur region target: a null region blurs the whole screen
        Item {
            id: offscreenAnchor
            x: -9999
            y: -9999
            width: 1
            height: 1
            visible: true
            opacity: 0.0
        }

        Region {
            id: hiddenBlurRegion
            Region {
                item: offscreenAnchor
                radius: 0
            }
        }

        Region {
            id: runnerBlurRegion
            Region {
                item: glassBackground
                radius: 0
            }
        }

        property var activeRegion: (runnerWindow.visible && runnerContainer.backdropOpacity > 0.01) ? runnerBlurRegion : hiddenBlurRegion
        BackgroundEffect.blurRegion: activeRegion

        Item {
            id: mainContent
            anchors.fill: parent
            focus: true

            opacity: (root.runnerVisible && (!runnerContainer.isExiting || runnerContainer.chosenIndex !== -1)) ? 1.0 : 0.0
            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.animationDurationFast
                    easing.type: Easing.InOutQuad
                }
            }

            onActiveFocusChanged: {
                if (!activeFocus && runnerWindow.visible && runnerContainer.chosenIndex === -1) {
                    root.toggleRunner(false);
                }
            }

            Item {
                id: runnerContainer
                // Fixed large height to avoid surface reconfiguration while content grows
                width: 600
                height: 1200
                y: parent.height * 0.2
                anchors.horizontalCenter: parent.horizontalCenter

                property int chosenIndex: -1
                property bool isExiting: false
                readonly property int resultsCount: AnyrunService.resultsModel.count

                property real backdropOpacity: (root.runnerVisible && !isExiting) ? 1.0 : 0.0

                Behavior on backdropOpacity {
                    NumberAnimation {
                        duration: runnerContainer.isExiting ? 300 : Theme.animationDurationFast
                        easing.type: Easing.InOutQuad
                    }
                }

                Timer {
                    id: exitTimer
                    interval: 850
                    onTriggered: root.toggleRunner(false)
                }

                function selectNext() {
                    if (resultsCount > 0)
                        resultsList.currentIndex = (resultsList.currentIndex + 1) % resultsCount;
                }

                function selectPrev() {
                    if (resultsCount > 0)
                        resultsList.currentIndex = (resultsList.currentIndex - 1 + resultsCount) % resultsCount;
                }

                function executeMatch(idx) {
                    chosenIndex = idx;
                    isExiting = true;
                    resultsList.currentIndex = idx;
                    const match = AnyrunService.resultsModel.get(idx);
                    AnyrunService.execute(match.rawPlugin, match.rawMatch);
                    exitTimer.start();
                }

                // Track the "visible" height for the background and clipping
                // Base: 15 (top margin) + 44 (search bar) + 15 (bottom margin) = 74
                // Divider gap: 8 (spacing) + 1 (line) + 8 (spacing) = 17
                // Empty state: 8 (spacing) + 60 (text) = 68
                readonly property real baseHeight: 74
                readonly property real separatorHeight: 17
                readonly property real emptyStateHeight: 68

                property real contentHeight: (!root.runnerVisible || isExiting) ? 0
                    : baseHeight
                    + (resultsCount > 0 ? resultsList.contentHeight + separatorHeight : 0)
                    + (resultsCount === 0 && searchInput.text !== "" ? emptyStateHeight : 0)

                property real targetBackgroundHeight: 0

                Timer {
                    id: heightDebounce
                    interval: 100
                    onTriggered: runnerContainer.targetBackgroundHeight = runnerContainer.contentHeight
                }

                onContentHeightChanged: {
                    if (contentHeight > targetBackgroundHeight || (!root.runnerVisible || isExiting)) {
                        targetBackgroundHeight = contentHeight;
                        heightDebounce.stop();
                    } else {
                        heightDebounce.restart();
                    }
                }

                Rectangle {
                    id: glassBackground
                    width: parent.width
                    height: runnerContainer.targetBackgroundHeight
                    radius: 12
                    color: "transparent"
                    opacity: runnerContainer.backdropOpacity

                    Behavior on height {
                        NumberAnimation {
                            duration: Theme.animationDuration
                            easing.type: Easing.OutQuad
                        }
                    }

                    ShaderEffect {
                        id: glassShader
                        anchors.fill: parent

                        property real radius: parent.radius
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
                }

                Item {
                    anchors.fill: parent
                    z: runnerContainer.isExiting ? 100 : 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 8

                        Rectangle {
                            id: searchField
                            Layout.fillWidth: true
                            Layout.preferredHeight: 44
                            radius: 12
                            color: Colors.alpha("#ffffff", 0.08)
                            opacity: runnerContainer.backdropOpacity
                            border.width: 1
                            border.color: searchInput.activeFocus ? Colors.alpha("#ffffff", 0.25) : Colors.alpha("#ffffff", 0.15)

                            Behavior on border.color {
                                ColorAnimation {
                                    duration: 150
                                }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 12

                                StyledText {
                                    text: ""
                                    font.pixelSize: 18
                                    color: Colors.palette.text
                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 150
                                        }
                                    }
                                }

                                TextInput {
                                    id: searchInput
                                    enabled: runnerContainer.chosenIndex === -1
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    verticalAlignment: TextInput.AlignVCenter
                                    font.pixelSize: 18
                                    color: Colors.palette.text
                                    selectionColor: Colors.palette.surface2
                                    selectedTextColor: Colors.palette.text

                                    StyledText {
                                        text: "Search anything..."
                                        font.pixelSize: 18
                                        color: Colors.palette.subtext1
                                        visible: searchInput.text === ""
                                        anchors.fill: parent
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    onTextChanged: {
                                        AnyrunService.query(text);
                                        resultsList.currentIndex = 0;
                                    }

                                    Keys.onDownPressed: runnerContainer.selectNext()
                                    Keys.onTabPressed: runnerContainer.selectNext()
                                    Keys.onUpPressed: runnerContainer.selectPrev()
                                    Keys.onBacktabPressed: runnerContainer.selectPrev()

                                    Keys.onReturnPressed: {
                                        if (runnerContainer.resultsCount > 0 && resultsList.currentIndex >= 0 && runnerContainer.chosenIndex === -1)
                                            runnerContainer.executeMatch(resultsList.currentIndex);
                                    }
                                    Keys.onEscapePressed: {
                                        root.toggleRunner(false);
                                    }
                                }

                                StyledText {
                                    text: ""
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

                        StyledText {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 60
                            text: "No results found"
                            font.pixelSize: 16
                            font.italic: true
                            color: Colors.palette.text
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            visible: runnerContainer.resultsCount === 0 && searchInput.text !== ""
                            opacity: runnerContainer.backdropOpacity
                        }

                        Item {
                            Layout.fillWidth: true
                            height: 1
                            visible: separator.opacity > 0
                            opacity: runnerContainer.backdropOpacity

                            Rectangle {
                                id: separator
                                anchors.fill: parent
                                color: Colors.alpha("#ffffff", 0.1)
                                opacity: runnerContainer.resultsCount > 0 ? 1.0 : 0.0
                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 150
                                    }
                                }
                            }
                        }

                        ListView {
                            id: resultsList
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            model: AnyrunService.resultsModel
                            interactive: false
                            spacing: 4
                            delegate: Item {
                                id: delegateRoot
                                z: runnerContainer.chosenIndex === index ? 1000 : 0
                                width: ListView.view.width
                                height: 48

                                property real blowOutScale: 1.0
                                property real blowOutOpacity: 1.0
                                property real entranceOpacity: 0.0
                                property real entranceScale: 0.95

                                opacity: runnerContainer.chosenIndex === index ? blowOutOpacity : (runnerContainer.chosenIndex === -1 ? (runnerContainer.backdropOpacity * entranceOpacity) : 0.0)
                                scale: runnerContainer.chosenIndex === index ? blowOutScale : entranceScale

                                states: [
                                    State {
                                        name: "chosen"
                                        when: runnerContainer.chosenIndex === index
                                        PropertyChanges {
                                            target: delegateRoot
                                            blowOutScale: 1.5
                                            blowOutOpacity: 0.0
                                        }
                                    }
                                ]

                                transitions: [
                                    Transition {
                                        from: ""
                                        to: "chosen"
                                        ParallelAnimation {
                                            NumberAnimation {
                                                property: "blowOutScale"
                                                duration: 800
                                                easing.type: Easing.OutCubic
                                            }
                                            NumberAnimation {
                                                property: "blowOutOpacity"
                                                duration: 800
                                            }
                                        }
                                    }
                                ]

                                Component.onCompleted: delegateEnterAnim.start()

                                SequentialAnimation {
                                    id: delegateEnterAnim
                                    PauseAnimation {
                                        duration: Math.max(0, index * 15)
                                    }
                                    ParallelAnimation {
                                        NumberAnimation {
                                            target: delegateRoot
                                            property: "entranceOpacity"
                                            to: 1.0
                                            duration: 150
                                        }
                                        NumberAnimation {
                                            target: delegateRoot
                                            property: "entranceScale"
                                            from: 0.95
                                            to: 1.0
                                            duration: 150
                                            easing.type: Easing.OutBack
                                        }
                                    }
                                }

                                Behavior on y {
                                    NumberAnimation {
                                        duration: 150
                                        easing.type: Easing.OutQuad
                                    }
                                }

                                Rectangle {
                                    id: delegateBg
                                    anchors.fill: parent
                                    radius: 8

                                    property bool isHovered: mouseArea.containsMouse
                                    property bool isActive: delegateRoot.ListView.isCurrentItem

                                    color: Colors.alpha("#ffffff", isActive ? 0.2 : (isHovered ? 0.22 : 0.08))

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: Theme.animationDurationFast
                                        }
                                    }

                                    Rectangle {
                                        anchors.fill: parent
                                        radius: parent.radius
                                        color: "transparent"
                                        border.width: 1
                                        border.color: delegateBg.isActive ? Colors.alpha("#ffffff", 0.20) : (delegateBg.isHovered ? Colors.alpha("#ffffff", 0.15) : "transparent")
                                        Behavior on border.color {
                                            ColorAnimation {
                                                duration: Theme.animationDurationFast
                                            }
                                        }
                                    }

                                    MouseArea {
                                        id: mouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onEntered: resultsList.currentIndex = index
                                        onClicked: {
                                            if (runnerContainer.chosenIndex === -1)
                                                runnerContainer.executeMatch(index);
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
                                                text: (model.title || "").replace(/&\w+;/g, '')
                                                font.pixelSize: 14
                                                color: Colors.palette.text
                                                elide: Text.ElideRight
                                            }

                                            StyledText {
                                                Layout.fillWidth: true
                                                text: (model.description || "").replace(/&\w+;/g, '')
                                                font.pixelSize: 11
                                                color: Colors.light.teal
                                                visible: text !== ""
                                                elide: Text.ElideRight
                                            }
                                        }

                                        StyledText {
                                            text: model.pluginName
                                            font.pixelSize: 10
                                            color: Colors.light.teal
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
