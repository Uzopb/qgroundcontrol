/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#include "AirLinkManager.h"
#include "QGCApplication.h"
#include "QGCCorePlugin.h"
#include "LinkManager.h"
#include "SettingsManager.h"
#include "UDPLink.h"

//#include "LinkInterface.h"

#include <QSettings>
#include <QDebug>

AirLinkManager::AirLinkManager(QGCApplication* app, QGCToolbox* toolbox)
    : QGCTool(app, toolbox)
{    
    _netMngr = new QNetworkAccessManager(this);
    QObject::connect(_netMngr, &QNetworkAccessManager::finished, [this](QNetworkReply *reply){
        _processReplyAirlinkServer(*reply);
        createConfigurationAirLink();
    });

}

AirLinkManager::~AirLinkManager()
{
    _netMngr->deleteLater();
}

void AirLinkManager::setToolbox(QGCToolbox* toolbox)
{
    QGCTool::setToolbox(toolbox);
}

void AirLinkManager::onlineStatusUpdate()
{
    QString pass = _toolbox->settingsManager()->appSettings()->passAirLink()->rawValueString();
    QString login = _toolbox->settingsManager()->appSettings()->loginAirLink()->rawValueString();

    _updateAirLinkState(login, pass);

//    if (_isAuth)
//        for (auto const &link : _rgLinkConfigs)
//            link->setOnline(_vehiclesFromServer[link->name()]);
//    else
//        for (auto const &link : _rgLinkConfigs)
//            link->setOnline(false);
}

\
void AirLinkManager::connectToAirLinkServer(const QString &login, const QString &pass)
{
    QNetworkRequest request;
    request.setUrl(QUrl("https://air-link.space/api/gs/getModems"));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QJsonObject obj;
    obj["login"] = login;
    obj["password"] = pass;
    QJsonDocument doc(obj);
    QByteArray data = doc.toJson(QJsonDocument::Compact);

    _netMngr->post(request, data);
}

void AirLinkManager::createConfigurationAirLink()
{
//    if (_isCreatedConfig)
//        return;

    QString pass = _toolbox->settingsManager()->appSettings()->passAirLink()->rawValueString();

    quint16 port = 14550;
    foreach (const QString &nameVehicle, _vehiclesFromServer.keys()) {

//        if (!_toolbox->linkManager()->links().empty()) {
//            auto nameConfig = std::find_if(_toolbox->linkManager()->links().begin(),
//                                           _toolbox->linkManager()->links().end(),
//                                           [&nameVehicle](const auto &link){
//                return link->linkConfiguration()->name() == nameVehicle;
//            });

//            if (nameConfig != _toolbox->linkManager()->links().end())
//                continue;
//        }

        QUdpSocket udpSocket;
        while (!udpSocket.bind(QHostAddress::LocalHost, port))
               port++;

        UDPConfiguration* udpConfig = new UDPConfiguration(nameVehicle);
        udpConfig->setPassword(pass);
        udpConfig->addHost("air-link.space", port++);
        udpConfig->setDynamic(false);
//        udp->setOnline(_vehiclesFromServer.value(nameVehicle));

        _toolbox->linkManager()->addConfiguration(udpConfig);
    }
    _toolbox->linkManager()->saveLinkConfigurationList();

//    _isCreatedConfig = true;
}

void AirLinkManager::sendLoginMsgToAirLink(LinkInterface *link, const QString &login)
{
//    __mavlink_airlink_auth_t auth;
//    uint8_t buffer[MAVLINK_MAX_PACKET_LEN];
//    mavlink_message_t mavmsg;

//    const QString pass = qgcApp()->toolbox()->settingsManager()->appSettings()->passAirLink()->rawValueString();

//    memset(&auth.login, 0, sizeof(auth.login));
//    memset(&auth.password, 0, sizeof(auth.password));
//    strcpy(auth.login, login.toUtf8().constData());
//    strcpy(auth.password, pass.toUtf8().constData());

//    mavlink_msg_airlink_auth_pack(0, 0, &mavmsg, auth.login, auth.password);
//    uint16_t len = mavlink_msg_to_send_buffer(buffer, &mavmsg);
//    link->writeBytesThreadSafe((const char *)buffer, len);

//    qDebug() << (link->isConnected() ? "Connected" : "Not connected");
//    qDebug() << login.toUtf8().constData();
//    qDebug() << pass.toUtf8().constData();
}

void AirLinkManager::_parseAnswer(const QByteArray &ba)
{
    QMutexLocker locker(&_mutex);
    _vehiclesFromServer.clear();
    for (const auto &arr : QJsonDocument::fromJson(ba)["modems"].toArray()) {
        _vehiclesFromServer.insert(arr.toObject()["name"].toString(),
                                   arr.toObject()["isOnline"].toBool());

        qDebug() << arr.toObject()["name"].toString();
        qDebug() << arr.toObject()["isOnline"].toBool();
        qDebug() << arr.toObject()["imei"].toString();
    }


}

void AirLinkManager::_processReplyAirlinkServer(QNetworkReply &reply)
{
    QByteArray ba = reply.readAll();

    if (reply.error() == QNetworkReply::NoError
            && !QJsonDocument::fromJson(ba)["modems"].toArray().isEmpty()) {
        _parseAnswer(ba);
        _isCreatedConfig = false;
        _isAuthServer = true;
        emit authStatusChanged();
    }  else if (reply.error() == QNetworkReply::NoError
                && QJsonDocument::fromJson(ba)["modems"].toArray().isEmpty()) {
        _isAuthServer = false;
        emit authStatusChanged();
        _isAuthServer = true;
    } else {
        _isConnectServer = false;
        emit connectStatusChanged();
        _isConnectServer = true;
    }
}

void AirLinkManager::_updateAirLinkState(const QString &login, const QString &pass)
{
    QNetworkAccessManager *mngr = new QNetworkAccessManager(this);

    const QUrl url("https://air-link.space/api/gs/getModems");
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QJsonObject obj;
    obj["login"] = login;
    obj["password"] = pass;
    QJsonDocument doc(obj);
    QByteArray data = doc.toJson();

    _replyOnline = mngr->post(request, data);

    QObject::connect(_replyOnline, &QNetworkReply::finished, [this](){
        QByteArray ba = _replyOnline->readAll();
        if (_replyOnline->error() == QNetworkReply::NoError
                && !QJsonDocument::fromJson(ba)["modems"].toArray().isEmpty()) {
            _parseAnswer(ba);
            _isAuth = true;
        } else {
            _isAuth = false;
        }
        _replyOnline->deleteLater();
    });

    delete mngr;
    mngr = nullptr;
}
