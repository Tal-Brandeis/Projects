#include "field.h"
#include "port.h"

#define BYTE_SIZE 8
#define PORT_DELIM "-"
#define RANGE 2


    Port::Port(String pattern) : Field(pattern){

    }

    Port::~Port(){

    }

    bool Port::set_value(String val) {
        String *p_string;
        size_t size = 0; 
        val.split(PORT_DELIM, &p_string, &size);

        String min_tmp = (p_string[0]).trim();
        String max_tmp = (p_string[1]).trim();

        min_port = min_tmp.to_integer();
        max_port = max_tmp.to_integer();

        delete[] p_string;

        if (size != RANGE){ 
            return false;
        }
        return true;
    }


    bool Port::match_value(String packet) const {
    	int curr_port = packet.to_integer();
    	if ((min_port <= curr_port) && (curr_port <= max_port)) {
    		return true;
    	}
    	return false;
    }
