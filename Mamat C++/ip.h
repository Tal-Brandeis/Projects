#ifndef IP_H
#define IP_H

#include "field.h"
#include <bitset>
	
class Ip : public Field {
private:
    String ip_rule;
    int mask;
    char *ip_to_binary(String ip)const;

    
public:
	/**
     * @brief Initiates an empty Ip obj, while setting Field(pattern)
     */
    Ip(String pattern);
    /**
     * @brief destroys Ip obj
     */
    ~Ip();
    /**
     * @brief the function gets a String and set it's data as ip_rule,
     * the rule is stored as a binary code in mask len(using ip_to_binary func).
     * @param String val, receives the required String to be set as rule.
     * @return true if set_value was succesful, false otherwise.
    **/
    bool set_value(String val);
    /**
     * @brief the func gets a String packet the packets data is converted
     * to binary code and checked for equallity with ip_rule.
     * @param String packet, receives the required packet to be checked.
     * @return true if packet macthes the rule and is legal, false otherwise.
    **/
    bool match_value(String packet) const;
};


#endif
