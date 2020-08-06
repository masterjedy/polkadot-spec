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

#ifndef KAGOMECROSSTESTCLI_CRYPTO_EXTENSION_HPP
#define KAGOMECROSSTESTCLI_CRYPTO_EXTENSION_HPP

#include <string>
#include <vector>

namespace crypto {
    /**
     * @brief executes ext_blake2_128 tests according to provided args
     * @param args data
     * @remark not implemented
     */
    void processExtBlake2_128(const std::vector<std::string> &args);

    /**
     * @brief executes ext_blake2_256 tests according to provided args
     * @param args data
     */
    void processExtBlake2_256(const std::vector<std::string> &args);

    /**
     * @brief executes ext_ed25519 tests according to provided args
     * @param args data
     */
    void processExtEd25519(const std::vector<std::string> &args);

    /**
     * @brief executes ext_keccak_256 tests according to provided args
     * @param args data
     */
    void processExtKeccak256(const std::vector<std::string> &args);

    /**
     * @brief executes ext_sr25519 tests according to provided args
     * @param args data
     * @remark not implemented
     */
    void processExtSr25519(const std::vector<std::string> &args);

    /**
     * @brief executes ext_twox_64 tests according to provided args
     * @param args data
     */
    void processExtTwox64(const std::vector<std::string> &args);

    /**
     * @brief executes ext_twox_128 tests according to provided args
     * @param args data
     */
    void processExtTwox128(const std::vector<std::string> &args);

    /**
     * @brief executes ext_twox_256 tests according to provided args
     * @param args data
     */
    void processExtTwox256(const std::vector<std::string> &args);

    /**
     * @brief executes ext_crypto_ed25519_generate_version_1 tests according to provided args
     * @param args data
     */
    void processEd25519Generate_version_1(const std::vector<std::string> &args);

    /**
     * @brief executes ext_crypto_sr25519_generate_version_1 tests according to provided args
     * @param args data
     */
    void processSr25519Generate_version_1(const std::vector<std::string> &args);

    /**
     * @brief executes ext_crypto_ed25519_public_keys_version_1 tests according to provided args
     * @param args data
     */
    void processEd25519PublicKeys_version_1(const std::vector<std::string> &args);

    /**
     * @brief executes ext_crypto_sr25519_public_keys_version_1 tests according to provided args
     * @param args data
     */
    void processSr25519PublicKeys_version_1(const std::vector<std::string> &args);

    /**
     * @brief executes ext_crypto_ed25519_sign_version_1 tests according to provided args
     * @param args data
     */
    void processEd25519Sign_version_1(const std::vector<std::string> &args);

    /**
     * @brief executes ext_crypto_ed25519_verify_version_1 tests according to provided args
     * @param args data
     */
    void processEd25519Verify_version_1(const std::vector<std::string> &args);

    /**
     * @brief executes ext_crypto_sr25519_sign_version_1 tests according to provided args
     * @param args data
     */
    void processSr25519Sign_version_1(const std::vector<std::string> &args);

    /**
     * @brief executes ext_crypto_sr25519_verify_version_1 tests according to provided args
     * @param args data
     */
    void processSr25519Verify_version_1(const std::vector<std::string> &args);


} // namespace crypto

#endif // KAGOMECROSSTESTCLI_CRYPTO_EXTENSION_HPP
