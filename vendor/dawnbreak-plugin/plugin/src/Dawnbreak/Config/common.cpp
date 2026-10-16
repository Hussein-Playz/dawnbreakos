#include "common.hpp"

#include <qstandardpaths.h>

namespace dawnbreak::config {

using Qt::StringLiterals::operator""_s;

Q_LOGGING_CATEGORY(lcConfig, "dawnbreak.config", QtInfoMsg)

QString configDir() {
    return QStandardPaths::writableLocation(QStandardPaths::GenericConfigLocation) + u"/dawnbreak"_s;
}

QString monitorConfigDir() {
    return configDir() + u"/monitors"_s;
}

} // namespace dawnbreak::config
