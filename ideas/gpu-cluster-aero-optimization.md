---
title: "Autonomous Aerodynamic Optimization via GPU-Accelerated CFD and Learned Surrogates"
date: 2026-04-16
domain: ["aerodynamics", "ai", "cfd", "topology-optimization"]
status: idea
project_repo: null
---

# Autonomous Aerodynamic Optimization via GPU-Accelerated CFD and Learned Surrogates

## What this is

A self-contained system that autonomously explores aerodynamic design spaces by combining GPU-accelerated CFD simulation, neural surrogate models, and reinforcement learning. It runs on a local multi-GPU node, generates its own training data, and improves with every run.

## Architecture

The system is built around three loops that feed into each other:

**Loop 1 — Idea generation.** A large language model proposes geometry modifications and parameterizations. It operates within a structured context that includes performance history from prior runs, known failure modes, and domain constraints. The LLM's role is creative exploration — suggesting configurations that a pure optimization algorithm would not sample on its own.

**Loop 2 — Surrogate-driven optimization.** Proposed geometries are evaluated using neural surrogate models (mesh-based graph networks, Fourier neural operators, or transformer-based physics surrogates). A reinforcement learning agent (PPO) navigates the design space using surrogate predictions as its reward signal. Multi-objective optimization (NSGA-III or similar) handles competing objectives like lift-to-drag ratio, structural compliance, and manufacturability.

**Loop 3 — Ground truth and retraining.** Promising candidates from Loop 2 are validated through full-fidelity CFD simulation (OpenFOAM with GPU acceleration via AmgX). Results feed back into the surrogate training set, expanding the model's accuracy envelope over time. A scheduler triggers retraining based on prediction uncertainty and distribution shift.

### Structural topology optimization

A parallel topology optimization pipeline handles structural components. GPU-accelerated solvers generate load-optimal material distributions that feed back into the aerodynamic geometry pipeline as structural feasibility constraints.

### Knowledge accumulation

Each run produces structured records — geometry parameters, simulation results, surrogate accuracy metrics, failure analyses. These persist in a knowledge base that informs subsequent runs. The system improves not just through model updates but through an expanding corpus of engineering context.

## Tech stack

**Hardware.** Multi-GPU compute node starting at 2× RTX 4090, scalable to 4+. 2000W+ PSU. Designed for sustained compute loads.

**CFD.** OpenFOAM with AmgX for GPU-accelerated linear algebra. Mesh generation via snappyHexMesh or cfMesh.

**Surrogates.** NVIDIA PhysicsNeMo — MeshGraphNet for irregular geometries, Fourier Neural Operator for regular grids, Transolver for transformer-based physics prediction.

**Optimization.** Stable-Baselines3 (PPO) for RL-driven exploration. pymoo for multi-objective evolutionary optimization. Custom reward shaping to balance aerodynamic performance against structural and manufacturing constraints.

**Topology optimization.** GPU-accelerated topology solvers (multi-GPU compliance minimization).

**Training data.** UniFoil (~500K airfoil simulations) and DrivAerML (automotive aerodynamics) for initial surrogate pre-training, supplemented by self-generated simulation data from Loop 3.

## Open questions

- What is the optimal retraining frequency for surrogates — continuous online learning vs. periodic batch retraining?
- Can a single surrogate architecture generalize across fundamentally different geometry families (airfoils, ducts, full vehicle bodies), or are domain-specific models required?
- How should the LLM's exploration budget be weighted against the RL agent's exploitation as the knowledge base grows?
- At what surrogate accuracy threshold does it become counterproductive to run additional full-fidelity validations?
- What minimum GPU count makes the three-loop architecture practical for non-trivial 3D RANS simulations?

## Related work

- **PhysicsNeMo (NVIDIA)** — Framework for training neural surrogate models on physics simulation data. Provides MeshGraphNet, FNO, and other architectures for physical systems.
- **OpenFOAM + AmgX** — GPU-accelerated CFD pipeline. AmgX handles the sparse linear algebra bottleneck that dominates simulation runtime.
- **DrivAerML dataset** — Large-scale automotive aerodynamics dataset for surrogate pre-training.
- **UniFoil dataset** — ~500K 2D airfoil simulations across a wide range of Reynolds numbers and angles of attack.
- **PhysicsX (Large Physics Models)** — Research direction exploring foundation-model-scale approaches to physical simulation.

## Acknowledgments

*Credits to the people and work that directly inspired this concept.*

- **CDFAM symposium (Barcelona, 2026)** — Presentations on computational design and AI-driven engineering workflows were a direct catalyst for this concept.
- **NVIDIA NeMo Agent Toolkit** — The idea of agentic CAE workflows shaped the three-loop autonomous architecture.
- **BeyondMath** — Their approach to foundational physics AI trained on self-generated data influenced the knowledge accumulation design.
- **[@webbtekk](https://www.instagram.com/webbtekk/)** — The idea of applying shark skin–inspired surface structures to aerodynamic optimization originated from his work.
