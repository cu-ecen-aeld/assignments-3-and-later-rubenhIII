SOURCES = writer.c
OBJS = $(SOURCES:.c=.o)
TARGET = writer

CROSS_COMPILE = #Cross-Compile Toolchain 
CC = gcc
OPTS = -Wall # flags
LIBS = #-lm # libraries

$(TARGET): $(OBJS)
	$(CROSS_COMPILE)$(CC) -o $(TARGET) $(OBJS) $(LIBS)

%.o: %.c
	$(CROSS_COMPILE)$(CC) $(OPTS) -c $< -o $@
clean:
	rm -f $(OBJS) $(TARGET)
