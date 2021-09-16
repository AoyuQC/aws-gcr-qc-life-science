FROM python:3.8-slim-buster

WORKDIR /usr/src/app

#COPY requirements.txt ./
#RUN pip install --no-cache-dir -r requirements.txt

COPY . .
RUN cd braket_install && ./install.sh && cd ..

CMD [ "python", "./batch-experiment.py" ]