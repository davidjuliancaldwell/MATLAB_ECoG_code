# MATLAB code repository to analyze neural signals

This is a code repository which contains helper functions and code to process neural signals. This work has been a collaborative effort with others in the laboratory (Kai Miller, Dora Hermes, Timothy Blakely, Jeremiah Wander, Devapratim Sarma, James Wu, Nile Wilson, Jeneva Cronin)

---
A few helpful scripts to show how one might setup a MATLAB environment include

***startup.m***, which calls

***setupEnvironment.m***

This scripts set environment variables which are often called by other scripts such as ***PlotElectrodes.m***

---

In terms of plotting electrodes on a brain, the following shows a minimal working example.

***PlotElectrodes_Script_Trimmed.m***

A more in depth look at how to plot on a cortex was put together by Miah

***PlotDotsDirect_Tutorial.m***

---
This is useful for getting an idea about "basic" neural signal analysis. Miah put this together, and most of the code is setup to work with BCI2000 data, rather than anything from the TDT or other systems. However, the general framework may be useful for thinking about extracting signals, filtering them, and looking at aspects of interest.

***QuickScreen_StimulusPresentation***

---

David J Caldwell, BSD-3 license
