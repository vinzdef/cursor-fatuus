import Clutter from 'gi://Clutter';
import Cogl from 'gi://Cogl';
import GObject from 'gi://GObject';
import Shell from 'gi://Shell';
import St from 'gi://St';

import * as Main from 'resource:///org/gnome/shell/ui/main.js';

// Solid disk whose outer `softness` fraction of the radius fades to
// transparent: 0 is a hard-edged circle, 1 a single fade from the center.
// Follows 1 - smoothstep, like the macOS app; the minimum fade keeps a hard
// edge antialiased.
const FALLOFF = `
uniform float softness;
uniform float opacity;

float falloff(vec2 coord) {
    float d = length(coord - 0.5) * 2.0;
    return (1.0 - smoothstep(1.0 - max(softness, 0.02), 1.0, d)) * opacity;
}
`;

const FalloffEffect = GObject.registerClass({
    GTypeName: 'CursorFatuusFalloffEffect',
}, class FalloffEffect extends Shell.GLSLEffect {
    setUniforms(values) {
        for (const [name, value] of Object.entries(values)) {
            const components = [value].flat();
            this.set_uniform_float(this.get_uniform_location(name), components.length, components);
        }
    }
});

// Paints the tint color through the falloff, ignoring the actor's content.
const TintEffect = GObject.registerClass({
    GTypeName: 'CursorFatuusTintEffect',
}, class TintEffect extends FalloffEffect {
    vfunc_build_pipeline() {
        this.add_glsl_snippet(Cogl.SnippetHook.FRAGMENT, `${FALLOFF}
            uniform vec3 tint;
        `, `
            float a = falloff(cogl_tex_coord_in[0].xy);
            cogl_color_out = vec4(tint * a, a);
        `, true);
    }
});

// Inverts what is already on screen beneath it, through the falloff: blending
// computes (1 - screen) * a + screen * (1 - a). Costs about the same as the
// tint, since nothing beneath is redrawn. Paints with its own pipeline, as
// offscreen effects don't expose theirs for setting a blend.
const InvertDisc = GObject.registerClass({
    GTypeName: 'CursorFatuusInvertDisc',
}, class InvertDisc extends Clutter.Actor {
    configure(softness, opacity) {
        this._uniforms = {softness, opacity};
        this._applyUniforms();
        this.queue_redraw();
    }

    _applyUniforms() {
        if (!this._pipeline)
            return;
        for (const [name, value] of Object.entries(this._uniforms))
            this._pipeline.set_uniform_1f(this._pipeline.get_uniform_location(name), value);
    }

    vfunc_paint(paintContext) {
        const framebuffer = paintContext.get_framebuffer();
        if (!this._pipeline) {
            this._pipeline = makeInvertPipeline(framebuffer.get_context());
            this._applyUniforms();
        }
        const [width, height] = this.get_size();
        framebuffer.draw_textured_rectangle(this._pipeline, 0, 0, width, height, 0, 0, 1, 1);
    }

    // Without this, Clutter can't tell what a custom paint covers and redraws
    // the whole stage on every move.
    vfunc_get_paint_volume(volume) {
        return volume.set_from_allocation(this);
    }
});

function makeInvertPipeline(context) {
    const pipeline = Cogl.Pipeline.new(context);
    // A layer, even without a texture, gives the shader texture coordinates.
    pipeline.set_layer_null_texture(0);
    pipeline.add_snippet(Cogl.Snippet.new(Cogl.SnippetHook.FRAGMENT, FALLOFF, `
        float a = falloff(cogl_tex_coord_in[0].xy);
        cogl_color_out = vec4(a);
    `));
    try {
        pipeline.set_blend(
            'RGB = ADD(SRC_COLOR * (1 - DST_COLOR), DST_COLOR * (1 - SRC_COLOR[A])) ' +
            'A = ADD(SRC_COLOR, DST_COLOR * (1 - SRC_COLOR[A]))');
    } catch (e) {
        // Painting must go on: a failed blend leaves a white glow instead.
        console.error(`Cursor Fatuus: invert blend failed: ${e.message}`);
    }
    return pipeline;
}

// Optionally inverts the actor's content, then masks it with the falloff.
const BackdropEffect = GObject.registerClass({
    GTypeName: 'CursorFatuusBackdropEffect',
}, class BackdropEffect extends FalloffEffect {
    vfunc_build_pipeline() {
        this.add_glsl_snippet(Cogl.SnippetHook.FRAGMENT, `${FALLOFF}
            uniform float invert;
        `, `
            // Colors are premultiplied, so inverting subtracts from alpha.
            if (invert > 0.5)
                cogl_color_out.rgb = vec3(cogl_color_out.a) - cogl_color_out.rgb;
            cogl_color_out *= falloff(cogl_tex_coord_in[0].xy);
        `, false);
    }
});

// Disc centered on the pointer: a backdrop of whatever lies beneath it,
// blurred and inverted, under a tint.
export class Halo {
    constructor() {
        this._radius = 0;
        this._pad = 0;

        // Redraws the shell's whole scene, which excludes the halo, as content
        // the blur and the falloff mask can process. Costly: every window is
        // drawn again whenever anything on screen changes, so it is only
        // shown when blurring.
        this._clone = new Clutter.Clone({source: Main.layoutManager.uiGroup});
        this._blur = new Shell.BlurEffect({mode: Shell.BlurMode.ACTOR});
        // Extends past the backdrop so the blur has real content at its edge.
        this._blurBox = new Clutter.Actor({clip_to_allocation: true});
        this._blurBox.add_effect(this._blur);
        this._blurBox.add_child(this._clone);

        this._backdropEffect = new BackdropEffect();
        this._backdrop = new Clutter.Actor({clip_to_allocation: true});
        this._backdrop.add_effect(this._backdropEffect);
        this._backdrop.add_child(this._blurBox);

        this._invert = new InvertDisc();

        // The effect replaces this background; it only gives the actor content to paint.
        this._tintEffect = new TintEffect();
        this._tint = new St.Widget({style: 'background-color: white;'});
        this._tint.add_effect(this._tintEffect);

        // Painted straight onto the stage, never into an offscreen buffer, so
        // the invert blends with the screen.
        this.actor = new Clutter.Actor();
        this.actor.add_child(this._backdrop);
        this.actor.add_child(this._invert);
        this.actor.add_child(this._tint);
        // Above uiGroup, which holds everything else the shell draws. Not
        // reactive, so input passes through.
        global.stage.add_child(this.actor);
    }

    // A null color hides the tint, leaving blur and invert unobstructed.
    configure({color, opacity, blurRadius, invert, radius, softness}) {
        // Whole pixels keep the clone aligned to the pixel grid.
        this._radius = Math.round(radius);
        // The blur's sigma is half its radius; three sigmas cover its reach.
        this._pad = Math.ceil(blurRadius * 3);
        const size = this._radius * 2;
        this.actor.set_size(size, size);
        this._backdrop.set_size(size, size);
        this._blurBox.set_position(-this._pad, -this._pad);
        this._blurBox.set_size(size + this._pad * 2, size + this._pad * 2);
        this._invert.set_size(size, size);
        this._tint.set_size(size, size);

        // Sigma equal to the macOS blur radius.
        this._blur.radius = Math.round(blurRadius * 2);
        const blurs = blurRadius > 0;
        this._backdrop.visible = blurs;
        // When the backdrop is already drawn, it inverts too: inverting the
        // blurred backdrop before masking matches macOS, while blending an
        // invert over it differs at the soft edge.
        this._backdropEffect.setUniforms({softness, opacity, invert: invert ? 1 : 0});
        this._invert.visible = invert && !blurs;
        if (this._invert.visible)
            this._invert.configure(softness, opacity);

        this._tint.visible = color !== null;
        if (color)
            this._tintEffect.setUniforms({softness, opacity, tint: color});
    }

    moveTo(x, y) {
        const left = x - this._radius;
        const top = y - this._radius;
        this.actor.set_position(left, top);
        // Keeps the clone in place on screen while the halo moves over it.
        this._clone.set_position(this._pad - left, this._pad - top);
    }

    destroy() {
        this.actor.destroy();
    }
}
