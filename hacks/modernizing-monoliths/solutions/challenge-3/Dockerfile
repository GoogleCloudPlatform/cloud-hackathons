FROM    python:3.7-slim AS installer
LABEL   author="<AUTHOR>"
LABEL   created="<DATE>"
LABEL   last_updated="<DATE>"

RUN     python3 -m venv /venv
ENV     PATH="/venv/bin:$PATH"

COPY    . /dcss-test

WORKDIR /dcss-test

RUN     apt-get update; \
        apt-get install -y wget; \
        wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb; \
        dpkg -i google-chrome-stable_current_amd64.deb; \
        apt-get -y --fix-broken install; \
        dpkg -i google-chrome-stable_current_amd64.deb; \
        pip3 install -r requirements.txt; \
        rm google-chrome-stable_current_amd64.deb; \
        rm requirements.txt;

ENV     LOADBALANCER_IP="GKE SERVICE IP" 

ENTRYPOINT      ["python3", "dcss_test.py"]
