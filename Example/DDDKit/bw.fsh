float grey = (gl_FragColor.x + gl_FragColor.y + gl_FragColor.z) / 3.0;
gl_FragColor = vec4(grey, grey, grey, 1.0);
