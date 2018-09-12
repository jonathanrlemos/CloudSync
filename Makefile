# makefile
#
# Copyright (c) 2018 Jonathan Lemos
#
# This software may be modified and distributed under the terms
# of the MIT license.  See the LICENSE file for details.

NAME=cloudsync
VERSION=0.1\ beta
SHELL=/bin/sh

CXX:=g++
CXXFLAGS:=-Wall -Wextra -pedantic -std=c++17 -DPROG_NAME=\"$(NAME)\" -DPROG_VERSION=\"$(VERSION)\"
CXXDBGFLAGS:=-g -fsanitize=address -fno-omit-frame-pointer
CXXRELEASEFLAGS:=-O2
LDFLAGS=-lmega

DIRECTORIES=$(shell find . -type d 2>/dev/null | sed -re 's|^.*\.git.*$$||;s|.*/sdk.*$$||;s|^.*/tests.*$$||' | awk 'NF')
FILES=$(foreach directory,$(DIRECTORIES),$(shell ls $(directory) | egrep '^.*\.cpp$$' | sed -re 's|^.*main.cpp$$||;s|^(.+)\.cpp$$|\1|'))
TESTS=$(shell find tests -type f -name '*.cpp' 2>/dev/null | sed -re 's|^(.+)cstest/$$||;s|^(.+)\.cpp$$|\1|')
FRAMEWORKFILES=$(shell ls tests/cstest | sed -re 's|^(.+)\.cpp$$|\1|')

SOURCEFILES=$(foreach file,$(FILES),$(file).cpp)
OBJECTS=$(foreach file,$(FILES),$(file).o)
DBGOBJECTS=$(foreach file,$(FILES),$(file).dbg.o)
TESTOBJECTS=$(foreach test,$(TESTS),$(test).dbg.o)
TESTEXECS=$(foreach test,$(TESTS),$(test).x)
FRAMEWORKOBJECTS=$(foreach frameworkfile,$(FRAMEWORKFILES),$(frameworkfile).dbg.o)

release: main.o $(OBJECTS)
	$(CC) -o $(NAME) main.o $(OBJECTS) $(CXXFLAGS) $(LDFLAGS) $(RELEASEFLAGS)

debug: main.dbg.o $(DBGOBJECTS)
	$(CC) -o $(NAME) main.dbg.o $(DBGOBJECTS) $(CXXFLAGS) $(DBGFLAGS) $(LDFLAGS)

.PHONY: docs
docs:
	doxygen Doxyfile

test: $(TESTEXECS)
	@echo "Made all tests"

%.x: $(DBGOBJECTS) $(FRAMEWORKOBJECTS)
	$(CXX) -o $@ $< $(FRAMEWORKOBJECTS) $(DBGOBJECTS) $(CXXFLAGS) $(DBGFLAGS) $(LDFLAGS)

%.o: %.cpp
	$(CXX) -c -o $@ $< $(CFLAGS) $(RELEASEFLAGS)

%.dbg.o: %.cpp
	$(CXX) -c -o $@ $< $(CFLAGS) $(DBGFLAGS)

.PHONY: clean
clean:
	rm -f *.o $(NAME) main.c.* vgcore.* $(TESTOBJECTS) $(DBGOBJECTS) $(OBJECTS) $(TESTEXECS) $(FRAMEWORKOBJECTS)
	rm -rf docs

.PHONY: linecount
linecount:
	wc -l Makefile README.md $(foreach dir,$(DIRECTORIES),$(dir)/*.hpp $(dir)/*.cpp) $(foreach test,$(TESTS),$(test).cpp) $(foreach frameworkfile,$(FRAMEWORKFILES),$(frameworkfile).hpp $(frameworkfile).cpp) 2>/dev/null | sort -k2,2

.PHONY: linecount_notests
linecount_notests:
	wc -l Makefile README.md $(foreach dir,$(DIRECTORIES),$(dir)/*.hpp $(dir)/*.cpp) 2>/dev/null | sort -k2,2
