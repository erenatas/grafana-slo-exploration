from flask import Flask, jsonify, request
from flask.cli import FlaskGroup
from prometheus_client import make_wsgi_app, Counter, Histogram
from werkzeug.middleware.dispatcher import DispatcherMiddleware
import random, time

app = Flask(__name__)
app.wsgi_app = DispatcherMiddleware(app.wsgi_app, {
    '/metrics': make_wsgi_app()
})

cli = FlaskGroup(app)

REQUEST_COUNT = Counter(
    'app_request_count',
    'Application Request Count',
    ['method', 'endpoint', 'http_status']
)

REQUEST_LATENCY = Histogram(
    'app_request_latency_seconds',
    'Application Request Latency',
    ['method', 'endpoint']
)

@app.route('/')
def hello():
    start_time = time.time()
    REQUEST_COUNT.labels('GET', '/', 200).inc()
    response = jsonify(message='Hello, world!')
    REQUEST_LATENCY.labels('GET', '/').observe(time.time() - start_time)
    return response

@app.route('/err')
def err():
    start_time = time.time()
    REQUEST_COUNT.labels('GET', '/err', 500).inc()
    response = jsonify(message='Internal Server Error!')
    REQUEST_LATENCY.labels('GET', '/err').observe(time.time() - start_time)
    return response, 500

@app.route('/variable')
def variable():
    start_time = time.time()

    req_type = request.args.get('type', default = "ok", type = str)
    if req_type == "ok":
        REQUEST_COUNT.labels('GET', '/variable', 200).inc()
        response = jsonify(message='ok!')
        REQUEST_LATENCY.labels('GET', '/variable').observe(time.time() - start_time)
        return response
    if req_type == "ko":
        REQUEST_COUNT.labels('GET', '/variable', 500).inc()
        response = jsonify(message='Internal Server Error!')
        REQUEST_LATENCY.labels('GET', '/variable').observe(time.time() - start_time)
        return response, 500
    if req_type == "late-ok":
        rand_ms = random.randint(1, 50)
        while (True):
            cur_time = round(time.time() * 1000)
            if cur_time - round(start_time * 1000) > rand_ms:
                break
        REQUEST_COUNT.labels('GET', '/variable', 200).inc()
        response = jsonify(message='late-ok!')
        REQUEST_LATENCY.labels('GET', '/variable').observe(time.time() - start_time)
        return response

if __name__ == '__main__':
    cli()