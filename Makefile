C_FILES=$(wildcard c/*.c)
O_FILES=$(C_FILES:c/%.c=build/%.o)
EXECUTABLE=a.out
USR_LOCAL=/usr/local
#USR_LOCAL=/Users/clmuser/Adobe/brew

CFLAGS=-Wno-deprecated-declarations -I$(USR_LOCAL)/include/luajit-2.0 -Ic
LDFLAGS=-lluajit -L$(USR_LOCAL)/lib -pagezero_size 10000 -image_base 100000000

.PHONY: all clean

all: a.out
clean:
	rm -f $(O_FILES) $(EXECUTABLE)
	rm -rf build


$(EXECUTABLE): $(O_FILES)
	clang $^ -o $@ -framework OpenGL -framework GLUT $(LDFLAGS)

build:
	mkdir -p build

build/%.o: c/%.c build
	clang -c $< $(CFLAGS) -o $@
