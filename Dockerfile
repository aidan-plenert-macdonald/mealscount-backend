FROM python:3.7 AS base
ENV PYTHONUNBUFFERED 1
RUN mkdir /code
WORKDIR /code
COPY *requirements.txt /code/
RUN pip install -r requirements.txt

FROM base AS testing
RUN pip install pylint
COPY . /code/

RUN pylint **.py || true


FROM node AS npm_build
COPY package*.json /code/
WORKDIR /code/
RUN npm install node-sass
RUN npm install .

COPY --from=testing /code/ /code/
RUN npm run build

FROM base AS release
COPY --from=testing /code/ /code/
COPY --from=npm_build /code/dist/ /code/dist

CMD python /code/server.py --host=0.0.0.0
