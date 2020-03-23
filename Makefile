
CMAKE=cmake
ifeq (MINGW,$(findstring MINGW,$(shell uname)))
CMAKE_TARGET = "MSYS Makefiles"
else
CMAKE_TARGET = "Unix Makefiles"
endif

CFLAGS=-O3
CXXFLAGS=$(CFLAGS) -Iinstall/include/antlr4-runtime -std=c++11 -DANTLR4CPP_STATIC
LDFLAGS=-Linstall/lib -Bstatic -lantlr4-runtime -lstdc++ -Bdynamic -static-libgcc

CPP_FILES=modelicaBaseListener.cpp  modelicaBaseVisitor.cpp  modelicaLexer.cpp  modelicaListener.cpp  modelicaParser.cpp  modelicaVisitor.cpp
H_FILES=$(patsubst %.cpp,%.h,$(CPP_FILES))
OBJS=$(patsubst %.cpp,%.o,$(CPP_FILES))

all: libomcparserantlr4.a

libomcparserantlr4.a: $(OBJS)
	$(AR) -s -r $@ $(OBJS)

$(OBJS): $(CPP_FILES) install/lib/libantlr4-runtime.a

3rdParty/antlr4/runtime/Cpp/build/Makefile: 
	(cd 3rdParty/antlr4/runtime/Cpp/build && $(CMAKE) -DCMAKE_VERBOSE_MAKEFILE:Bool=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_COLOR_MAKEFILE:Bool=OFF -DCMAKE_INSTALL_PREFIX:String=../../../../../install ../ -G $(CMAKE_TARGET))

install/lib/libantlr4-runtime.a: 3rdParty/antlr4/runtime/Cpp/CMakeLists.txt
	mkdir -p 3rdParty/antlr4/runtime/Cpp/build
	$(MAKE) 3rdParty/antlr4/runtime/Cpp/build/Makefile
	$(MAKE) -C 3rdParty/antlr4/runtime/Cpp/build/ install

$(CPP_FILES): runtool

runtool: modelica.g4
	java -cp 3rdParty/antlr4/tool/antlr-4.8-complete.jar org.antlr.v4.Tool -Dlanguage=Cpp -package openmodelica -listener -visitor  modelica.g4

test: libomcparserantlr4.a
	$(MAKE) -C test

clean-local:
	rm -rf libomcparserantlr4.a $(OBJS) $(CPP_FILES) $(H_FILES) *.interp *.tokens
	$(MAKE) -C test clean

clean-runtime:
	rm -rf 3rdParty/antlr4/runtime/Cpp/build/ 3rdParty/antlr4/runtime/Cpp/dist/ install
	
clean: clean-local clean-runtime