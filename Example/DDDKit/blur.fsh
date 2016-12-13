uniform vec2 u_scale;
const int steps = 4;

// create gaussian mix
float gauss[2 * steps + 1];
float total = 0.0;
for(int i=0; i<=2 * steps; i++) {
	gauss[i] = exp(float(-i * i));
}
for(int i = -steps; i<=steps; i++) {
	int ai = i < 0 ? -i : i;
	for(int j = -steps; j<=steps; j++) {
		int aj = j < 0 ? -j : j;
		total += gauss[ai + aj];
	}
}
for(int i=0; i<=2 * steps; i++) {
	gauss[i] /= total;
}

// compute pixel result
vec3 color = vec3(0, 0, 0);
for(int i = -steps; i<=steps; i++) {
	float fi = float(i);
	int ai = i < 0 ? -i : i;
	for(int j = -steps; j<=steps; j++) {
		float fj = float(j);
		int aj = j < 0 ? -j : j;
		color += pixelAt(v_textureCoordinate + vec2(fi, fj) * u_scale / float(steps)) * gauss[ai + aj];
	}
}

gl_FragColor = vec4(color, 1.0);
