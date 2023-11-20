/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#pragma once

#include "QGCToolbox.h"
#include "QGCLoggingCategory.h"
#include "Fact.h"

#include <QTimer>
#include <QTime>
#include <QNetworkReply>

class AppSettings;
class QGCApplication;
class LinkInterface;

//-----------------------------------------------------------------------------
class AirLinkManager : public QGCTool
{
    Q_OBJECT

public:
    Q_PROPERTY(bool  isConnectServer         READ isConnectServer        NOTIFY connectStatusChanged)
    Q_PROPERTY(bool  isAuthServer            READ isAuthServer           NOTIFY authStatusChanged)
    \
    Q_INVOKABLE void connectToAirLinkServer     (const QString &login, const QString &pass);
    Q_INVOKABLE void createConfigurationAirLink (void);
    Q_INVOKABLE void sendLoginMsgToAirLink      (LinkInterface* link, const QString &login);
    Q_INVOKABLE bool isConnectServer            (void) { return _isConnectServer; }
    Q_INVOKABLE bool isAuthServer               (void) { return _isAuthServer; }

    explicit AirLinkManager                 (QGCApplication* app, QGCToolbox* toolbox);
    ~AirLinkManager                         () override;

    void   setToolbox                       (QGCToolbox* toolbox) override;

signals:
    void    connectStatusChanged();
    void    authStatusChanged();

private slots:
    void    onlineStatusUpdate  (void);

private:
    void                _parseAnswer                (const QByteArray &ba);
    void                _processReplyAirlinkServer  (QNetworkReply &reply);
    void                _updateAirLinkState         (const QString &login, const QString &pass);

private:
    QTimer              _onlineStatusTimer;
    uint32_t            _onlineTimeout {10000};

    QMutex              _mutex;

    QNetworkReply*      _replyOnline;

    bool                _isConnectServer {true};
    bool                _isAuthServer {false};
    bool                _isAuth {false};
    bool                _isOnlineStatusRequest;
    bool                _isCreatedConfig {false};
    QMap<QString, bool> _vehiclesFromServer;

    bool                    _isConnected    = false;
    AppSettings*            _appSettings    = nullptr;
    AirLinkManager*         _airLinkManager = nullptr;
    QNetworkAccessManager*  _netMngr    = nullptr;
};
