CXX=g++
CXXLINK=$(CXX)
CXXFLAGS=-g -Wall -std=c++11
EXEC=firewall.exe
OBJS=field.o ip.o port.o string.o
RM=rm -rf main.o field.o ip.o port.o string.o libfirewall.so firewall.exe

#links main.o to executable, linking libfirewall.so and libinput.so.
$(EXEC):libfirewall.so main.o
	$(CXXLINK) main.o -o $(EXEC) -lfirewall -L. -linput -L.

#link OBJS to libfirewall.so
libfirewall.so: $(OBJS)
	$(CXXLINK) -shared $(OBJS) -o libfirewall.so -L.

#compile main.cpp if any of these changed
main.o: main.cpp field.h ip.h port.h string.h
	$(CXX) $(CXXFLAGS) -c -fpic main.cpp -lfirewall -L. -linput -L.

#compile string.cpp if any of these changed
string.o: string.cpp string.h 
	$(CXX) $(CXXFLAGS) -c -fpic string.cpp
	
#compile field.cpp if any of these changed
field.o: field.cpp field.h string.h
	$(CXX) $(CXXFLAGS) -c -fpic field.cpp

#compile ip.cpp if any of these changed
ip.o: ip.cpp ip.h field.h
	$(CXX) $(CXXFLAGS) -c -fpic ip.cpp

#compile port.cpp if any of these changed
port.o: port.cpp port.h field.h
	$(CXX) $(CXXFLAGS) -c -fpic port.cpp




#clean files, manually called
clean:
	$(RM)