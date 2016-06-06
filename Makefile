C_FILES=$(wildcard *.c)
O_FILES=$(C_FILES:%.c=%.o)
EXECUTABLE=a.out
USR_LOCAL=/usr/local
#USR_LOCAL=/Users/clmuser/Adobe/brew

CFLAGS=-Wno-deprecated-declarations -I$(USR_LOCAL)/include/luajit-2.0
LDFLAGS=-lluajit -L$(USR_LOCAL)/lib -pagezero_size 10000 -image_base 100000000

.PHONY: all clean

all: a.out
clean:
	rm -f $(O_FILES) $(EXECUTABLE)


$(EXECUTABLE): $(O_FILES)
	clang $^ -o $@ -framework OpenGL -framework GLUT $(LDFLAGS)

%.o: %.c
	clang -c $< $(CFLAGS)
