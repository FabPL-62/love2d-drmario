// aca iniciamos el color de entrada y salida
extern vec3 colorI, colorO;

// tolerancia de cambio
extern vec3 colorT;

// factor alpha externo
extern number alpha;

vec4 rgb_to_hsv(vec4 col)
{
    number H = 0.0;
    number S = 0.0;
    number V = 0.0;
    
    number M = max(col.r, max(col.g, col.b));
    number m = min(col.r, min(col.g, col.b));
    
    V = M;
    
    number C = M - m;
    
    if (C > 0.0)
    {
        if (M == col.r) H = mod( (col.g - col.b) / C, 6.0);
        if (M == col.g) H = (col.b - col.r) / C + 2.0;
        if (M == col.b) H = (col.r - col.g) / C + 4.0;
        H /= 6.0;
        S = C / V;
    }
    
    return vec4(H, S, V, col.a);
}

vec4 hsv_to_rgb(vec4 col)
{
    number H = col.r;
    number S = col.g;
    number V = col.b;
    
    number C = V * S;
    
    H *= 6.0;
    number X = C * (1.0 - abs( mod(H, 2.0) - 1.0 ));
    number m = V - C;
    C += m;
    X += m;
    
    if (H < 1.0) return vec4(C, X, m, col.a);
    if (H < 2.0) return vec4(X, C, m, col.a);
    if (H < 3.0) return vec4(m, C, X, col.a);
    if (H < 4.0) return vec4(m, X, C, col.a);
    if (H < 5.0) return vec4(X, m, C, col.a);
    else         return vec4(C, m, X, col.a);
}

// proceso principal
vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
    vec4 pixel = Texel(texture,texture_coords);
    vec4 pixel_hsv = rgb_to_hsv(pixel);
    vec4 input_hsv = rgb_to_hsv(vec4(colorI,1.0));
    vec4 delta     = pixel_hsv - input_hsv;

    if (all(lessThanEqual(abs(delta),vec4(colorT,1.0))))
    {
        number M = max(pixel.r, max(pixel.g, pixel.b));
        number m = min(pixel.r, min(pixel.g, pixel.b));
        pixel = vec4((colorO.rgb * (M - m) + ((colorO.r + colorO.g + colorO.b) * (1.0 - M) / 3.0 + 1.0) * m), pixel.a);
    }

    pixel = vec4(pixel.r,pixel.g,pixel.b,pixel.a*alpha);

    return pixel * color;
}