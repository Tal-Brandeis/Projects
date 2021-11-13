#include <stddef.h>
#include <iostream>
#include <cstring>
#include "string.h"

#define SUCCEES 0
#define FAIL 1

using namespace std;


    /**
     * @brief Receives a string, allocates a new string at the same length
     * and copies the contents.
     * param str - The string that should be copied.
     * param len - The length of the given string.
     * returns a pointer to the new string.
     */
    //static function
	static char *alloc_and_copy(const char *str, int len){
		return strcpy(new char[len + 1], str);
	}


    String::String() {
    	length = 0;
        data = alloc_and_copy("",length);
    }


    String::String(const String &str) {
        if (str.data == NULL){
            length = 0;
            data = alloc_and_copy("",length);
        } else{
    	length = str.length;
    	data = alloc_and_copy(str.data,length);
        }
    }


    String::String(const char *str) {
        if (str == NULL){
            length = 0;
            data = alloc_and_copy("",length);
        } else{
    	length = strlen(str);
    	data = alloc_and_copy(str,length);
        }
    }


    String::~String() {
    	delete[] data;
    }


    String& String::operator=(const String &rhs) {
    	if ((rhs.data == NULL)||this == &rhs) {
    		return *this;
    	}

    	delete[] data;
    	data = alloc_and_copy(rhs.data, rhs.length);
    	length = rhs.length;
    	return *this;
    }


    String& String::operator=(const char *str) {
    
        if ((str == NULL)||(strcmp(data, str) == SUCCEES)) {
    		return *this;
    	}

    	delete[] data;
    	length = strlen(str);
    	data = alloc_and_copy(str,length);
    	return *this;
    }


    bool String::equals(const String &rhs) const {
    	if (rhs.data == NULL){
            return false;
        }
        if ((strcmp(this->data, rhs.data) == SUCCEES)
    		&& (this->length == rhs.length)) {
    		return true;
    	}
    	return false;
    }


    bool String::equals(const char *rhs) const {
    	if (rhs == NULL){
            return false;
        }
        if ((strcmp(this->data, rhs) == SUCCEES)
    	    		&& (this->length == strlen(rhs))) {
    		return true;
    	}
    	return false;
    }


    void String::split(const char *delimiters,
    	String **output, size_t *size) const {
        int size_cnt = 0;
        std::string tmp=data;
        int start = 0;
        int delim_size = strlen(delimiters);

        //counts the number of substrings according to the delimeters
        for (size_t i = 0; i < length; i++) {
            for (int j = 0; j < delim_size; j++) {
                if (data[i] == delimiters[j]) {
                    start = i + 1;
                    size_cnt++;
                }
            }
            if ((i == (length - 1)) && (start < (int)length)) {
                size_cnt++;
            }
        }

        //splits the string only if the output isnt NULL        
        int cnt = 0;
        if (output != NULL) {
            start = 0;
            *output = new String[size_cnt];
            for (size_t i = 0; i < length; i++) {
                for (int j = 0; j < delim_size; j++) {
                    if (data[i] == delimiters[j]) {
                        (*output)[cnt]=(tmp.substr(start,i-start)).data();
                        start = i + 1;
                        cnt++;
                    }
                }
                if ((i == (length - 1)) && (start < (int)length)) {
                    (*output)[cnt]=(tmp.substr(start,i-start+1)).data();
                    cnt++;
                }
            }
        }

        *size = size_cnt;


    }


    int String::to_integer() const {
    	return atoi(data);
    }


    String String::trim() const {
    	std::string str_tmp=data;

        int start = str_tmp.find_first_not_of(" ");
    	int end = str_tmp.find_last_not_of(" ");
    	char new_str[(end-start+1)+1];
        for (int i = 0; i < (end-start+1); i++) {
            new_str[i]=data[start+i];
        }
        new_str[(end-start+1)]='\0';

        String tmp(new_str);
    	return tmp;
    }
