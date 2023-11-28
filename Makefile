INCLUDE_PATH := $(abspath ./)
LIBRARY_PATH := $(abspath ./)


BUILD_TYPE?=
# keep standard at C11 and C++11
CFLAGS   = -I. -I./piper/src/cpp -I./piper/build/fi/include -I./piper/build/pi/include -I./piper/build/si/include -O3 -DNDEBUG -std=c11 -fPIC
CXXFLAGS = -I. -I./piper/src/cpp -I./piper/build/fi/include -I./piper/build/pi/include -I./piper/build/si/include -O3 -DNDEBUG -std=c++17 -fPIC
LDFLAGS  = -L./piper/build/fi/lib -L./piper/build/pi/lib -L./piper/build/si/lib -lfmt -lspdlog -lucd

# warnings
CFLAGS   += -Wall -Wextra -Wpedantic -Wcast-qual -Wdouble-promotion -Wshadow -Wstrict-prototypes -Wpointer-arith -Wno-unused-function
CXXFLAGS += -Wall -Wextra -Wpedantic -Wcast-qual -Wno-unused-function
#
# Print build information
#

$(info I go-piper build info: )

piper.o:
	mkdir -p piper/build
	cd piper/build && cmake .. -DCMAKE_BUILD_TYPE=Release $(CMAKE_ARGS) && make
	cp piper/build/CMakeFiles/piper.dir/src/cpp/piper.cpp.o piper.o

gopiper.o:
	$(CXX) $(CXXFLAGS) gopiper.cpp -o gopiper.o -c $(LDFLAGS)

libpiper_binding.a: piper.o gopiper.o
	ar src libpiper_binding.a piper.o

example/main: libpiper_binding.a
	CGO_CXXFLAGS="${CXXFLAGS}" CGO_LDFLAGS="${LDFLAGS}" LIBRARY_PATH=${LIBRARY_PATH} go build -buildvcs=false -x -o example/main ./example

clean:
	rm -rf *.o
	rm -rf *.a
	rm -rf piper/build
	rm -rf example/main

docker-run:
	docker build -t piper . && docker run -v $(abspath ./):/build/go -ti --rm piper
