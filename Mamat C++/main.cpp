#include <cstring>
#include "string.h"
#include "field.h"
#include "input.h"
#include "ip.h"
#include "port.h"
#include <iostream>


#define ERROR 1
#define SUCCESS 0

#define IP_TYPE_DST "dst-ip"
#define IP_TYPE_SRC "src-ip"
#define PORT_TYPE_DST "dst-port"
#define PORT_TYPE_SRC "src-port"
#define DELIM "="


/**
 * @brief The func receives as an argument a rule for the packet, and an stdin
 * with a list of packets. The func filters the packets that match the rule 
 * and prints them.
 * @param argc - The func receives the num of arguments.
 * @param argv - The func receives the required rule.
 * @returns "1" if an error occurred, and "0" otherwise.
 * @note The func filters the packets using the parse input function from the
 * libinput library.
**/
int main(int argc, char *argv[]) {
    bool check = check_args(argc, argv);
    if (check != SUCCESS) {
        return ERROR;
    }

    int len = strlen(argv[1]);
    for (int i = 0; i < len; i++) {
        if ((argv[1])[i] == ','){
            (argv[1])[i] = ' ';
        }
    }

    String tmp = argv[1];
    tmp=tmp.trim();
    String *p_string = NULL;
    size_t size; 
    tmp.split(DELIM, &p_string, &size);
    for (size_t i = 0; i < size; i++) {
        p_string[i]=(p_string[i]).trim();
    }

    Field *rule;

    if (((p_string[0]).equals(IP_TYPE_SRC))
                ||((p_string[0]).equals(IP_TYPE_DST))) {
        rule = new Ip(p_string[0]);
                    
     } else if(((p_string[0]).equals(PORT_TYPE_SRC))
                ||((p_string[0]).equals(PORT_TYPE_DST))){
        rule = new Port(p_string[0]);
    }

    rule->set_value(p_string[1]);
    parse_input(*rule);
    delete rule;
    delete[] p_string;

    return SUCCESS;
}
