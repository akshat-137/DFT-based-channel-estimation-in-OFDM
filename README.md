📡 #DFT-Based Channel Estimation in OFDM
MATLAB Simulation of LS vs DFT-Enhanced Channel Estimation
This project implements and compares Least Squares (LS) and DFT-based channel estimation techniques for an OFDM system operating over a Rayleigh frequency-selective fading channel.
The DFT-based estimator significantly improves estimation accuracy by exploiting the finite delay spread of real-world multipath channels.

#🚀 Project Overview

This MATLAB simulation demonstrates:

- 64-point OFDM system
- QPSK modulation
- Rayleigh multipath fading channel (8 taps)
- Block-type pilot-based estimation
- LS estimation
- DFT-based enhanced estimation
- Zero-Forcing (ZF) equalization
- BER & MSE performance evaluation (0–30 dB SNR)

The DFT estimator applies time-domain truncation to remove noise components from taps outside the true channel length, leading to significantly cleaner channel estimates.

#📁 System Block Diagram
Tx Bits → QPSK Mod → OFDM Mod → Rayleigh Channel → Add Noise → OFDM Demod
      → LS Estimate → (optional) DFT Filtering → ZF Equalizer → Decisions → BER

📊 Simulation Results
1. MSE vs SNR

The DFT-based estimator provides an ~8× reduction in MSE across all SNR values.

SNR (dB)	MSE (LS)	MSE (DFT)
0	1.003	0.1268
5	0.3121	0.0408
10	0.1002	0.01254
15	0.03124	0.003906
20	0.009976	0.00131
25	0.003152	0.0004066
30	0.001005	0.0001293
2. BER vs SNR

DFT-based estimation achieves 40–50% lower BER, giving a clear SNR gain.

SNR (dB)	BER (LS)	BER (DFT)
0	0.3127	0.2334
5	0.1763	0.1168
10	0.08097	0.04827
15	0.03048	0.01815
20	0.01059	0.005917
25	0.003116	0.001718
30	0.001214	0.0007367
📷 Plots

Add your images here after uploading:

![Channel Response](images/channel_response.png)
![MSE Plot](images/mse_plot.png)
![BER Plot](images/ber_plot.png)

🧠 Key Insight

The DFT-based estimator:

Converts LS estimate → time domain

Keeps only first L taps (actual channel length)

Zeroes out noise-dominated taps

Converts back to frequency domain

This is the same technique used in 4G LTE and 5G NR receivers for high-accuracy channel estimation.

🛠 How to Run

Clone the repository:

git clone https://github.com/<your-username>/<repo-name>.git


Open MATLAB and run:

main_ofdm_channel_estimation.m


View the MSE, BER, and channel estimation plots.

📌 Repository Structure
📁 OFDM-DFT-Channel-Estimation/
│
├── main_ofdm_channel_estimation.m
├── ls_estimator.m
├── dft_estimator.m
├── ofdm_tx_rx.m
├── plots.m
│
├── images/
│   ├── channel_response.png
│   ├── mse_plot.png
│   └── ber_plot.png
│
└── README.md

🎯 Conclusion

This project demonstrates that DFT-based channel estimation provides:

Much lower estimation error

Cleaner channel impulse response

Lower BER at all SNR levels

Higher SNR efficiency

Receiver behavior similar to LTE/5G PHY processing

The results match both theory and practical wireless system design.

👨‍💻 Author

Akshat Gupta
3rd-year B.Tech, Electronics & Communication Engineering
JSS Academy of Technical Education, Noida, India
