INCLUDE_PATH := $(abspath ./)
LIBRARY_PATH := $(abspath ./)


BUILD_TYPE?=
# keep standard at C11 and C++11
CFLAGS   = -I. -I./piper/src/cpp -I./piper/build/fi/include -I./piper/build/pi/include -I./piper/build/si/include -O3 -DNDEBUG -std=c11 -fPIC -I./piper-phonemize/pi/include
CXXFLAGS = -I. -I./piper/src/cpp -I./piper/build/fi/include -I./piper/build/pi/include -I./piper/build/si/include -O3 -DNDEBUG -std=c++17 -fPIC -I./piper-phonemize/pi/include
LDFLAGS  = -L./piper-phonemize/pi/lib -L./espeak/ei/lib/ -L./piper/build/fi/lib -L./piper/build/pi/lib -L./piper/build/si/lib -lfmt -lspdlog -lucd

# warnings
CFLAGS   += -Wall -Wextra -Wpedantic -Wcast-qual -Wdouble-promotion -Wshadow -Wstrict-prototypes -Wpointer-arith -Wno-unused-function
CXXFLAGS += -Wall -Wextra -Wpedantic -Wcast-qual -Wno-unused-function
#
# Print build information
#

$(info I go-piper build info: )
piper.o:
	mkdir -p piper/build
	mkdir -p piper-phonemize/pi
	mkdir -p espeak/ei
	cd espeak/ei && cmake .. -DUSE_ASYNC:BOOL=OFF -DBUILD_SHARED_LIBS:BOOL=ON -DUSE_MBROLA:BOOL=OFF -DUSE_LIBPCAUDIO:BOOL=OFF -DUSE_KLATT:BOOL=OFF -DUSE_SPEECHPLAYER:BOOL=OFF -DBUILD_ESPEAK_NG_TESTS:BOOL=OFF -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON -DEXTRA_cmn:BOOL=ON -DEXTRA_ru:BOOL=ON -DCMAKE_C_FLAGS="-D_FILE_OFFSET_BITS=64" -DUSE_LIBSONIC:BOOL=OFF -DBUILD_SHARED_LIBS:BOOL=ON -DCMAKE_INSTALL_PREFIX:PATH=$(abspath ./)/espeak/ei -DCMAKE_BUILD_TYPE=Release && make install
	cd piper-phonemize/pi && cmake .. --debug-output -DCMAKE_INSTALL_PREFIX:PATH=$(abspath ./)/piper-phonemize/pi -DESPEAK_NG_DIR=$(abspath ./)/espeak/ei/ -DCMAKE_BUILD_TYPE=Release && make install
	if [ -d "$(abspath ./)/piper-phonemize/pi/lib64" ]; then cp -rfv piper-phonemize/pi/lib64/* piper-phonemize/pi/lib; fi
	cd piper/build && cmake .. -DPIPER_PHONEMIZE_DIR=$(abspath ./)/piper-phonemize/pi -DCMAKE_BUILD_TYPE=Release $(CMAKE_ARGS) && make
	cp piper/build/CMakeFiles/piper.dir/src/cpp/piper.cpp.o piper.o

gopiper.o: piper.o
	$(CXX) $(CXXFLAGS) gopiper.cpp -o gopiper.o -c $(LDFLAGS)

libpiper_binding.a: piper.o gopiper.o
	ar src libpiper_binding.a piper.o

example/main: libpiper_binding.a
	CGO_CXXFLAGS="${CXXFLAGS}" CGO_LDFLAGS="${LDFLAGS}" LIBRARY_PATH=${LIBRARY_PATH} go build -buildvcs=false -x -o example/main ./example

clean:
	rm -rf *.o
	rm -rf *.a
	rm -rf piper/build
	rm -rf piper-phonemize/pi
	rm -rf espeak/ei
	rm -rf example/main

docker-run:
	docker build -t piper . && docker run -v $(abspath ./):/build/go -ti --rm piper
