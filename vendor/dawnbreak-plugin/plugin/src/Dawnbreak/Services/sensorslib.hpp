#pragma once

#include <optional>

namespace dawnbreak::services::sensorslib {

void ensureInit();

[[nodiscard]] std::optional<double> cpuPackageTemp();
[[nodiscard]] std::optional<double> gpuPciAverageTemp();

} // namespace dawnbreak::services::sensorslib
