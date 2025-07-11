from flask import Flask, jsonify
import os
import socket
import time

app = Flask(__name__)

@app.route('/')
def hello():
    hostname = socket.gethostname()
    return f"Hello from {hostname}! Welcome to 2bcloud Assignment!"

@app.route('/healthz')
def health_check():
    return jsonify({
        'status': 'healthy',
        'service': '2bcloud-assignment-app',
        'version': '1.0.0'
    }), 200

@app.route('/stress/<int:n>')
def stress(n):
    """CPU-intensive endpoint for testing HPA"""
    start_time = time.time()
    result = 0
    for i in range(n * 1000000):
        result += i * i
    end_time = time.time()
    return jsonify({
        'result': result,
        'time_taken': end_time - start_time,
        'hostname': socket.gethostname() 
    }), 200

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)
