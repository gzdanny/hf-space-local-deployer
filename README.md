# Hugging Face Space Docker Deployer

This is a simple yet powerful script designed to help you **deploy and test any Hugging Face Space locally using Docker with a single command.**

It automates the entire setup process, including installing dependencies, cloning the repository, and running the application inside a Docker container. This is especially useful for testing large models that exceed the resource limits of Hugging Face's free Space tier.

## ✨ Features

- **One-Click Deployment**: Get any Hugging Face Space up and running locally.
- **Dependency Automation**: Automatically installs Docker and Git (if not present).
- **Interactive Setup**: Guides you through the process, prompting for the Space name and port.
- **Resource Freedom**: Test large models without worrying about cloud resource limits.

## 🚀 Getting Started

### Prerequisites

- A Debian/Ubuntu-based system.
- An internet connection.

### Usage

   ```bash
   # Debian/Ubuntu-based
   curl -o https://raw.githubusercontent.com/gzdanny/hf-space-local-deployer/main/deploy.sh
   ```

The script will guide you through the rest of the process.

## ⚙️ How It Works

1.  **Dependency Check**: The script first verifies if **Docker** and **Git** are installed and installs them if they are not.
2.  **Repository Clone**: It prompts you for the `username/project_name` of the Hugging Face Space and clones the repository.
3.  **Docker Build**: It builds a Docker image based on the `requirements.txt` file in the repository. The model and all dependencies are downloaded and packaged into this image.
4.  **Container Run**: It starts a Docker container, mapping a port of your choice (or the default `7860`) to the container's internal port.
5.  **Access the App**: You can then access the running application in your browser at `http://localhost:[your_port]`.

## 🤝 Contribution

Contributions are welcome\! If you have ideas for improvements, feel free to open an issue or submit a pull request on GitHub.
