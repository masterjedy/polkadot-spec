#Copyright (c) 2019 Web3 Technologies Foundation
#
#This file is part of Polkadot Host Test Suite
#
#Polkadot Host Test Suite is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#Polkadot Host Tests is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with Foobar.  If not, see <https://www.gnu.org/licenses/>.

# TODO: Move away from custom kagome branch for testing
#hunter_config(kagome
#    URL https://github.com/soramitsu/kagome/archive/af5c718a05a3b734291dd2c4f574c8dffb76ad46.tar.gz
#    SHA1 81f456bb92d06e7b5861dacb66d4ff77515dadf6
#)

hunter_config(libsecp256k1
        URL https://github.com/soramitsu/soramitsu-libsecp256k1/archive/c7630e1bac638c0f16ee66d4dce7b5c49eecbaa5.zip
        SHA1 179e316b0fe5150f1b05ca70ec2ac1490fe2cb3b
        CMAKE_ARGS SECP256K1_BUILD_TEST=OFF
        )

hunter_config(kagome
        URL https://github.com/soramitsu/kagome/archive/a069166e8ddc56668dbc4dfbc4335ad9741e79fb.tar.gz
        SHA1 fa75b99a02486cc2c8f54b3f9e737b8bb4bb9c91
        )


