

#version 100
uniform highp mat4 u_Projection;
uniform highp mat4 u_ModelView;
attribute vec4 a_Position;
attribute vec4 a_Color;
varying mediump vec4 v_Color;

void main(void) {
    v_Color = a_Color;
    gl_Position = u_Projection * u_ModelView * a_Position;
}


