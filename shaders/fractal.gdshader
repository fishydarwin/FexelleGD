shader_type canvas_item;

/*
 * FEXL FUNCTIONS IMPLEMENTATION
 */

highp vec2 fexl_add(vec2 a, vec2 b) {
	return vec2(a.x + b.x, a.y + b.y);
}

highp vec2 fexl_sub(vec2 a, vec2 b) {
	return vec2(a.x - b.x, a.y - b.y);
}

highp vec2 fexl_mul(vec2 a, vec2 b) {
	return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
}

highp vec2 fexl_div(vec2 a, vec2 b) {
	highp float sqr = b.x * b.x + b.y * b.y;
	return vec2((a.x * b.x + a.y * b.y) / sqr, 
				(a.x * b.y - a.y * b.x) / sqr);
}

highp vec2 fexl_abs(vec2 z) {
	return vec2(sqrt(z.x * z.x + z.y * z.y), 0);
}

highp vec2 fexl_re(vec2 z) {
	return vec2(z.x, 0);
}

highp vec2 fexl_im(vec2 z) {
	return vec2(z.y, 0);
}

highp vec2 fexl_sqrt(vec2 z) {
	highp float r = sqrt(z.x * z.x + z.y * z.y);
	if (r == 0.0) return vec2(0.0, 0.0);
	vec2 zpr = vec2(z.x + r, z.y);
	highp float abs_zpr = sqrt(zpr.x * zpr.x + zpr.y * zpr.y);
	highp float part_product = sqrt(r) / abs_zpr;
	return vec2(zpr.x * part_product, zpr.y * part_product);
}

highp vec2 fexl_ln(vec2 z) {
	return vec2(log(sqrt(z.x * z.x + z.y * z.y)), atan(z.y, z.x));
}

highp vec2 fexl_sin(vec2 z) {
	return vec2(sin(z.x) * cosh(z.y), cos(z.x) * sinh(z.y));
}

highp vec2 fexl_cos(vec2 z) {
	return vec2(cos(z.x) * cosh(z.y), -sin(z.x) * sinh(z.y));
}

highp vec2 fexl_tan(vec2 z) {
	highp float tan_a = tan(z.x);
	highp float tanh_b = tanh(z.y);
	highp float tan_a2 = tan_a * tan_a;
	highp float tanh_b2 = tanh_b * tanh_b;
	highp float part_divisor = 1.0 + tan_a2 * tanh_b2; 
	return vec2(
		(tan_a - tan_a * tanh_b2) / part_divisor,
		(tanh_b + tan_a2 * tanh_b) / part_divisor
	);
}

highp vec2 fexl_cot(vec2 z) {
	vec2 sine = vec2(sin(z.x) * cosh(z.y), cos(z.x) * sinh(z.y));
	vec2 cosine = vec2(cos(z.x) * cosh(z.y), -sin(z.x) * sinh(z.y));
	if (cosine.x == 0.0 || cosine.y == 0.0) return vec2(0, 0);
	return cosine / sine;
}

highp vec2 __internal_fexl_exp(vec2 z) {
	highp float exponent = exp(z.x);
    return vec2(exponent * cos(z.y), exponent * sin(z.y));
}

highp vec2 fexl_pow(vec2 a, vec2 b) {
	return __internal_fexl_exp(fexl_mul(fexl_ln(a), b));
}

/*
 * GENERAL CONTROLS AND ROUTINES
 */

uniform highp float ox = -1.0;
uniform highp float oy = 0.0;

uniform highp float zoom = 0.25;
uniform int max_depth = 500;

uniform float palette_red : hint_range(1.0, 2.0) = 2.0;
uniform float palette_green : hint_range(1.0, 2.0) = 1.5;
uniform float palette_blue : hint_range(1.0, 2.0) = 1.0;
vec4 compute_color(int achieved_depth) {
	float proportion = float(achieved_depth) / float(max_depth);
	float r = clamp(1.0 - pow(3.0 * proportion - palette_red, 2.0), 0.0, 1.0);
	float g = clamp(1.0 - pow(3.0 * proportion - palette_green, 2.0), 0.0, 1.0);
	float b = clamp(1.0 - pow(3.0 * proportion - palette_blue, 2.0), 0.0, 1.0);
	return vec4(r, g, b, 1.0);
}

uniform highp float bound = 3.14159;
vec2 f(vec2 z, vec2 c) {
	// TODO: replace FEXL to GDShader at run-time
	// - - - - BURNING SHIP TEST
	vec2 abs_za = fexl_re(z);
	abs_za = fexl_abs(abs_za);
	vec2 abs_zb = fexl_im(z);
	abs_zb = fexl_abs(abs_zb);
	z = vec2(abs_za.x, abs_zb.x);
	z = fexl_mul(z, z);
	z = fexl_add(z, c);
	// - - - -
	return z;
	//vec2 test = fexl_cos(z);
	//return fexl_add(fexl_pow(z, vec2(2.0, 0.0)), c);
}

const highp float EPSILON = 0.0000001;
const highp float EPSILON_SQR = EPSILON * EPSILON;
uniform highp float y_ratio = 0.536458333; // good initial guess

void fragment() {
	
	highp vec2 z = vec2(0.0, 0.0);
	highp vec2 c = vec2((UV.x - 0.5 + ox * zoom) / zoom, 
						(UV.y - 0.5 + oy * zoom) / zoom * y_ratio);
	
	highp float bound_sqr = bound * bound;
	int iteration = 0;
	while (iteration <= max_depth) {
		
		highp vec2 zn = f(z, c);
		
		highp float z_len = zn.x * zn.x + zn.y * zn.y;
		if (z_len >= bound_sqr) break;
		if (z_len <= EPSILON_SQR) break;
		
		z = zn;
		iteration++;
	}
	
	COLOR = compute_color(iteration);
	
}
