C_FILES=$(wildcard *.c)
O_FILES=$(C_FILES:%.c=%.o)
EXECUTABLE=a.out

CFLAGS=-Wno-deprecated-declarations -I/usr/local/include/luajit-2.0
LDFLAGS=-lluajit -L/usr/local/lib

.PHONY: all clean

all: a.out
clean:
	rm -f $(O_FILES) $(EXECUTABLE)


$(EXECUTABLE): $(O_FILES)
	clang $^ -o $@ -framework OpenGL -framework GLUT $(LDFLAGS)

%.o: %.c
	clang -c $< $(CFLAGS)
