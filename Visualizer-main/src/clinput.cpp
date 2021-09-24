#include "clinput.h"
#include <iostream>
#include <string>

using namespace godot;

void CLInput::_register_methods() {
    register_method("read_line", &CLInput::read_line);
}

CLInput::CLInput() {
}

CLInput::~CLInput() {
    // add your cleanup here
}

void CLInput::_init() {
    // initialize any variables here
}

String CLInput::read_line() {
    std::string input;
    std::getline(std::cin, input);
    return String(input.c_str());
}