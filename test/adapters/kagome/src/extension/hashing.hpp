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

#ifndef KAGOMECROSSTESTCLI_HASHING_EXTENSION_HPP
#define KAGOMECROSSTESTCLI_HASHING_EXTENSION_HPP

#include <string>
#include <vector>

namespace hashing {
    /**
     * @brief executes ext_hashing_keccak_256_version_1 tests according to provided args
     * @param args data
     */
    void processExtKeccak256_version_1(const std::vector<std::string> &args);

    /**
     * @brief executes ext_hashing_sha2_256_version_1 tests according to provided args
     * @param args data
     */
    void processExtSha2_256_version_1(const std::vector<std::string> &args);

    /**
     * @brief executes ext_hashing_blake2_128_version_1 tests according to provided args
     * @param args data
     */
    void processBlake2_128_version_1(const std::vector<std::string> &args);

    /**
     * @brief executes ext_hashing_sha2_256_version_1 tests according to provided args
     * @param args data
     */
    void processBlake2_256_version_1(const std::vector<std::string> &args);

    /**
     * @brief executes ext_hashing_twox_256_version_1 tests according to provided args
     * @param args data
     */
    void processTwox256_version_1(const std::vector<std::string> &args);

    /**
     * @brief executes ext_hashing_twox_128_version_1 tests according to provided args
     * @param args data
     */
    void processTwox128_version_1(const std::vector<std::string> &args);

    /**
     * @brief executes ext_hashing_twox_64_version_1 tests according to provided args
     * @param args data
     */
    void processTwox64_version_1(const std::vector<std::string> &args);

}

#endif // KAGOMECROSSTESTCLI_HASHING_EXTENSION_HPP
