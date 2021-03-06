#ifdef GL_ES
precision mediump float;
#endif
 
uniform vec2 resolution;
uniform float time;
uniform vec2 mouse;
void main( void ) {
 
    vec2 p = ( gl_FragCoord.xy / resolution.xy );
     
    vec2 rPos = p + vec2(fract(time)*2.0-1.0, sin(time*8.0)*0.3);
    vec2 gPos = p + vec2(fract(time+0.3)*2.0-1.0, cos(time*7.0)*0.3);
    vec2 bPos = p + vec2(fract(time+0.6)*2.0-1.0, 0.0);
     
    float r = 1.0-distance(rPos, vec2(0.5,0.5))*3.0;
    float g = 1.0-distance(gPos, vec2(0.5,0.5))*1.5;
    float b = 1.0-distance(bPos, vec2(0.5,0.5))*1.0;
     
    float v3 = 1.0-pow(p.y-sin(p.x*8.0+time)*0.3-0.5,0.5);
    float v4 = 1.0-pow(p.y-sin(p.x*3.0+time*2.0)*0.3-0.5,0.3);
     
    float a = time;
    float v = 0.0;
    vec2 c = mouse; //vec2(0.5,0.5);
     
    for (float i = 1.0; i<6.0; ++i)
    {
        a+=0.6;
         
        v += (1.0-clamp(
                       pow((c.x-p.x)*sin(a)+
                        (p.y-c.y)*cos(a),0.8)*100.0,
                       0.0,1.0)) / (i*0.5);
    }
     
     
    gl_FragColor = vec4(v+r+v3+v4, g+v4-v3, b+v-v4,1.0);
}
