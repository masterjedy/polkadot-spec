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

#ifndef KAGOMECROSSTESTCLI_TRIE_EXTENSION_HPP
#define KAGOMECROSSTESTCLI_TRIE_EXTENSION_HPP

#include <string>
#include <vector>

namespace trie {
    /**
     * @brief executes ext_trie_blake2_256_root_version_1 tests according to provided args
     * @param args data
     */
    void processBlake2_256Root_version_1(const std::vector<std::string> &args);

    /**
     * @brief executes ext_trie_blake2_256_ordered_root_version_1 tests according to provided args
     * @param args data
     */
    void processBlake2_256OrderedRoot_version_1(const std::vector<std::string> &args);
}

#endif // KAGOMECROSSTESTCLI_TRIE_EXTENSION_HPP
