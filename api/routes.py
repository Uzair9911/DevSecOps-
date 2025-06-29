import os
from flask import request
from api import app
from api.resources.errors import UnauthorizedError, BadRequestError, NotFoundResourceError
from api.resources.helpers import Helpers
from flask import send_from_directory


@app.route('/test', methods=['GET'])
def test():
    parameter = request.args.get('parameter', type=int)

    # input validation and sanitizing
    if parameter is None:
        raise BadRequestError('Bad input parameters')

    # auth validation -> e.g credentials and permissions for operation are correct
    if not Helpers.is_valid_user(parameter):
        raise UnauthorizedError('Incorrect Credentials')

    # user <-> input identification, e.g order ID indeed belongs to current user
    if not Helpers.is_parameter_exist_in_db(parameter):
        raise NotFoundResourceError('Parameter does not exist at DB or does not belong to user')

    # some service that performs business logic, e.g finalize order
    Helpers.some_function(parameter)

    return "OK" if parameter else 0, 200


@app.route("/ping", methods=['GET'])
def ping():
    return "OK", 200


@app.route('/favicon.ico')
def favicon():
    return send_from_directory(
        os.path.join(app.root_path, 'static'),
        'favicon.ico', mimetype='image/vnd.microsoft.icon'
    )
