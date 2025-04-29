# =======================  Makefile  ==========================================
SRC_DIR := src/main/cpp
SRC     := $(SRC_DIR)/native.cpp
TARGET  := native

UNAME_S := $(shell uname -s)

ifeq ($(UNAME_S),Darwin)
    CXX      := $(shell command -v clang++ 2>/dev/null || echo g++)
    LIB_EXT  := dylib
    OS_INC   := darwin
    SHARED   := -dynamiclib -Wl,-install_name,@rpath/lib$(TARGET).$(LIB_EXT)
else ifeq ($(UNAME_S),Linux)
    CXX      ?= g++
    LIB_EXT  := so
    OS_INC   := linux
    SHARED   := -shared -Wl,-soname,lib$(TARGET).$(LIB_EXT)
else
    CXX      ?= g++
    LIB_EXT  := dll
    OS_INC   := win32
    SHARED   := -shared
endif

OUT_FILE := lib$(TARGET).$(LIB_EXT)

JNI_INC  := -I"$(JAVA_HOME)/include" -I"$(JAVA_HOME)/include/$(OS_INC)"
CXXFLAGS += -std=c++17 -fPIC $(JNI_INC) -O2
LDFLAGS  += $(SHARED)

all: $(OUT_FILE)

$(OUT_FILE): $(SRC)
	@echo "➜ linking $(OUT_FILE) with $(CXX)"
	$(CXX) $(CXXFLAGS) $< -o "$@" $(LDFLAGS)

clean:
	$(RM) $(OUT_FILE)

## ---------- Gradle  ------------------------------------------------------
build:                         # Kotlin derle + header üret
	./gradlew build

run: $(OUT_FILE)               # Native kütüphane hazırsa >>> run
	./gradlew run

.PHONY: all clean build run