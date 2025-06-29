class Helpers:
    @staticmethod
    def is_valid_user(parameter):
        # e.g. some logic for user authorization with using JWT
        return parameter < 3

    @staticmethod
    def is_parameter_exist_in_db(parameter):
        # e.g. some logic for getting order from storage and check if it belongs to user
        return parameter > 0

    @staticmethod
    def some_function(parameter):
        # e.g. some advanced business logic for order’s finalization as some transaction in db
        if parameter == 1:
            'raise critical error' > 1

        return parameter
