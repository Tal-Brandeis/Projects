#ifndef PORT_H
#define PORT_H

#include "field.h"
	
class Port : public Field {
private:
  	int min_port;
  	int max_port;


public:
    /**
     * @brief Initiates an empty object
     */	
    Port(String pattern);

    ~Port();

    /**
     * @brief Sets the min/max values of the class that determine the rule.
     * @param val - The func receives the rule in the format "MIN-MAX", with
     * arbitrary spaces at the beginning and at the end.
	 * @returns "false" if an error occurred, and "true" otherwise.
     */
    bool set_value(String val);

    /**
     * @brief Receives a parsed packet and checks whether it matches the rule.
     * @param packet - The func receives the packet that will be checked in
     * the format "PRT".
	 * @returns "true" if the packet is valid, and "false" otherwise.
     */
    bool match_value(String packet) const;
};



#endif
