from flask import Flask
from flask_restful import Api
from flask_log_request_id import RequestID


app = Flask(__name__)
RequestID(app)
api = Api(app)

if __name__ == '__main__':
    app.run(debug=True)

from api import routes # noqa
