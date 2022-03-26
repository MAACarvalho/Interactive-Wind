#version 410

in vec4 position;
in vec3 normal;
in vec2 texCoord0;

out Data {

    vec3 normal;
    vec2 texture_coord;

} DataOut;

uniform mat4 m_model;

void main() {

    DataOut.normal          = normalize(normal);
    DataOut.texture_coord   = texCoord0;

    gl_Position             = m_model * position;

}