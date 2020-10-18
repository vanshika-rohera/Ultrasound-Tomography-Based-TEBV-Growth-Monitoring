# Ultrasound-Tomography-Based-TEBV-Growth-Monitoring
The code packet is being used to take RF data and process it to reconstruct a full 360 degree image

ImageReconstructionDATA
This code contains the image reconstruction process for the data collected. The process includes forming A-lines for pre-beamformed RF data, rotation of phantom point for 360 degree reconstruction, delay and sum beamforming, envelope detection, and log compression. 

generateRF2
The generate RF2 function loops through each angle to create an A-line which undergoes the beamforming process. 

rotatePhantom
The rotate phantom function takes a phantom position and rotates it in a circle in order to have a 360 degree view of the desired phantom.

roty
The rotate phantom function calls on the rotate y-axis function because the phantom is rotated using a rotational matrix that rotates around the y-axis. The rotational matrix follows P’=P*[cos(a) – sin(a); sin(a)cos(a)]

The data folder contains data collected with two points phantoms and with the bioreactor filled with water
