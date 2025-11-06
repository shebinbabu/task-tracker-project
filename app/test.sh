# 1. Flask app runs directly
echo "✓ Testing Flask directly..."
source venv/bin/activate
python app/app.py &
FLASK_PID=$!
sleep 3
curl -s http://localhost:8000/health | grep healthy && echo "✓ Flask works!"
kill $FLASK_PID
deactivate

# 2. Docker image builds
echo "✓ Testing Docker build..."
docker build -t task-tracker:local . && echo "✓ Docker build works!"

# 3. Container runs
echo "✓ Testing Docker run..."
docker run -d --name test-run -p 8001:8000 task-tracker:local
sleep 3
curl -s http://localhost:8001/health | grep healthy && echo "✓ Docker run works!"
docker stop test-run && docker rm test-run

# 4. Deployment script works
echo "✓ Testing deployment script..."
./scripts/deploy.sh task-tracker:local 8002
sleep 3
curl -s http://localhost:8002/health | grep healthy && echo "✓ Deployment script works!"

# 5. Data persistence
echo "✓ Testing data persistence..."
curl -X POST http://localhost:8002/tasks -H "Content-Type: application/json" -d '{"title":"Persistence test"}'
BEFORE=$(curl -s http://localhost:8002/tasks | grep -c "Persistence test")
docker restart task-tracker
sleep 3
AFTER=$(curl -s http://localhost:8002/tasks | grep -c "Persistence test")
[ "$BEFORE" -eq "$AFTER" ] && echo "✓ Data persistence works!"

echo ""
echo "All tests passed! ✓"
