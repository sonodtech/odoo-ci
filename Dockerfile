FROM ubuntu:24.04

# some environment variables
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive

RUN set -x \
  && apt-get update \
  && apt-get dist-upgrade -y \
  && apt-get install -y software-properties-common \
  && add-apt-repository -y ppa:deadsnakes/ppa \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    build-essential \
    git \
    mercurial \
    wget \
    openssh-client \
    rsync \
    make \
    python3 \
    python3-dev \
    python3-venv \
    python3.8 \
    python3.8-dev \
    python3.8-venv \
    python3.9 \
    python3.9-dev \
    python3.9-venv \
    python3.10 \
    python3.10-dev \
    python3.10-venv \
    python3.11 \
    python3.11-dev \
    python3.11-venv \
    python3.12 \
    python3.12-dev \
    python3.12-venv \
    python3.13 \
    python3.13-dev \
    python3.13-venv \
    postgresql-client \
    libpq-dev \
    libcairo2 \
    libcairo2-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libxmlsec1-openssl \
    pkg-config \
    # expect provides the unbuffer utility
    tcl \
    expect \
    # odoo dependencies
    graphviz \
    node-clean-css \
    node-less \
    poppler-utils \
    antiword \
    # libreoffice for py3o
    libreoffice-writer \
    libreoffice-calc \
    # gettext to manipulate .pot, .po files
    gettext \
  # wkhtmltopdf
  && wget -q -O /tmp/wkhtmltox.deb https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.jammy_amd64.deb \
  && echo "4f723b2691ad8638a9df960e0421d346d7315083e3583a334f33362280ddba15 /tmp/wkhtmltox.deb" | sha256sum -c - \
  && apt-get -y install /tmp/wkhtmltox.deb \
  && rm -f /tmp/wkhtmltox.deb \
  # cleanup
  && rm -fr /var/lib/apt/lists/*

# Install pipx, which we use to install other python tools.
ENV PIPX_BIN_DIR=/usr/local/bin
ENV PIPX_HOME=/opt/pipx
RUN python3 -m venv /opt/pipx/venv \
    && /opt/pipx/venv/bin/pip install --no-cache-dir pipx \
    && ln -s /opt/pipx/venv/bin/pipx /usr/local/bin/

# We don't use the ubuntu virtualenv package because it unbundles pip dependencies
# in virtualenvs it create.
RUN pipx install --pip-args="--no-cache-dir" virtualenv

# git-autoshare
RUN pipx install --pip-args="--no-cache-dir" "git-autoshare>=1.0.0b4"
COPY git-wrapper /usr/local/bin/git

# manifestoo
RUN pipx install --pip-args="--no-cache-dir" "manifestoo>=0.4.0"

# pip-split-requirements
RUN pipx install --pip-args="--no-cache-dir" "pip-split-requirements>=0.7"

# create gitlab-runner user, and do the rest of config using that user
RUN useradd --shell /bin/bash -m gitlab-runner -c ""
USER gitlab-runner
ENV PIPX_BIN_DIR=/home/gitlab-runner/.local/bin
ENV PIPX_HOME=/home/gitlab-runner/.local/pipx
ENV PATH=/home/gitlab-runner/.local/bin:$PATH

# set git user.name and user.email so the runner can git push
RUN git config --global user.email "gitlab@sonod.tech" \
  && git config --global user.name "GitLab"

# disable git safe repository detection, because GitLab CI checks out as root,
# and we run as gitlab-runner
RUN git config --global --add safe.directory '*'

# avoid potential race conditions in creating these directories
RUN mkdir -p \
  /home/gitlab-runner/.local/share/Odoo/addons \
  /home/gitlab-runner/.local/share/Odoo/filestore \
  /home/gitlab-runner/.local/share/Odoo/sessions

# make sure directories in /home/gitlab-runner have adequate owner and permissions
RUN mkdir -p \
  /home/gitlab-runner/.cache \
  /home/gitlab-runner/.config \
  /home/gitlab-runner/.ssh \
  && chmod 700 /home/gitlab-runner/.ssh

COPY --chown=gitlab-runner --chmod=644 git-autoshare.yml /home/gitlab-runner/.config/git-autoshare/repos.yml

COPY --chown=gitlab-runner --chmod=644 ssh_config /home/gitlab-runner/.ssh/config