clear ;
clc ;
close all ;
rng(1) ;
%% DEFINE PARAMETERS 
subcarriers = 64 ;
ofdm_symb = 50 ;
M = 4 ; % QPSK
k = log2(M) ; % Bits per symbol
taps = 8 ; % channel length
SNR_dB = 0:5:30 ;
frames = 200 ;
%% RESULT PREALLOCATION
BER_ls   = zeros(size(SNR_dB));
BER_dft  = zeros(size(SNR_dB));
mse_ls   = zeros(size(SNR_dB));
mse_dft  = zeros(size(SNR_dB));

for i = 1:length(SNR_dB)
    snr_db = SNR_dB(i) ;
    snr_linear = 10^(snr_db/10) ;
    bit_err_ls = 0 ;
    bit_err_dft = 0 ;
    total_bits = 0 ;
    mse_acc_ls = 0 ;
    mse_acc_dft = 0 ;
    for f = 1:frames
        % RANDOM FREQ SELECTIVE RAYLEIGH CHANNEL
        p = exp(-0:(taps-1)) ;
        p = p/sum(p) ;
        h = (randn(taps,1) + 1*j*randn(taps,1))/sqrt(2) ; % rayleigh taps
        h = h.*sqrt(p.') ;
        h_true = fft([h; zeros(subcarriers-taps,1)]) ; % true freq response
        % PILOT OFDM SYMBOL
        pilot_bits = randi([0 1],subcarriers, 1);
        pilot_symb = 2*pilot_bits - 1; % BPSK Pilots (+/-1) with magnitude = 0 
        Es = mean(abs(pilot_symb).^2) ;
        nsd = Es/snr_linear ; % noise spectral density
        noise = sqrt(nsd/2)*(randn(subcarriers,1) + 1*j*randn(subcarriers,1)) ;
        % Recieved pilot in freq domain :
        Y_pilot = h_true.*pilot_symb + noise ;
        H_ls = Y_pilot./pilot_symb ; % LS Channel Estimation
        % DFT based channel Estimation
        h_time_est = ifft(H_ls);
        h_time_trunc = zeros(subcarriers,1) ;
        h_time_trunc(1:taps) = h_time_est(1:taps) ;
        H_dft = fft(h_time_trunc) ;
        % MSE (estimate vs true)
        err_ls = H_ls - h_true ;
        err_dft = H_dft - h_true ;
        mse_acc_ls = mse_acc_ls + mean(abs(err_ls).^2) ;
        mse_acc_dft = mse_acc_dft + mean(abs(err_dft).^2) ;
        %% TRANSMISSION
        num = subcarriers*ofdm_symb*k ;
        bits_tx = randi([0 1], num , 1) ;
        data_bits = reshape(bits_tx,k,[]).' ;
        b1 = data_bits(:,1) ;
        b2 = data_bits(:,2) ;
        data_symb = ((1 - 2*b1) + 1i*(1 - 2*b2)) / sqrt(2); % QPSK Symbols
        data_symb_mat = reshape(data_symb , subcarriers , ofdm_symb) ;
        Es_data = mean(abs(data_symb).^2) ;
        nsd_data = Es_data/snr_linear ;
        Y_data = zeros(subcarriers , ofdm_symb) ;
        for t = 1:ofdm_symb 
            Xj = data_symb_mat(:,t) ;
            noise_j = sqrt(nsd_data/2)*(randn(subcarriers,1) + 1*j*randn(subcarriers,1)) ;
            Y_data(:, t) = h_true .* Xj + noise_j; % Received data in frequency domain
        end
        %% CHANNEL EQUALIZATION : LS & DFT 
        H_ls_mat = repmat(H_ls,1,ofdm_symb) ;
        H_dft_mat = repmat(H_dft,1,ofdm_symb) ;
        xhat_ls = Y_data./H_ls_mat ;
        xhat_dft = Y_data./H_dft_mat ;
        %% QPSK DEMODULATION
        xhat_ls_vec = xhat_ls(:) ;
        xhat_dft_vec = xhat_dft(:) ;
        b1_hat_ls = real(xhat_ls_vec) < 0 ;
        b2_hat_ls = imag(xhat_ls_vec) < 0; 
        b1_hat_dft = real(xhat_dft_vec) < 0 ;
        b2_hat_dft = imag(xhat_dft_vec) < 0; 
        bits_rx_ls = zeros(num,1) ;
        bits_rx_dft = zeros(num ,1) ;
        bits_rx_ls(1:2:end)  = b1_hat_ls;
        bits_rx_ls(2:2:end)  = b2_hat_ls;
        bits_rx_dft(1:2:end) = b1_hat_dft;
        bits_rx_dft(2:2:end) = b2_hat_dft;
        bit_err_ls = bit_err_ls + sum(bits_tx ~= bits_rx_ls) ;
        bit_err_dft = bit_err_dft + sum(bits_tx ~= bits_rx_dft);
        total_bits = total_bits + num ;
    end
    %% BER & MSE CALCULATION 
    BER_ls(i) = bit_err_ls/total_bits ;
    BER_dft(i) = bit_err_dft/total_bits ;
    mse_ls(i) = mse_acc_ls / frames;
    mse_dft(i) = mse_acc_dft / frames;
    
    fprintf('SNR = %2d dB : BER _LS = %.4g , BER_DFT = %.4g , MSE_LS = %.4g , MSE_DFT = %.4g \n ' , snr_db , BER_ls(i) , BER_dft(i) , mse_ls(i) , mse_dft(i)) ;
end
%% PLOTS 
figure ; 
semilogy(SNR_dB, BER_ls, '-o', 'LineWidth', 1.5); 
hold on;
semilogy(SNR_dB, BER_dft, '-s', 'LineWidth', 1.5);
grid on; 
xlabel('SNR (dB)'); 
ylabel('BER');
title('BER vs SNR: LS vs DFT-based Channel Estimation');
legend('LS', 'DFT-based', 'Location', 'southwest');

figure;
semilogy(SNR_dB, mse_ls, '-o', 'LineWidth', 1.5);
hold on;
semilogy(SNR_dB, mse_dft, '-s', 'LineWidth', 1.5);
grid on; 
xlabel('SNR (dB)'); 
ylabel('MSE');
title('MSE of Channel Estimates vs SNR');
legend('LS', 'DFT-based', 'Location', 'southwest');

mid_idx = ceil(length(SNR_dB)/2);
fprintf('\nExample frequency responses plotted for SNR = %d dB\n', SNR_dB(mid_idx));

figure;
stem(0:subcarriers-1, abs(h_true), 'filled');
hold on;
stem(0:subcarriers-1, abs(H_ls), 'x');
stem(0:subcarriers-1, abs(H_dft), 's');
grid on;
xlabel('Subcarrier Index');
ylabel('|H(k)|');
title(sprintf('Channel Magnitude Response (SNR = %d dB)', SNR_dB(mid_idx)));
legend('True H', 'LS Estimate', 'DFT-based Estimate', 'Location', 'best');