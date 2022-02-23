FROM python:3.8-slim-bullseye

RUN apt-get update \
    && apt-get install -y \
        postgresql-client \
        libpq-dev \
        git \
        bash-completion \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


# dbt-runner app
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
ENV PYTHONUNBUFFERED 1
ENV PYTHONPATH /dbt-runner
ENV DBT_PROFILES_DIR /dbt-runner/dbt
ENV DBT_MODULES_DIR /dbt_modules
WORKDIR /dbt-runner

# Conveniences
RUN echo 'source /usr/share/bash-completion/bash_completion' >> /etc/bash.bashrc
RUN echo 'export HISTFILE=/dbt-runner/.developer/history' >> $HOME/.bashrc
RUN echo 'mkdir -p /dbt-runner/.developer && touch /dbt-runner/.developer/bashrc && source /dbt-runner/.developer/bashrc' >> $HOME/.bashrc


COPY requirements.txt requirements.txt
RUN pip install --upgrade pip
RUN pip install --ignore-installed -r requirements.txt && rm -rf /root/.cache

RUN mkdir -p /build_dbt_deps
COPY dbt/dbt_project.yml /build_dbt_deps/dbt_project.yml
COPY dbt/packages.yml /build_dbt_deps/packages.yml
RUN cd /build_dbt_deps \
    && dbt deps


ENTRYPOINT ["/bin/bash", "-c"]
