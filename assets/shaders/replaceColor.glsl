// aca iniciamos el color de entrada y salida
extern vec3 colorI, colorO;

// proceso principal
vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
    vec4 pixel = Texel(texture,texture_coords);
    if (pixel == vec4(colorI,pixel.a)) pixel = vec4(colorO,pixel.a);
    return pixel * color;
}