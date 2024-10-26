uniform float iTime;
void main()
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = openfl_TextureCoordv;
    vec4 col = flixel_texture2D(bitmap,uv);
    uv.x += (sin(4.*uv.y+iTime)/20.) * float(1. - col.rgb);
    uv.y += (sin(4.*uv.x+iTime)/20.) * float(1. - col.rgb);
    // Time varying pixel color
    
    // Output to screen
    gl_FragColor = flixel_texture2D(bitmap,uv);
}
