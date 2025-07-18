FROM python:3.12-slim


RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev

RUN pip install poetry

WORKDIR /app

COPY pyproject.toml poetry.lock* /app/

RUN poetry config virtualenvs.create false \
    && poetry install --no-interaction --no-ansi --no-root


COPY . /app

CMD ["gunicorn", "myproject.wsgi:application", "--bind", "0.0.0.0:8000"]