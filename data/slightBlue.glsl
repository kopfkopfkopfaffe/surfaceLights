#ifdef GL_ES
precision mediump float; 
#endif

uniform float time;
uniform vec2 resolution;

// Fractal Soup - @P_Malin

vec2 CircleInversion(vec2 vPos, vec2 vOrigin, float fRadius)
{	
	vec2 vOP = vPos - vOrigin;
	return vOrigin - vOP * fRadius * fRadius / dot(vOP, vOP);
}

float Parabola( float x, float n )
{
	return pow( 4.0*x*(1.0-x), n );
}

void main(void)
{
	vec2 vPos = gl_FragCoord.xy / resolution.xy;
	vPos = vPos - 0.5;
	
	vPos.x *= resolution.x / resolution.y;
	
	vec2 vScale = vec2(1.2);
	vec2 vOffset = vec2( sin(time * 0.123), sin(time * 0.0567));

	float l = 0.0;
	float minl = 10000.0;
	
	for(int i=0; i<48; i++)
	{
		vPos.x = abs(vPos.x);
		vPos = vPos * vScale + vOffset;	
		
		vPos = CircleInversion(vPos, vec2(0.5, 0.5), 1.0);
		
		l = length(vPos);
		minl = min(l, minl);
	}
	
	
	float t = 4.1 + time * 0.025;
	vec3 vBaseColour = normalize(vec3(sin(t * 1.890), sin(t * 1.345), sin(t * 1.123)) * 0.5 + 0.5);

	//vBaseColour = vec3(1.0, 0.15, 0.05);
	
	float fBrightness = 15.0;
	
	vec3 vColour = vBaseColour * l * l * fBrightness;
	
	minl = Parabola(minl, 5.0);	
	
	vColour *= minl + 0.1;
	
	vColour = 1.0 - exp(-vColour);
	gl_FragColor = vec4(vColour,1.0);
}

