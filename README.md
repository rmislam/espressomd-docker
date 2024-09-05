# espressomd-docker
A Debian-based Docker setup for EspressoMD

This is a docker compose setup for a Debian container that runs the molecular dynamics software EspressoMD: https://espressomd.github.io/

This code has been tested on WSL2 running Debian on Windows 11 with an NVIDIA RTX 3070 GPU.

## Building
```bash
sudo docker compose build
```

Note that this will fail if you don't have an NVIDIA GPU because it builds EspressoMD with CUDA enabled. If you want to disable CUDA, see the `ESPRESSO_BUILD_WITH_CUDA` option in the EspressoMD documentation.

Note that a Docker volume named `espressomd-docker_volume` will be created, which you can use for persistent storage.

## Running
```bash
sudo docker compose up
```

A Jupyter Lab server will be running in the container.
Jupyter will output a URL (http://127.0.0.1:8888/lab) where you can access the tutorial notebooks in the doc/tutorials folder. The visualization tutorial is useful for checking if your display forwarding is working correctly.

Note that if you're on WSL, you may need to replace localhost in the URL with the ip from:
```bash
ip addr | grep eth0 | grep inet
```

This gives the ip address of WSL relative to the Windows host.

Whenever importing the Python espressomd module, make sure to add this to the top of your Python code to add espressomd to the Python path:
```python
import sys
sys.path.insert(0, '/home/espresso/espresso/build/src/python')
```

These lines have already been added to the Jupyter configuration, so you can run the tutorial notebooks without any modification. If you plan to run Python files outside of Jupyter, however, you'll need these import statements.

## Configuration
You can enable or disable the compilation of specific EspressoMD features by modifying myconfig.hpp and rebuilding the image. See the EspressoMD documentation for info about features: https://espressomd.github.io/
