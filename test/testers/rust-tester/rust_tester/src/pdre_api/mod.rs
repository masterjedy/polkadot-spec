mod child_storage;
mod crypto;
mod misc;
mod network;
mod storage;
mod utils;

use clap::ArgMatches;
use utils::ParsedInput;

pub fn process_pdre_api_tests(subcmd_matches: &ArgMatches) {
    if let Some(func) = subcmd_matches.value_of("function") {
        let input: ParsedInput = subcmd_matches.values_of("input").unwrap().into();

        match func {
            "ext_storage_get" => storage::ext_storage_get(input),
            "ext_storage_child_get" => child_storage::ext_storage_child_get(input),
            "ext_storage_read" => storage::ext_storage_read(input),
            "ext_storage_child_read" => child_storage::ext_storage_child_read(input),
            "ext_storage_clear" => storage::ext_storage_clear(input),
            "ext_storage_child_clear" => child_storage::ext_storage_child_clear(input),
            "ext_storage_child_storage_kill" => child_storage::ext_storage_child_storage_kill_version_1(input),
            "ext_storage_exists" => storage::ext_storage_exists(input),
            "ext_storage_child_exists" => child_storage::ext_storage_child_exists_version_1(input),
            "ext_storage_clear_prefix" => storage::ext_storage_clear_prefix(input),
            "ext_storage_child_clear_prefix" => child_storage::ext_storage_child_clear_prefix(input),
            "ext_storage_root" => storage::ext_storage_root(input),
            "ext_storage_child_root" => child_storage::ext_storage_child_root(input),
            "ext_storage_next_key" => storage::ext_storage_next_key(input),
            "ext_crypto_ed25519_public_keys" => crypto::ext_crypto_ed25519_public_keys_version_1(input),
            "ext_crypto_ed25519_generate" => crypto::ext_crypto_ed25519_generate_version_1(input),
            "ext_crypto_ed25519_sign" => crypto::ext_crypto_ed25519_sign_version_1(input),
            "ext_crypto_ed25519_verify" => crypto::ext_crypto_ed25519_verify_version_1(input),
            "ext_crypto_sr25519_generate" => crypto::ext_crypto_sr25519_generate_version_1(input),
            "ext_crypto_sr25519_sign" => crypto::ext_crypto_sr25519_sign_version_1(input),
            "ext_crypto_sr25519_verify" => crypto::ext_crypto_sr25519_verify_version_1(input),
            "ext_hashing_keccak_256" => crypto::ext_hashing_keccak_256_version_1(input),
            "ext_hashing_sha2_256" => crypto::ext_hashing_sha2_256_version_1(input),
            "ext_hashing_blake2_128" => crypto::ext_hashing_blake2_128_version_1(input),
            "ext_hashing_blake2_256" => crypto::ext_hashing_blake2_256_version_1(input),
            "ext_hashing_twox_256" => crypto::ext_hashing_twox_256_version_1(input),
            "ext_hashing_twox_128" => crypto::ext_hashing_twox_128_version_1(input),
            "ext_hashing_twox_64" => crypto::ext_hashing_twox_64_version_1(input),
            _ => panic!("specified function not available"),
        }
    }
}
