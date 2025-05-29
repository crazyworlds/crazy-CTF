Welcome to the repository of our Capture The Flag (CTF) "EvilCorp Journey"!

This project offers a complete and self-contained CTF environment, designed to challenge your cybersecurity skills. Whether you are a student, an ethical hacking enthusiast, or a security professional, this CTF is crafted to provide you with a practical and stimulating learning experience.

"EvilCorp Journey" will guide you through a series of interconnected challenges, simulating a realistic intrusion path. You will start from an initial access point and navigate through various phases of reconnaissance, vulnerability exploitation, and privilege escalation, until you achieve full control of the target systems.

CTF Environment Setup
To launch the "EvilCorp Journey" environment on your system, follow these simple steps:

Clone the Repository:
If you haven't already, clone this repository to your local system:

git clone https://github.com/crazyworlds/crazy-CTF.git
cd crazy-CTF

Prerequisites:
Ensure you have Docker and Docker Compose installed and functional on your system. You can download them from the official Docker website.

Start the CTF Environment:
The repository includes a startup script (start_ctf.sh) that will generate the necessary SSH keys, configure the environment, and launch all Docker services.

From the root directory of the repository (crazy-CTF/), make the script executable and run it:

chmod +x start_ctf.sh
./start_ctf.sh

This process might take a few minutes on the first run, as Docker will need to download base images and build the containers.

Accessing the CTF:
Once the script has completed the setup, the environment will be ready. Key access information will be displayed in your terminal. The entry points will be:

Starting Web Point: http://localhost:1080



What you'll find:

Multi-Phase Challenges: A path starting with web reconnaissance, progressing to SSH server access, and culminating in complex privilege escalation techniques.

Real Vulnerabilities: You will exploit known CVEs (e.g., Redis Arbitrary File Write (AFW)) and common misconfigurations (e.g., sudo mount --bind abuse).

Advanced Networking: You will face segmented network scenarios that require pivoting and tunneling techniques.

Isolated Environment: The entire infrastructure is managed via Docker Compose, ensuring an isolated, reproducible, and easy-to-start/reset environment.

Prepare to immerse yourself in an ethical hacking adventure, solve puzzles, and uncover the hidden secrets within EvilCorp's systems.

Happy flag hunting!