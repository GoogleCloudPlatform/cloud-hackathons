TARGET=student-files.zip
OBJS=*

$(TARGET): $(OBJS)
	zip -r $(TARGET) $(OBJS) -x Makefile

clean:
	rm -f $(TARGET) 
