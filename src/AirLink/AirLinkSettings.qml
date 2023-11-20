/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtGraphicalEffects       1.0
import QtMultimedia             5.5
import QtQuick                  2.3
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.4
import QtQuick.Dialogs          1.2
import QtQuick.Layouts          1.2
import QtLocation               5.3
import QtPositioning            5.3

import QGroundControl                       1.0
import QGroundControl.Controllers           1.0
import QGroundControl.Controls              1.0
import QGroundControl.FactControls          1.0
import QGroundControl.FactSystem            1.0
import QGroundControl.Palette               1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.SettingsManager       1.0

Rectangle {
    id:                 _root
    color:              qgcPal.window
    anchors.fill:       parent
    anchors.margins:    ScreenTools.defaultFontPixelWidth

    property real _labelWidth:                  ScreenTools.defaultFontPixelWidth * 26
    property real _valueWidth:                  ScreenTools.defaultFontPixelWidth * 20    
    property real _panelWidth:                  _root.width * _internalWidthRatio
    property Fact _passwordFact:                QGroundControl.settingsManager.appSettings.passAirLink
    property Fact _usernameFact:                QGroundControl.settingsManager.appSettings.loginAirLink

//    property int _isAuthServer: {
//        if (QGroundControl.airlinkManager.isAuthServer) {
////            closeAirLinkRegistration()
//            loginDialog.visible = true
//            return true
//        } /*else {
//            loginDialog.visible = true
//            return false
//        }*/
//    }

    MessageDialog {
        id:         loginDialog
        visible:    false
        icon:       StandardIcon.Warning
        standardButtons: StandardButton.Yes
        title:      qsTr("AirLink Authentification")
        text:       QGroundControl.airlinkManager.isAuthServer ? qsTr("login successful !")
                                                               : qsTr("Wrong login or password. Please check it and try again!")

        onYes: loginDialog.visible = false
    }

    readonly property real _internalWidthRatio:          0.8

    QGCFlickable {
        clip:               true
        anchors.fill:       parent
        contentHeight:      settingsColumn.height
        contentWidth:       settingsColumn.width
        Column {
            id:                 settingsColumn
            width:              _root.width
            spacing:            ScreenTools.defaultFontPixelHeight * 0.5
            anchors.margins:    ScreenTools.defaultFontPixelWidth
            QGCLabel {
                text:           qsTr("Reboot ground unit for changes to take effect.")
                color:          qgcPal.colorOrange
                visible:        QGroundControl.taisyncManager.needReboot
                font.family:    ScreenTools.demiboldFontFamily
                anchors.horizontalCenter:   parent.horizontalCenter
            }

            //---------------------------------------------
            // AirLink Registration
            Item {
                id: airLinkRegistration
                width:                      _panelWidth
                height:                     loginLabel.height
                anchors.margins:            ScreenTools.defaultFontPixelWidth
                anchors.horizontalCenter:   parent.horizontalCenter
                QGCLabel {
                    id:             loginLabel
                    text:           qsTr("Login / Registration")
                    font.family:    ScreenTools.demiboldFontFamily
                }
            }
            Rectangle {
                height:                     loginCol.height + (ScreenTools.defaultFontPixelHeight * 2)
                width:                      _panelWidth
                color:                      qgcPal.windowShade
                anchors.margins:            ScreenTools.defaultFontPixelWidth
                anchors.horizontalCenter:   parent.horizontalCenter
                Column {
                    id:                     loginCol
                    spacing:                ScreenTools.defaultFontPixelHeight * 0.5
                    width:                  parent.width
                    anchors.centerIn:       parent

                        GridLayout {
                            anchors.margins:    ScreenTools.defaultFontPixelHeight
                            columnSpacing:      ScreenTools.defaultFontPixelWidth * 2
                            anchors.horizontalCenter: parent.horizontalCenter
                            width:                  parent.width * 0.4
                            columns:        2
                            //                                        columnSpacing:  _colSpacing
                            //                                        rowSpacing:     _rowSpacing

                            QGCLabel {
                                text: qsTr("User Name:")
                            }
                            FactTextField {
                                id:             _userText
                                fact:           _usernameFact
                                width:          _labelWidth*5//_secondColumnWidth
                                visible:        _usernameFact.visible
                                placeholderText:qsTr("Enter Login")
                                Layout.fillWidth:    true
//                                Layout.preferredWidth:  mainLayout.width//_secondColumnWidth
                            }
                            QGCLabel {
                                text: qsTr("Password:")
                            }
                            FactTextField {
                                id:             _passText
                                fact:           _passwordFact
                                width:          _labelWidth*5//_secondColumnWidth
                                visible:        _passwordFact.visible
                                placeholderText:qsTr("Enter Password")
                                echoMode:       TextInput.Password
                                Layout.fillWidth:    true
                            }
                            QGCLabel {
                                text: "Forgot Your AirLink Password?"
                                font.underline: true
                                Layout.columnSpan:  2
                                MouseArea {
                                    anchors.fill:   parent
                                    hoverEnabled:   true
                                    cursorShape:    Qt.PointingHandCursor
                                    onClicked:      Qt.openUrlExternally("https://air-link.space/forgot-pass")
                                }
                            }
                        }
                        Item {
                            width:  1
                            height: ScreenTools.defaultFontPixelHeight
                        }
                        RowLayout {
                            Layout.alignment:   Qt.AlignHCenter
                            anchors.horizontalCenter:   parent.horizontalCenter
//                            spacing:            _colSpacing

                            QGCButton {
                                text:       qsTr("Login")
//                                anchors.horizontalCenter:   parent.horizontalCenter                                
                                enabled:    _userText.text !== "" && _passText.text !== "" && !QGroundControl.airlinkManager.isAuthServer
                                onClicked:  QGroundControl.airlinkManager.connectToAirLinkServer(_userText.text, _passText.text)
                //                onClicked:  _linkRoot.openAirLinkRegistration()
                            }
                            QGCButton {
//                                width:      ScreenTools.defaultFontPixelWidth * 10
                                text:       qsTr("Register")
                                onClicked:  Qt.openUrlExternally("https://air-link.space/registration")
                            }
                            QGCButton {
//                                width:      ScreenTools.defaultFontPixelWidth * 10
                                text:       qsTr("OK")
                                enabled:    _userText.text !== "" && _passText.text !== ""
//                                onClicked:  QGroundControl.linkManager.connectToAirLinkServer(_userText.text, _passText.text)
                            }
                            QGCButton {
//                                width:      ScreenTools.defaultFontPixelWidth * 10
                                text:       qsTr("Cancel")
//                                onClicked: {
//                                    settingsLoader.sourceComponent = null
//                                    QGroundControl.linkManager.cancelConfigurationEditing(settingsLoader.editingConfig)
//                                }
                            }
                        }

                    }
                }

            /*
//        QGCButton {
//            text:       qsTr("Login AirLink")
//            enabled:    true
//            onClicked:  _linkRoot.openAirLinkRegistration()
//        }
              */

/*
    //---------------------------------------------
    // AirLink Registration
//    Component {
//        id: airLinkRegistration
//        Rectangle {
//            id:             settingsRect
//            color:          qgcPal.window
//            anchors.fill:   parent
//            property real   _panelWidth:    width * 0.8

//            QGCFlickable {
//                id:                 settingsFlick
//                clip:               true
//                anchors.fill:       parent
//                anchors.margins:    ScreenTools.defaultFontPixelWidth
//                contentHeight:      mainLayout.height
//                contentWidth:       mainLayout.width

//                ColumnLayout {
//                    id:         mainLayout
//                    spacing:    _rowSpacing

//                    QGCGroupBox {
//                        title: qsTr("Login / Registration")

//                        ColumnLayout {
//                            spacing: _rowSpacing

//                            GridLayout {
//                                columns:        2
//                                columnSpacing:  _colSpacing
//                                rowSpacing:     _rowSpacing

//                                QGCLabel {text: qsTr("User Name:")}
//                                FactTextField {
//                                    id:             _userText
//                                    fact:           _usernameFact
//                                    width:          _secondColumnWidth
//                                    visible:        _usernameFact.visible
//                                    placeholderText:qsTr("Enter Login")
//                                    Layout.fillWidth:    true
//                                    Layout.preferredWidth:  _secondColumnWidth
//                                    property Fact _usernameFact: QGroundControl.settingsManager.appSettings.loginAirLink
//                                }
//                                QGCLabel { text: qsTr("Password:") }
//                                FactTextField {
//                                    id:             _passText
//                                    fact:           _passwordFact
//                                    width:          _secondColumnWidth
//                                    visible:        _passwordFact.visible
//                                    placeholderText:qsTr("Enter Password")
//                                    echoMode:       TextInput.Password
//                                    Layout.fillWidth:    true
//                                    property Fact _passwordFact: QGroundControl.settingsManager.appSettings.passAirLink
//                                }
//                                QGCLabel {
//                                    text: "Forgot Your AirLink Password?"
//                                    font.underline: true
//                                    Layout.columnSpan:  2
//                                    MouseArea {
//                                        anchors.fill:   parent
//                                        hoverEnabled:   true
//                                        cursorShape:    Qt.PointingHandCursor
//                                        onClicked:      Qt.openUrlExternally("https://air-link.space/forgot-pass")
//                                    }
//                                }
//                            }
//                        }
//                    }


//                    RowLayout {
//                        Layout.alignment:   Qt.AlignHCenter
//                        spacing:            _colSpacing

//                        QGCButton {
//                            width:      ScreenTools.defaultFontPixelWidth * 10
//                            text:       qsTr("Register")
//                            onClicked:  Qt.openUrlExternally("https://air-link.space/registration")
//                        }
//                        QGCButton {
//                            width:      ScreenTools.defaultFontPixelWidth * 10
//                            text:       qsTr("OK")
//                            enabled:    _userText.text !== "" && _passText.text !== ""
//                            onClicked:  QGroundControl.linkManager.connectToAirLinkServer(_userText.text, _passText.text)
//                        }
//                        QGCButton {
//                            width:      ScreenTools.defaultFontPixelWidth * 10
//                            text:       qsTr("Cancel")
//                            onClicked: {
//                                settingsLoader.sourceComponent = null
//                                QGroundControl.linkManager.cancelConfigurationEditing(settingsLoader.editingConfig)
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
*/
        }
    }
}
