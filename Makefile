CC=clang
BUILD_DIR=build
EXECUTABLE=a.out
USR_LOCAL=/usr/local
#USR_LOCAL=/Users/clmuser/Adobe/brew


C_FILES=$(wildcard c/*.c)
O_FILES=$(C_FILES:c/%.c=$(BUILD_DIR)/%.o)

CFLAGS=-Wno-deprecated-declarations -I$(USR_LOCAL)/include/luajit-2.0 -Ic
LD_FRAMEWORKS=-framework OpenGL -framework GLUT
LD_LUAJIT=-lluajit -pagezero_size 10000 -image_base 100000000
LDFLAGS=-L$(USR_LOCAL)/lib $(LD_FRAMEWORKS) $(LD_LUAJIT)

.PHONY: all clean

all: $(EXECUTABLE)
clean:
	rm -f $(O_FILES) $(EXECUTABLE)
	rm -rf $(BUILD_DIR)


$(EXECUTABLE): $(O_FILES)
	$(CC) $^ -o $@ $(LDFLAGS)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/%.o: c/%.c $(BUILD_DIR)
	$(CC) -c $< $(CFLAGS) -o $@
