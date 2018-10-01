/***********************************************************************/


import QtQuick 2.0

import SddmComponents 2.0


Rectangle {
    width: 640
    height: 480

    TextConstants { id: textConstants }

    Connections {
        target: sddm

        onLoginSucceeded: {
            errorMessage.color = "steelblue"
            errorMessage.text = textConstants.loginSucceeded
        }

        onLoginFailed: {
            errorMessage.color = "red"
            errorMessage.text = textConstants.loginFailed
        }
    }

    Repeater {
        model: screenModel
        Background {
            x: geometry.x; y: geometry.y; width: geometry.width; height:geometry.height
            source: config.background
            /* source: "epita.png" */
            fillMode: Image.Strech
            onStatusChanged: {
                if (status == Image.Error && source != config.defaultBackground) {
                    source = config.defaultBackground
                }
            }
        }
    }

    Rectangle {
        property variant geometry: screenModel.geometry(screenModel.primary)
        x: geometry.x; y: geometry.y; width: geometry.width; height: geometry.height
        color: "transparent"
        transformOrigin: Item.Top

        Text {
          y: 50
          anchors.horizontalCenter: parent.horizontalCenter
          height: text.implicitHeight
          color: "white"
          text: config.title
          wrapMode: Text.WordWrap
          font.pixelSize: archlinux.height / 11.75
          elide: Text.ElideRight
          horizontalAlignment: Text.AlignHCenter
        }

        Image {
            id: epitalogo
            width: height * 3
            height: parent.height / 3
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -1 * height / 2
            anchors.horizontalCenterOffset: 0
            fillMode: Image.PreserveAspectFit
            transformOrigin: Item.Center
            /* source: "epita.png" */
            source: config.logo
        }

        Rectangle {
            id: archlinux
            anchors.centerIn: parent
            height: parent.height / 10 * 3
            width: height * 1.8
            anchors.verticalCenterOffset: height * 2 / 3
            color: "#0C0C0C"

            Column {
                id: mainColumn
                anchors.centerIn: parent
                width: parent.width * 0.9
                spacing: archlinux.height / 22.5

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    verticalAlignment: Text.AlignVCenter
                    width: parent.width
                    height: text.implicitHeight
                    color: "white"
                    text: textConstants.welcomeText.arg(sddm.hostName)
                    wrapMode: Text.WordWrap
                    font.pixelSize: archlinux.height / 11.75
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }

                Row {
                    width: parent.width
                    spacing: Math.round(archlinux.height / 70)
                    Text {
                        id: lblName
                        width: parent.width * 0.20; height: archlinux.height / 9
                        color: "white"
                        text: textConstants.userName
                        verticalAlignment: Text.AlignVCenter
                        font.bold: true
                        font.pixelSize: archlinux.height / 22.5
                    }

                    TextBox {
                        id: name
                        width: parent.width * 0.8; height: archlinux.height / 9
                        text: userModel.lastUser
                        font.pixelSize: archlinux.height / 20

                        KeyNavigation.backtab: rebootButton; KeyNavigation.tab: password

                        Keys.onPressed: {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                sddm.login(name.text, password.text, session.index)
                                event.accepted = true
                            }
                        }
                    }
                }

                Row {
                    width: parent.width
                    spacing : Math.round(archlinux.height / 70)
                    Text {
                        id: lblPassword
                        width: parent.width * 0.2; height: archlinux.height / 9
                        color: "white"
                        text: textConstants.password
                        verticalAlignment: Text.AlignVCenter
                        font.bold: true
                        font.pixelSize: archlinux.height / 22.5
                    }

                    PasswordBox {
                        id: password
                        width: parent.width * 0.8; height: archlinux.height / 9
                        font.pixelSize: archlinux.height / 20
                        tooltipBG: "lightgrey"
                        focus: true
                        Timer {
                            interval: 200
                            running: true
                            onTriggered: password.forceActiveFocus()
                        }

                        KeyNavigation.backtab: name; KeyNavigation.tab: session

                        Keys.onPressed: {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                sddm.login(name.text, password.text, session.index)
                                event.accepted = true
                            }
                        }
                    }
                }

                Row {
                    spacing: Math.round(archlinux.height / 70)
                    width: parent.width
                    z: 100

                    Text {
                        id: lblSession
                        width: parent.width / 6 + 18; height: archlinux.height / 9
                        text: textConstants.session
                        verticalAlignment: Text.AlignVCenter
                        color: "white"
                        wrapMode: TextEdit.WordWrap
                        font.bold: true
                        font.pixelSize: archlinux.height / 22.5
                    }

                    ComboBox {
                        id: session
                        width: parent.width / 3; height: archlinux.height / 9
                        font.pixelSize: archlinux.height / 20

                        arrowIcon: "angle-down.png"

                        model: sessionModel
                        index: sessionModel.lastIndex

                        KeyNavigation.backtab: password; KeyNavigation.tab: layoutBox
                    }

                    ComboBox {
                        id: comboLayout
                        model: keyboard.layouts
                        index: keyboard.currentLayout
                        width: (parent.width / 2) - 24; height: archlinux.height / 9
                        font.pixelSize: archlinux.height / 20
                        arrowIcon: "angle-down.png"
                        KeyNavigation.backtab: session; KeyNavigation.tab: loginButton
                        onValueChanged: keyboard.currentLayout = id

                        Connections {
                            target: keyboard
                            onCurrentLayoutChanged: combo.index = keyboard.currentLayout
                        }

                        rowDelegate: Rectangle {
                            color: "transparent"
                            Image {
                                id: img
                                source: "/usr/share/sddm/flags/%1.png".arg(modelItem ? modelItem.modelData.shortName : "zz")
                                anchors.margins: 4
                                fillMode: Image.PreserveAspectFit
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                            }
                            Text {
                                anchors.margins: 4
                                anchors.left: img.right
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                verticalAlignment: Text.AlignVCenter
                                text: modelItem ? modelItem.modelData.longName : "zz"
                                font.pixelSize: 14
                            }
                        }
                    }
                }

                Column {
                    width: parent.width
                    Text {
                        id: errorMessage
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: textConstants.prompt
                        color: "white"
                        font.pixelSize: archlinux.height / 22.5
                    }
                }

                Row {
                    spacing: Math.round(archlinux.height / 70)
                    anchors.horizontalCenter: parent.horizontalCenter
                    property int btnWidth: Math.max(loginButton.implicitWidth,
                                                    shutdownButton.implicitWidth,
                                                    rebootButton.implicitWidth, archlinux.height / 3) + 8
                    Button {
                        id: loginButton
                        text: textConstants.login
                        width: parent.btnWidth
                        height: archlinux.height / 9
                        font.pixelSize: archlinux.height / 20
                        color: "#1793d1"

                        onClicked: sddm.login(name.text, password.text, session.index)

                        KeyNavigation.backtab: layoutBox; KeyNavigation.tab: shutdownButton
                    }

                    Button {
                        id: shutdownButton
                        text: textConstants.shutdown
                        width: parent.btnWidth
                        height: archlinux.height / 9
                        font.pixelSize: archlinux.height / 20
                        color: "#1793d1"

                        onClicked: sddm.powerOff()

                        KeyNavigation.backtab: loginButton; KeyNavigation.tab: rebootButton
                    }

                    Button {
                        id: rebootButton
                        text: textConstants.reboot
                        width: parent.btnWidth
                        height: archlinux.height / 9
                        font.pixelSize: archlinux.height / 20
                        color: "#1793d1"

                        onClicked: sddm.reboot()

                        KeyNavigation.backtab: shutdownButton; KeyNavigation.tab: name
                    }
                }
            }
        }

        Text {
          anchors.right: parent.right
          anchors.rightMargin: 100
          y: parent.height - 100
          height: text.implicitHeight
          color: "white"
          text: config.footer
          wrapMode: Text.WordWrap
          font.pixelSize: archlinux.height / 20 
          elide: Text.ElideRight
        }
    }

    Component.onCompleted: {
        if (name.text == "")
            name.focus = true
        else
            password.focus = true
    }
}
