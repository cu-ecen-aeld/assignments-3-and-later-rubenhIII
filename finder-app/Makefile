SOURCES = writer.c
OBJS = $(SOURCES:.c=.o)
TARGET = writer

CROSS_COMPILE =#aarch64-none-linux-gnu-#Cross-Compile Toolchain 
CC = gcc
OPTS = -Wall # flags
LIBS = #-lm # libraries

all: $(TARGET)
$(TARGET): $(OBJS)
	$(CROSS_COMPILE)$(CC) -o $(TARGET) $(OBJS) $(LIBS)

%.o: %.c
	$(CROSS_COMPILE)$(CC) $(OPTS) -c $< -o $@
clean:
	rm -f $(OBJS) $(TARGET)
