//
// Created by Arseny Tolmachev on 2017/03/02.
//

#ifndef JUMANPP_CORE_H
#define JUMANPP_CORE_H

#include "core/analysis/lattice_config.h"
#include "core/dictionary.h"
#include "core/features_api.h"
#include "core/runtime_info.h"

namespace jumanpp {
namespace core {

class FeatureHolder {
  std::unique_ptr<features::PrimitiveFeatureApply> primitive_;
};

struct CoreConfig {
  i32 beamSize;
};

class CoreHolder {
  CoreConfig cfg_;
  const RuntimeInfo& runtime_;
  const dic::DictionaryHolder& dic_;
  FeatureHolder features_;
  analysis::LatticeConfig latticeCfg_;

 public:
  CoreHolder(const CoreConfig& conf, const RuntimeInfo& runtime,
             const dic::DictionaryHolder& dic);
  const analysis::LatticeConfig& latticeConfig() const { return latticeCfg_; }
  const dic::DictionaryHolder& dic() const { return dic_; }
};

}  // core
}  // jumanpp

#endif  // JUMANPP_CORE_H
