video-delay
===========

A digital video input delay meter built on an FPGA

### Overview

This project uses a custom photodiode sensor circuit and a DVI chip on a [PMOD expansion board from 1BitSquared](https://1bitsquared.com/collections/fpga/products/pmod-digital-video-interface) to implement a digital video input delay meter on a [Digilent Nexys A7-100T FPGA development board](https://digilent.com/shop/nexys-a7-fpga-trainer-board-recommended-for-ece-curriculum/). To within a margin of error of 0.1ms, the design aims to measure the time delay from the moment a pixel's data is sent to the DVI output to the moment it lights up the corresponding pixel on a TV or monitor. The video signal is driven by the 24bpp version of the DVI PMOD running in DDR mode, generating 720p at 60Hz.

For more details, watch the [video on YouTube](https://youtu.be/DxKJLtoABO0) and check out the [write-up on hackaday.io](https://hackaday.io/project/190456-video-input-delay-meter).

[![Watch the video](https://img.youtube.com/vi/DxKJLtoABO0/hqdefault.jpg)](https://youtu.be/DxKJLtoABO0)

### Running the project

To run this project, you'll need Vivado 2022.1 (or later) installed with its binaries available on your path. From the top level of this repository, run:

```bash
vivado -source init.tcl
```

This will start Vivado and create a subdirectory named `video-delay` with the project initialized in it. You can run synthesis, implementation and bitstream generation from within Vivado to try out the project on your matching hardware.

With a little effort, it should be very possible to port this project to other Digilent boards, such as the [Basys 3](https://digilent.com/shop/basys-3-artix-7-fpga-trainer-board-recommended-for-introductory-users/). You would need to adjust constraints to account for different pinouts and different resources like LEDs and seven segements displays. Low-to-mid cost FPGA development boards from other vendors should also be plenty capable of running a ported version of this project. The PMOD pinouts and the clocking requirements are probably the biggest technical constraints. For relaxed clocking, you could certainly run a slower video signal, such as 480p. You could also drive an easier DVI PMOD, such as the 4bpp version of the same PMOD from 1BitSquared.

### Branches

This repository is organized into branches for each of the development steps outlined in the video:

1. [Sensor](./tree/feature/01-sensor)
    * Read data from the custom photodiode circuit and light up the development board's LEDs
2. [DVI](./tree/feature/02-dvi)
    * Output a basic 720p 60Hz signal from the DVI chip that displays a color gradient
3. [Sevens](./tree/feature/03-sevens)
    * Wire up user interface components of buttons and seven segment displays
4. [Patterns](./tree/feature/04-patterns)
    * Create a user interface to control the pattern of pixels sent out by the DVI chip
5. [Timer](./tree/feature/05-timer)
    * Implement a timer to control the DVI output, measure a TV or monitor's response, and show the measured results on the seven segment displays
