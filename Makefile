INCLUDE_PATH := $(abspath ./)
LIBRARY_PATH := $(abspath ./)


BUILD_TYPE?=
# keep standard at C11 and C++11
CFLAGS   = -I./ -I./piper/src/cpp/ -O3 -DNDEBUG -std=c11 -fPIC
CXXFLAGS = -I./ -I./piper/src/cpp/ -O3 -DNDEBUG -std=c++17 -fPIC
LDFLAGS  = -lspdlog

# warnings
CFLAGS   += -Wall -Wextra -Wpedantic -Wcast-qual -Wdouble-promotion -Wshadow -Wstrict-prototypes -Wpointer-arith -Wno-unused-function
CXXFLAGS += -Wall -Wextra -Wpedantic -Wcast-qual -Wno-unused-function
#
# Print build information
#

$(info I go-piper build info: )

piper.o:
	mkdir -p piper/build
	cd piper/build && cmake ../src/cpp -DCMAKE_BUILD_TYPE=Release $(CMAKE_ARGS) && make
	cp piper/build/CMakeFiles/piper.dir/piper.cpp.o piper.o

gopiper.o:
	$(CXX) $(CXXFLAGS) gopiper.cpp -o gopiper.o -c $(LDFLAGS)

libpiper_binding.a: piper.o gopiper.o
	ar src libpiper_binding.a piper.o

example/main: libpiper_binding.a
	LIBRARY_PATH=${LIBRARY_PATH} go build -buildvcs=false -x -o example/main ./example

clean:
	rm -rf *.o
	rm -rf *.a
	rm -rf piper/build
	rm -rf example/main

docker-run:
	docker build -t piper . && docker run -v $(abspath ./):/build/go -ti --rm piper