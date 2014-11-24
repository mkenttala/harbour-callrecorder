/*
    Call Recorder for SailfishOS
    Copyright (C) 2014  Dmitriy Purgin <dpurgin@gmail.com>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef LIBCALLRECORDER_SETTINGS_H
#define LIBCALLRECORDER_SETTINGS_H

#include <QAudioFormat>
#include <QAudioDeviceInfo>
#include <QScopedPointer>

#include "config.h"

class LIBCALLRECORDER_DECL Settings : public QObject
{
    Q_OBJECT

    Q_DISABLE_COPY(Settings)

    Q_PROPERTY(QString outputLocation READ outputLocation WRITE setOutputLocation NOTIFY outputLocationChanged)
    Q_PROPERTY(int sampleRate READ sampleRate WRITE setSampleRate NOTIFY sampleRateChanged)

public:
    Settings(QObject* parent = NULL);
    ~Settings();

    QAudioFormat audioFormat() const;
    QAudioDeviceInfo inputDevice() const;

    QString outputLocation() const;
    void setOutputLocation(const QString& outputLocation);

    int sampleRate() const;
    void setSampleRate(int sampleRate);

signals:
    void outputLocationChanged(QString outputLocation);
    void sampleRateChanged(int sampleRate);
    void settingsChanged();

private:
    class SettingsPrivate;
    QScopedPointer< SettingsPrivate > d;
};

#endif // LIBCALLRECORDER_SETTINGS_H