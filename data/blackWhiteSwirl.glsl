#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

void main( void ) {

	vec2 position = ( gl_FragCoord.xy / resolution.xy ) * time + time;
	float d1 = distance(gl_FragCoord.xy / resolution.xy, mouse.xy + vec2(0.03,cos(time*1.17)/5.0));
	float d2 = distance(gl_FragCoord.xy / resolution.xy, mouse.xy - vec2(0.03,sin(time*1.29)/5.0));
	

	gl_FragColor +=  vec4(sin(d1*130.0+time*1.0) * sin(d2*130.0+time*1.0) / 2.0 );
}
