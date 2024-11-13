.PHONY: all run clean

AS = as
ASFLAGS = --64

LD = ld

all: randword.o
	$(LD) -o randword randword.o

randword.o: randword.s
	$(AS) $(ASFLAGS) -o $@ $<

run: randword
	./randword

clean:
	rm -f randword *.o
