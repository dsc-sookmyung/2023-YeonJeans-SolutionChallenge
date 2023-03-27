port = 8000
bind = f'0.0.0.0:{port}'
accesslog = './logs/access.log'
errorlog = './logs/error.log'
loglevel = 'info'
worker_class = 'uvicorn.workers.UvicornWorker'
daemon = True
