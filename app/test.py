import sqlite3
import os
from flask import Flask, request, jsonify, g

# Use local directory when running outside Docker
# In Docker: /data/tasks.db
# Locally: ./data/tasks.db (current directory)
if os.environ.get('DB_PATH'):
    DATABASE = os.environ.get('DB_PATH')
elif os.path.exists('/.dockerenv'):
    # Running inside Docker container
    DATABASE = '/data/tasks.db'
else:
    # Running locally
    DATABASE = os.path.join(os.getcwd(), 'data', 'tasks.db')

app = Flask(__name__)

def get_db():
    """Opens a new database connection if there is none yet."""
    if 'db' not in g:
        g.db = sqlite3.connect(DATABASE)
        g.db.row_factory = sqlite3.Row
    return g.db

@app.teardown_appcontext
def close_db(error):
    """Closes the database at the end of the request."""
    db = g.pop('db', None)
    if db is not None:
        db.close()

def init_db():
    """Create the tasks table in the database."""
    db = get_db()
    db.execute('''
        CREATE TABLE IF NOT EXISTS tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    db.commit()

# Initialize database when app starts (Flask 3.0 way)
with app.app_context():
    db_dir = os.path.dirname(DATABASE)
    if db_dir:  # Only create directory if path has a directory component
        os.makedirs(db_dir, exist_ok=True)
    init_db()
    print(f"Database initialized at: {DATABASE}")

@app.route('/tasks', methods=['POST'])
def create_task():
    """Create a new task - POST /tasks"""
    data = request.get_json(force=True)
    title = data.get('title')
    
    if not title:
        return jsonify({'error': 'title field is required'}), 400
    
    db = get_db()
    cursor = db.execute('INSERT INTO tasks (title) VALUES (?)', (title,))
    db.commit()
    
    return jsonify({
        'id': cursor.lastrowid,
        'title': title,
        'message': 'Task created successfully'
    }), 201

@app.route('/tasks', methods=['GET'])
def list_tasks():
    """List all tasks - GET /tasks"""
    db = get_db()
    tasks = db.execute('SELECT id, title, created_at FROM tasks ORDER BY id DESC').fetchall()
    
    return jsonify([
        {'id': task['id'], 'title': task['title'], 'created_at': task['created_at']}
        for task in tasks
    ])

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({'status': 'healthy'}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000, debug=True)
