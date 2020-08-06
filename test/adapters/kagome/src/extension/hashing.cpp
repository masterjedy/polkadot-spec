/*
 * Copyright (c) 2019 Web3 Technologies Foundation
 *
 * This file is part of Polkadot Host Test Suite
 *
 * Polkadot Host Test Suite is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Polkadot Host Tests is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Foobar.  If not, see <https://www.gnu.org/licenses/>.
 */

#include "crypto.hpp"

#include "helpers.hpp"

#include <common/buffer.hpp>
#include <common/hexutil.hpp>

#include <iostream>

#include "hashing.hpp"

namespace hashing {

    void processExtKeccak256_version_1(const std::vector<std::string> &args) {
        std::string data = args[0];

        auto[memory, extension] = helpers::initialize_environment();

        kagome::common::Buffer buffer;

        buffer.put(data);
        kagome::runtime::WasmSize valueSize = buffer.size();
        kagome::runtime::WasmSpan valuePtr = memory->allocate(valueSize);
        memory->storeBuffer(valuePtr, buffer);
        buffer.clear();

        auto resultPtr = memory->allocate(32);
        extension->ext_blake2_256(valuePtr, valueSize, resultPtr);
        auto hash = memory->loadN(resultPtr, 32);

        std::cout << kagome::common::hex_lower(hash) << "\n";

    }
}
