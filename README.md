# A Comparison between NDR-Learner and Causal Forest

##### Table of Contents  

This GitHub Repository is meant to be a companion for the Master Thesis "A Comparison between NDR- Learner and Causal Forest" by Marvin Scherer (2022). The code for the 6 different simulations and their respective plots can be found in the folder `Code`. The code and the plots are run in R and are mainly built with help of the `causalDML`, `grf`, `causalToolbox` and `tidyverse` package. Please refer to the paper for more detailed information or to the documentation of the respective packages in case of more specific questions.


**If you clone this repository and run the code by yourself, make sure to:**

- Create a `Results` and `Figures` folder inside of your `Code` folder for the simulations and plots to run smoothly and store the results and the plots.
- Input your working directory in `"YOUR WORKING DIRECTORY"` at the beginning of each R Script (line 14 for simulations and line 9 for `plots.R`) (See image below).
    - ![](https://github.com/marvinscherer/dml-comparison/blob/main/Code/Figures/YOUR_WORKING_DIRECTORY.jpg)
- Take into account that the simulations can take a long run time and be computationally expensive (up to 24h+).

## How to use

Once you've followed the steps above and you are aware that your RStudio might be running for multiple hours in a row you can set:
- The desired amount of maximum observations `N` 
- And the amount of simulated iterations `r` in the `#Parameters` section from line 19 to 21 (See image below).
    - ![](https://github.com/marvinscherer/dml-comparison/blob/main/Code/Figures/parameters.jpg)
- You can also change the step increase of the grid of observations by changing `n_range` in line 27.
- For more in-depth tweaking please refer to the documentation of the respective packages mentioned above.

## Contact me 
For questions feel free to contact me under `marvin.scherer@student.unisg.ch` or `marvin_scherer@hotmail.com`.