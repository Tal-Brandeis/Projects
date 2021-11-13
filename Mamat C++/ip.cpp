#include "field.h"
#include "ip.h"
#include <bitset>
#include <cstring>
#include <cstdlib>
	
#define BYTE_SIZE 8
#define MASK_DELIM "/"
#define IP_DELIM "."
#define NUM_OF_BYTES 4
    
    /**
     * @brief the function gets a String and converts it's data to binary,
     * returnes the binary code as char* after being trimmed accroding to mask
     * @param String ip The func receives the required String to be proccesed.
     * @return char*(in mask length) of ip->data converted to binary.
    **/
    char *Ip::ip_to_binary(String ip)const{

        String *p_string;
        size_t size = 0; 
        ip.split(IP_DELIM, &p_string, &size);
        std::string tmp;
        
        //build a binary string from 4 bytes of ip, for each convert to int,
        // and then convert to bin string.
        for (size_t i = 0; i < size; i++){
            int curr_byte=(p_string[i]).to_integer();
            tmp+=std::bitset<BYTE_SIZE>(curr_byte).to_string();
        }
        tmp=tmp.substr(0,mask);
        delete[] p_string;
        return strcpy(new char[tmp.length()+1],tmp.data());
    }



    Ip::Ip(String pattern) : Field(pattern){
    }
        

    Ip::~Ip(){
    }

    bool Ip::set_value(String val)  {
    	
        String *p_string;
        size_t size = 0; 
        val.split(MASK_DELIM, &p_string, &size);
        String ip_tmp = (p_string[0]).trim();
        String mask_tmp = (p_string[1]).trim();

        mask = mask_tmp.to_integer();
        char *binary = ip_to_binary(ip_tmp);
        ip_rule = binary;

        delete[] binary;
        delete[] p_string;

        if ((size!=NUM_OF_BYTES+1)||(&ip_rule==NULL)){ 
            return false;
        }
        return true;
    }

    bool Ip::match_value(String packet) const{
        char *tmp=ip_to_binary(packet);
        String curr_ip=String(tmp);
        delete[] tmp;
        if(ip_rule.equals(curr_ip)){

        return true;
       }

        return false;
    }
