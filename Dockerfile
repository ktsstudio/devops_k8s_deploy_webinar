FROM python:3.9-slim as builder
ENV PYTHONUNBUFFERED=1

RUN pip install -U pip setuptools wheel

WORKDIR /wheels
COPY requirements.txt /requirements.txt
RUN pip wheel -r /requirements.txt


FROM python:3.9-slim
ENV PYTHONUNBUFFERED=1

COPY --from=builder /wheels /wheels
RUN pip install -U pip setuptools wheel \
      && pip install /wheels/* \
      && rm -rf /wheels \
      && rm -rf /root/.cache/pip/*

WORKDIR /code
COPY . .

EXPOSE 8000
ENV PYTHONPATH /code

RUN python manage.py collectstatic --noinput

CMD ["gunicorn", "-c", "docker/gunicorn.py", "ktswebinar.wsgi:application"]
