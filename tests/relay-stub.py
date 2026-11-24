# A local stand-in for the ntfy relay, for tests/board.sh. It never touches the network.
# POST /<topic> with a body sends the body to each open GET /<topic>/json stream, as one ntfy JSON line.
# Each POST body is also written to the log file. Usage: python3 relay-stub.py <port-file> <log-file>
import json, sys, threading, time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

port_file, log_file = sys.argv[1], sys.argv[2]
lock = threading.Lock()
streams = {}  # topic -> list of handlers' wfile


class Handler(BaseHTTPRequestHandler):
    def log_message(self, *args):
        pass

    def do_POST(self):
        topic = self.path.strip("/")
        body = self.rfile.read(int(self.headers.get("Content-Length") or 0)).decode()
        with open(log_file, "a") as f:
            f.write(f"{topic} {body}\n")
        line = (json.dumps({"id": str(time.time()), "event": "message", "topic": topic, "message": body}) + "\n").encode()
        with lock:
            for w in list(streams.get(topic, [])):
                try:
                    w.write(line); w.flush()
                except Exception:
                    streams[topic].remove(w)
        self.send_response(200); self.end_headers(); self.wfile.write(b"{}")

    def do_GET(self):
        topic = self.path.strip("/").split("/")[0]
        self.send_response(200); self.send_header("Content-Type", "application/x-ndjson"); self.end_headers()
        self.wfile.write((json.dumps({"event": "open", "topic": topic}) + "\n").encode()); self.wfile.flush()
        with lock:
            streams.setdefault(topic, []).append(self.wfile)
        while True:
            time.sleep(1)


server = ThreadingHTTPServer(("127.0.0.1", 0), Handler)
with open(port_file, "w") as f:
    f.write(str(server.server_address[1]))
server.serve_forever()
