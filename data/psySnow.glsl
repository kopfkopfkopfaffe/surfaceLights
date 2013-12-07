#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;
varying vec2 surfacePosition;

vec3 hsv(in float h, in float s, in float v)
{
	return mix(vec3(1.0), clamp((abs(fract(h + vec3(3, 2, 1) / 3.0) * 6.0 - 3.0) - 1.0), 0.0 , 1.0), s) * v;
}

void main( void ) {

	vec2 uv = surfacePosition;
	vec2 p = uv;
	const float pi = 3.14159;
	float d = 999.0;
	vec2 c = mouse*2.0-1.0;
	for (int i = 0; i < 15; i++) {
		p = abs(mod(vec2(p.y,-p.x)/dot(p,p)+c,pi/2.0)-pi/4.0);
		p = vec2(p.x*p.x-p.y*p.y, 2.0*p.x*p.y)+c;
		d = min(d, log(exp(p.x)+exp(p.y)));
	}

	gl_FragColor = vec4( hsv(d*4.0,1.0,1.0),1.0 );

}
