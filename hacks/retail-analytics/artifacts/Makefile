
TARGET=archive.zip
OBJS=main.tf variables.tf runtime.yaml setup.sh

$(TARGET): $(OBJS)
	zip $(TARGET) $(OBJS)

clean:
	rm -f $(TARGET) 
