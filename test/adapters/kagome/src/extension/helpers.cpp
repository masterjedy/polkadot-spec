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

#include "helpers.hpp"

#include <binaryen/shell-interface.h>

#include <storage/trie/impl/trie_storage_impl.hpp>
#include <storage/trie/impl/trie_storage_backend_impl.hpp>
#include <storage/in_memory/in_memory_storage.hpp>
#include <storage/changes_trie/impl/storage_changes_tracker_impl.hpp>
#include <runtime/common/trie_storage_provider_impl.hpp>
#include <runtime/binaryen/wasm_memory_impl.hpp>
#include <extensions/impl/extension_impl.hpp>
#include <storage/trie/polkadot_trie/polkadot_trie_factory_impl.hpp>
#include <storage/trie/serialization/polkadot_codec.hpp>
#include <crypto/sr25519/sr25519_provider_impl.hpp>
#include <crypto/ed25519/ed25519_provider_impl.hpp>
#include <crypto/random_generator/boost_generator.hpp>
#include <crypto/secp256k1/secp256k1_provider_impl.hpp>
#include <crypto/hasher/hasher_impl.hpp>
#include <crypto/bip39/impl/bip39_provider_impl.hpp>
#include <crypto/pbkdf2/impl/pbkdf2_provider_impl.hpp>
#include <crypto/crypto_store/crypto_store_impl.hpp>
#include <storage/trie/serialization/trie_serializer_impl.hpp>
#include <storage/trie/impl/trie_storage_backend_impl.hpp>
#include <blockchain/impl/storage_util.hpp>
#include <storage/buffer_map_types.hpp>
#include <runtime/common/trie_storage_provider_impl.hpp>

namespace helpers {

    wasm::ShellExternalInterface GLOBAL_WASM_SHELL;

    std::pair<
            std::shared_ptr<kagome::runtime::WasmMemory>,
            std::unique_ptr<kagome::extensions::Extension>
    > initialize_environment() {

        auto trie_factory = std::make_shared<kagome::storage::trie::PolkadotTrieFactoryImpl>();
        auto codec = std::make_shared<kagome::storage::trie::PolkadotCodec>();

        // std::shared_ptr<BufferStorage> storage,
        //                      common::Buffer node_prefix


        auto node_prefix = kagome::blockchain::prefix::TRIE_NODE;

        // TODO(yuraz) creat correctly
//        auto buffer_storage = std::make_shared<kagome::storage::BufferStorage>();
//        auto trie_backend = std::make_shared<kagome::storage::trie::TrieStorageBackendImpl>(buffer_storage,
//                                                                                            node_prefix);

        std::shared_ptr<kagome::storage::BufferStorage> buffer_storage;
        std::shared_ptr<kagome::storage::trie::TrieStorageBackendImpl> trie_backend;

        auto trie_serializer = std::make_shared<kagome::storage::trie::TrieSerializerImpl>(trie_factory, codec,
                                                                                           trie_backend);
        auto tracker = std::make_shared<kagome::storage::changes_trie::StorageChangesTrackerImpl>(trie_factory, codec);

        auto trie = kagome::storage::trie::TrieStorageImpl::createEmpty(trie_factory, codec, trie_serializer,
                                                                        boost::make_optional<std::shared_ptr<kagome::storage::changes_trie::ChangesTracker>>(
                                                                                tracker)).value();

        std::shared_ptr<kagome::runtime::WasmMemory> memory =
                std::make_shared<kagome::runtime::binaryen::WasmMemoryImpl>(&GLOBAL_WASM_SHELL.memory, 4096);

        auto trie_storage_provider = std::make_shared<kagome::runtime::TrieStorageProviderImpl>(std::move(trie));


        auto random_provider = std::make_shared<kagome::crypto::BoostRandomGenerator>();
        auto sr25519_provider = std::make_shared<kagome::crypto::SR25519ProviderImpl>(random_provider);
        auto ed25519_provider = std::make_shared<kagome::crypto::ED25519ProviderImpl>();
        auto secp256k1_provider = std::make_shared<kagome::crypto::Secp256k1ProviderImpl>();
        auto hasher = std::make_shared<kagome::crypto::HasherImpl>();

        auto pbkdf2_provider = std::make_shared<kagome::crypto::Pbkdf2ProviderImpl>();
        auto bip39_provider = std::make_shared<kagome::crypto::Bip39ProviderImpl>(pbkdf2_provider);

        auto crypto_store = std::make_shared<kagome::crypto::CryptoStoreImpl>(ed25519_provider, sr25519_provider,
                                                                              secp256k1_provider, bip39_provider,
                                                                              random_provider);


        std::unique_ptr<kagome::extensions::Extension> extension =
                std::make_unique<kagome::extensions::ExtensionImpl>(memory, trie_storage_provider, tracker,
                                                                    sr25519_provider,
                                                                    ed25519_provider, secp256k1_provider, hasher,
                                                                    crypto_store, bip39_provider);

        return std::make_pair(memory, std::move(extension));
    }

}
