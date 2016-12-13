uniform vec2 u_center;

// get distance to center
float dist = distance(v_textureCoordinate, u_center);
dist = min(dist, distance(v_textureCoordinate, u_center + vec2(-1, 0)));
dist = min(dist, distance(v_textureCoordinate, u_center + vec2(1, 0)));
dist = min(dist * 3.0, 1.0);
dist = dist * dist * dist;

mediump vec3 rgb = gl_FragColor.xyz;
float grey = (rgb.x + rgb.y + rgb.z) / 3.0;

gl_FragColor = vec4((rgb * (1.0 - dist) + grey * dist) * (1.0 - dist * 0.7), 1.0);
