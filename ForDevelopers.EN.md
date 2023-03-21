# Welcome to the annotated edition of MakeUp.

It is my desire that MakeUp can be used as a basis for creating more and better shaders, which is why I am writing this explanatory text about the source code.

I hope that the comments you find within will be helpful to modify and/or extend MakeUp according to your needs.

Happy editing!

## Organization of shader files

### shaders/common

In order to avoid duplicate code, the various shaders used in the different dimensions of Minecraft refer to files located in this directory. This is where the main routines for each of the different types of blocks are located, as well as the rest of the steps in the Optifine/Iris work pipeline.

The vertex and fragment shaders for each step are separated into individual files, which can be clearly identified by the name of the file in question.

There isn't necessarily a file here for each step or type of block, as some blocks or steps share many things in common, and in MakeUp are treated similarly (or almost the same).

The best examples of this are solid_blocks_fragment.glsl and solid_blocks_vertex.glsl, which control the drawing of the vast majority of game blocks that are not translucent or that require very special attention.

The file names attempt to be explicit about their content or purpose.

### shaders/lang

Translation files. They name the options in the configuration screens.

### shaders/lib

Files with specific routines or declarations used in various places in the main routines are located here.

The files located in this directory are treated as "libraries" and are called OUTSIDE of the main shader function that requests them (meaning they are not inserted inside the main function of the specific shader). Usually, they declare functions or values used by the requester.

The file names attempt to be explicit about their content or purpose.

### shaders/src

The files here serve a similar role to those in shaders/lib. The difference lies in the way they are inserted into the code of the requesting shader.

In this case, the code is intended to be inserted INSIDE the main function of the specific shader. They are simple snippets of code that, when used multiple times, are only written once here and are included in a "dirty" way in the code, without being strictly speaking functions.

### shaders/textures

As the name suggests, this is where the textures used by the shader are stored.
shaders/worldX

The well-known folders that host the shaders corresponding to each dimension:

    world0: Overworld
    world-1: Nether
    world1: The End

The shaders used for any other unspecified dimension are direct descendants of the "shaders" directory.

-----

# Main Drawing Flow

## Buffers

Buffers are used and assigned in the following way:

    - noisetex: Stores the water normals in two channels, with the third component being calculated at runtime. (RG8)
    - colortex0: Bluenoise (not loaded). (R8)
    - colortex1: Main buffer. When DOF is active, it is four channels, with the fourth channel storing the scene depth for antialiasing and to avoid sudden focus changes due to camera shake. (Without DOF: R11F_G11F_B10F, with DOF: RGBA16)
    - colortex2: Stores the "blocky" cloud map. (R8)
    - colortex3: Stores the history used for temporal sampling. When DOF is active, it is four channels, with the fourth channel storing the scene depth for antialiasing and to avoid sudden focus changes due to camera shake. (Without DOF: R11F_G11F_B10F, with DOF: RGBA16)
    - gaux1: Stores a version of the scene that will be used for screen-space reflections and refractions. After it is used for that, it is used as an auxiliary to store the scene's bloom. (R11F_G11F_B10F)
    - gaux2: Stores the cloud map in "natural" format. (R8)
    - gaux3: Stores the historical value of the scene's auto-exposure. The auto-exposure value is obtained by doing a weighted average with the value of this channel and the calculated one in the current scene to create a gradual transition of auto-exposure over time. Yes, it is excessive to use an entire buffer to store a single floating-point value, but it is what it is. It is only used if the default auto-exposure method is used. (R16F)
    - gaux4: Stores the color of the sky (without clouds or other objects) to give the color that should be used in the fog (yes, the fog is always the color of the "sky"). This way, objects are blurred and blended with the sky in the distance.

-----

# General drawing steps

This is just a general description of the steps involved in drawing a typical scene. It does not have all the details and may vary depending on the dimension and options activated.

1. The color of the sky or infinite distance is calculated in 'prepare'. This color is written in two places:
 - colortex1: It will be used later to write the solid blocks there.
 - gaux4: This buffer will be used to extract the color of the fog from it.

2. In gbuffers_skybasic, elements such as stars are drawn over the previously drawn sky. Subsequently, textured sky elements are drawn (gbuffers_skytextured). All of this is written in colortex1.

3. Solid blocks are created in the corresponding gbuffer programs. Here, the lighting of the blocks is calculated (including shadows).
The result will be written in:
 - colortex1

4. In deferred, clouds and ambient occlusion will be calculated. The results will be written in:
 - colortex1: The calculated scene is written here, the "a" channel will store the depth (only if it makes sense).
 - gaux1: It will be used later as a data source for the calculation of screen-space reflections and refractions in the next step.

5. Translucent blocks are drawn. The clouds are recalculated in low quality to be used in reflections. gaux1 is read as a source for screen-space refractions and reflections. The alpha channel continues to be used to store depth. The results are written to:
 - colortex1

6. In Composite, the current frame's autoexposure level is calculated and weighted with the historical value saved in gaux3. Volumetric lighting is also calculated, and bloom is prepared. The autoexposure does not take into account any of these later effects.
"Preparing bloom" means saving a version of the current scene with the applied exposure level to gaux1.
The calculated autoexposure value is also saved to gaux3.

7. In Composite1, DOF is calculated and bloom is applied. To apply bloom, a mipmap level of the gaux3 buffer calculated in the previous step is read. The result is written to colortex1

8. In Composite2, AA and motion blur are calculated. The result is written to colortex0. If temporal super-sampling is enabled, the history is written to colortex3.

9. Finally, post-processing effects such as chromatic aberration, autoexposure, tone mapping, and color blindness aids are applied in Final.
The image is then sent to the screen.

-----

Review the rest of the directories or source code to find information related to that element.