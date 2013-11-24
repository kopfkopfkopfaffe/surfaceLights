#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

vec3 pip(vec2 take, int i) {
	vec3 po = vec3(take, 0);
	for(int i = 0; i < 4; i++) {
		po.x = sin(po.y*1.4)-cos(po.x*-2.3);
		po.y = sin((mouse.x-0.5)*po.x/1.0)-cos((mouse.y-0.5)*po.y);
		po.z = sin(po.x+po.y);
		po.xy += take;
	}
	return sin(po.brg);
}

vec3 inf(vec2 take) {
	return pip(take, 100);
}

void main( void ) {
	gl_FragColor = vec4(inf((gl_FragCoord.xy/resolution.xy-0.5)*10.0), 1.0);
}
