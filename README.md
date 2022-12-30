# Simulator for the analysis and evualation of Tracker Tags efficiency

This repository contains the Matlab scripts and functions for the numerical simulation of the 
 model developed to evaluate the tracker tags efficiency (i.e. Apple's AirTags, Tile's tracker, etc.)

The model is described in the paper by Enrique Hernández-Orallo, Antonio Armero, Carlos Tavares Calafate and Pietro Manzoni, "Analysis and evaluation of tracker tags efficiency", 
published by Hindawi Wireless Communications & Mobile Computing

Specifically, the file "Simulate_Airtags.m" contain the function that simulate numerically the tracker tags efficiency using a human mobility trace. As an example of how to use this function, file "TestSimAirTags_NCCU.m" contains the code that loads a mobility trace (the NCCU_trace_full.mat file), generates and located a set of lost tags and call the function to simulate this scenario.

Developed by GRC, Grupo de Redes de Computadores, Universitat Politecnica de Valencia, 2022
