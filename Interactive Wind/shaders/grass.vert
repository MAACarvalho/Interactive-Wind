#version 410

uniform mat4 m_model;

in vec4 position;

void main() {

    gl_Position = m_model * position; 

}



