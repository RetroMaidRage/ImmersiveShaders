float waterH(vec3 posxz, float frametimecounter) {

float wave = 10.0;


float factor = 2.0;
float amplitude = 0.2;
float speed = 4.0;
float size = 0.2;

float px = posxz.x/50.0 + 250.0;
float py = posxz.z/50.0  + 250.0;

float fpx = abs(fract(px*20.0)-0.5)*2.0;
float fpy = abs(fract(py*20.0)-0.5)*2.0;

float d = length(vec2(fpx,fpy));

for (int i = 1; i < 4; i++) {
	wave -= d*factor*cos( (1/factor)*px*py*size + 1.0*frametimecounter*speed);
	factor /= 2;
}

factor = 1.0;
px = -posxz.x/50.0 + 250.0;
py = -posxz.z/150.0 - 250.0;

fpx = abs(fract(px*20.0)-0.5)*2.0;
fpy = abs(fract(py*20.0)-0.5)*2.0;

d = length(vec2(fpx,fpy));
float wave2 = 0.0;
for (int i = 1; i < 4; i++) {
	wave2 -= d*factor*cos( (1/factor)*px*py*size + 1.0*frametimecounter*speed);
	factor /= 2;
}

return amplitude*wave2+amplitude*wave;
}
