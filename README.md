# Sonod docker image for running Odoo CI workloads

This Odoo image has the following characteristics:

- Based on Ubuntu 22.04.
- Minimal dependencies to run Odoo CI jobs

  - git (with user.name=GitLab and user.email=gitlab@sonod.tech)
  - git-autoshare
  - mercurial
  - openssh-client
  - rsync
  - make
  - python3.10
  - virtualenv
  - postgresql client
  - lessc
  - wkhtmltopdf
  - unbuffer
  - gettext: useful to manipulate .po files
  - graphviz, poppler-utils, antiword: used by some Odoo versions
  - libreoffice-writer, libreoffice-calc: for py3o

- [pipx](https://pypi.org/project:pipx>)
- [manifestoo](https://pypi.org/project/manifestoo>)
- ssh client configuration

  - disable strict host key checking

- Odoo 16 is supported.
- Odoo is not preinstalled.
- Runs as non-privileged user named _gitlab-runner_

## Recommended mounts

It is recommended to mount the following volumes, for better build performance:

- ```/home/gitlab-runner/.cache/pip```
- ```/home/gitlab-runner/.cache/git-autoshare```
- ```/home/gitlab-runner/.cache/acsoo-wheel```, if you use the deprecated ```acsoo wheel``` command
