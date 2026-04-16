---
title: "Hybrid RF Direction Finding and Phased Array Communication System"
date: 2026-04-16
domain: ["rf-systems", "signal-processing", "ai", "sdr"]
status: idea
project_repo: null
---

# Hybrid RF Direction Finding and Phased Array Communication System

## What this is

A three-layer RF system that combines wideband direction finding, mechanical antenna pointing, and electronically steered phased array communication on a single platform. The DF subsystem locates signal sources in 3D space, the rotator slews to the target bearing, and the phased array fine-steers a high-gain beam for data link establishment. The system is designed for communication with custom-built remote platforms — drones, rockets, high-altitude vehicles, and ground stations — where both ends of the link are purpose-designed to work together.

## Architecture

### Layer 1 — Direction finding (TDOA)

A coherent multi-channel SDR array estimates angle of arrival for incoming signals across a wide frequency range (868 MHz to 5+ GHz). Multiple wideband log-periodic dipole antennas are arranged in 3D space around the rotator structure, connected to synchronized software-defined radios sharing a common reference clock. Time-difference-of-arrival and phase-difference techniques provide azimuth and elevation estimates for detected emitters.

An ML classification pipeline processes raw IQ data in stages: modulation recognition (identifying signal type), protocol identification (matching against known waveforms from the remote platforms), and device fingerprinting (distinguishing between specific units). Training happens offline on GPU compute; inference runs on edge hardware co-located with the antenna system.

### Layer 2 — Mechanical pointing

An upgraded open-source antenna rotator provides 360° azimuth and 180° elevation coverage with sub-degree pointing accuracy. Stock stepper motors are replaced with commercial closed-loop servo drivers to eliminate backlash. The rotator carries both the phased array and the edge compute stack (single-board computer + ML accelerator). Control is exposed via Hamlib's rotctld protocol over TCP, making it compatible with existing ground station software and scriptable from any language.

The rotator's role is coarse alignment — slewing the phased array's boresight to within a few degrees of the target based on DF estimates. Fine pointing is handled electronically by the phased array itself.

### Layer 3 — Phased array communication

An open-source software-defined phased array operating in C-band (4.9–6.0 GHz) provides the high-gain data link. The array consists of multiple quad-element tiles with individual phase and amplitude control per element, enabling electronic beam steering without mechanical motion. Primary operating band is 5.8 GHz ISM, chosen for license-free operation and compatibility with custom platform transceivers.

The phased array integrates with GNU Radio and SoapySDR, allowing fully programmable waveform generation and signal processing. Beam patterns, steering angles, and modulation schemes are all software-defined and can adapt in real time based on link quality feedback.

### Integration loop

The three layers operate as a closed loop: DF detects and classifies an incoming signal → bearing estimate is passed to the rotator controller → rotator slews to coarse alignment → phased array electronically fine-steers and establishes a data link → link quality metrics feed back to refine DF calibration over time.

Detection events, classification results, and link performance data are logged as structured records in a persistent knowledge base. Over successive sessions, the system accumulates signal environment data — known emitter locations, propagation characteristics, interference patterns — that improve both DF accuracy and communication reliability.

## Tech stack

**Direction finding hardware.** 3× Ettus USRP B210 (2 channels each, 6 coherent channels total, 70 MHz–6 GHz tuning range). OctoClock-G provides 10 MHz reference and PPS synchronization across all units. 5× wideband log-periodic dipole antennas covering 868 MHz–5 GHz, mechanically positionable in 3D around the rotator body for band-optimal baseline geometry.

**Rotator.** Based on the wuxx/AntRunner platform (ESP32 + GRBL firmware, 10 kg payload capacity). Upgraded with closed-loop stepper drivers. Controlled via Hamlib rotctld (TCP port 4533).

**Edge compute.** Raspberry Pi 5 + Google Coral Edge TPU mounted on the rotator body. Hailo-8L AI accelerator (13 TOPS) planned for ML inference workloads — modulation classification and protocol identification at the edge with minimal latency.

**Phased array.** Open.Space Mini — 18 quad-element tiles (72 antennas total), 4.9–6.0 GHz, 34 dBi gain, 52.6 dBW EIRP. Open-source SDR-based architecture with GNU Radio and SoapySDR integration. Analog Devices Phaser (CN0566) used as a development and learning platform during the buildout phase.

**ML pipeline.** torchsig for signal classification training. Modulation recognition → protocol identification → device fingerprinting, trained on GPU hardware and deployed to edge accelerators for real-time inference.

**Signal processing.** GNU Radio for flowgraph-based SDR processing. Python and C++ for custom DSP blocks. SoapySDR as the hardware abstraction layer across all SDR devices.

## Related work

- **Ettus Research / USRP** — The USRP B210 is a widely used coherent SDR platform in academic and professional RF research. The multi-device synchronization approach using OctoClock-G is well-documented in direction-finding literature.
- **Open.Space (Skylark Wireless)** — Open-source software-defined phased array platform. One of the first affordable, fully programmable antenna arrays available to individual builders.
- **wuxx/AntRunner** — Open-source antenna rotator design. ESP32 + GRBL-based, designed for amateur radio and satellite tracking applications.
- **Analog Devices Phaser (CN0566)** — 10-element X-band phased array development kit. Primarily an educational platform for learning beamforming, DOA estimation, and array signal processing fundamentals.
- **torchsig** — Open-source signal processing and classification library built on PyTorch. Provides modulation recognition models and training utilities for RF machine learning applications.
- **Hamlib** — Open-source library for controlling radio transceivers and antenna rotators. The rotctld daemon provides a standardized TCP interface used across ground station software.
- **GNU Radio** — Open-source signal processing framework. The standard platform for SDR development, providing a block-based architecture for building custom radio systems.

## Acknowledgments

*Credits to the people and work that directly inspired this concept.*

- **Skylark Wireless / Open.Space** — For building the first genuinely open-source, affordable phased array platform and making electronically steered arrays available to individual builders.
- **wuxx** — The AntRunner rotator design provided the mechanical foundation that the entire system is built on.
- **Jon Kraft** — His youtube videos where the most insightfull in regards to phased array antennas in my opinion.
