#ifndef GDCLINPUT_H
#define GDCLINPUT_H

#include <Godot.hpp>
#include <Node.hpp>

namespace godot {

class CLInput : public Node {
    GODOT_CLASS(CLInput, Node)

public:
    static void _register_methods();

    CLInput();
    ~CLInput();

    void _init(); // our initializer called by Godot

    String read_line();
};

}

#endif