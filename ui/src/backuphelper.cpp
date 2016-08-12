/*
    Call Recorder for SailfishOS
    Copyright (C) 2016 Dmitriy Purgin <dpurgin@gmail.com>

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

#include "backuphelper.h"

#include <QDebug>
#include <QDir>
#include <QFileInfo>
#include <QThreadPool>

#include <libcallrecorder/settings.h>

#include "backupexception.h"
#include "backupworker.h"

QDebug operator<<(QDebug dbg, BackupHelper::ErrorCode errorCode)
{
    switch (errorCode)
    {
        case BackupHelper::ErrorCode::None: dbg << "No error"; break;
        case BackupHelper::ErrorCode::FileExists: dbg << "File exists"; break;
        case BackupHelper::ErrorCode::FileNotExists: dbg << "File doesn't exist"; break;
        case BackupHelper::ErrorCode::UnableToWrite: dbg << "Unable to write"; break;
        case BackupHelper::ErrorCode::UnableToStart: dbg << "Unable to start thread"; break;
        default: dbg << "Unknown";
    }

    return dbg;
}

BackupHelper::BackupHelper(QObject* parent)
    : QObject(parent)
{
    qDebug();
}

BackupHelper::~BackupHelper()
{
    qDebug();
}

void BackupHelper::backup(const QString& fileName, bool compress, bool overwrite)
{
    qDebug() << "backing up to " << fileName;

    setErrorCode(ErrorCode::None);
    setBusy(true);

    try
    {
        QFileInfo backupFileInfo(fileName);

        if (!overwrite && backupFileInfo.exists())
            throw BackupException(ErrorCode::FileExists, fileName);

        if (!backupFileInfo.absoluteDir().exists())
        {
            if (!QDir().mkpath(backupFileInfo.absolutePath()))
            {
                throw BackupException(ErrorCode::UnableToWrite,
                                      backupFileInfo.absolutePath());
            }
        }

        QFile file(backupFileInfo.absoluteFilePath());

        if (!file.open(QFile::WriteOnly))
            throw BackupException(ErrorCode::UnableToWrite, backupFileInfo.absoluteFilePath());

        file.close();

        BackupWorker* worker = new BackupWorker(BackupWorker::Mode::Backup, fileName, compress);

        connect(worker, &BackupWorker::started,
                [this]() { setBusy(true); });

        connect(worker, &BackupWorker::finished,
                [this](ErrorCode errorCode) { setBusy(false); setErrorCode(errorCode); });

        connect(worker, &BackupWorker::progressChanged,
                this, &BackupHelper::setProgress);

        connect(worker, &BackupWorker::totalCountChanged,
                this, &BackupHelper::setTotalCount);

        if (!QThreadPool::globalInstance()->tryStart(worker))
            throw BackupException(ErrorCode::UnableToStart, QString());
    }
    catch (BackupException& e)
    {
        qDebug() << e.errorCode() << e.qWhat();

        setBusy(false);
        setErrorCode(e.errorCode());
    }
}

void BackupHelper::restore(const QString&)
{
}
