shader_type spatial;
render_mode unshaded; // We don't need lighting for this


void fragment() {
    // NORMAL is in view-space, you might want world-space
    // vec3 world_normal = (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;

    // Encode the normal data (which is -1 to 1) as a color (0 to 1)
    ALBEDO = NORMAL;// * 0.5 + 0.5;
}