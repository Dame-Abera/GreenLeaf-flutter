Models (Database table equivalents) and their fields (column):
    Model (table): CustomUser 
        description - represents the application user.
        fields (db table columns):
            first_name 
            last_name
            email
            profile_image
            birthdate
            gender
            phone_number
            is_active
            is_staff
        !!! Detail of possible values and constraints for these fields (column tables) can be found in accounts/models.py
    
    Model (table): PlantModel
        description: represents Plant record in the  application
        fields (db table columns):
            plant_image
            common_name
            scientific_name
            habitat
            origin
            description
            created_by
        !!! Detail of possible values and constraints for these fields (column tables) can be found in GreenLeafAPI/models.py
    
    Model (table): ObservationModel
        description: represents Observation record in the  application
        fields (db table columns):
            observation_image
            related_field
            time
            date
            location
            note
            created_by
        !!! Detail of possible values and constraints for these fields (column tables) can be found in GreenLeafAPI/models.py
            

Applications and API-endpoints: (assume the application server runs locally)
    'accounts' application: handles user registration, login, profile management.

    User registration:
        endpoint: 
            http://localhost:port_number/account/api/register/
        Method: POST
        Authentication type: None
        sample data(json):
            {
                "email":"example.com",
                "password":"secure_password",
                "confirm_password":"secure_password"
            }
        
        reponse (user registers succesfully):
            {
                "user": {
                    "email": "example@gmail.com"
                },
                "refresh": "refresh_token",
                "access": "access_token"
            }
        !!! the access_token can be used to log the user directly to the homepage 
    
    User login (JWT authentication is used):
        endpoint:
            http://localhost:port_number/account/api/token/
        method: POST
        Authentication Type: None
        sample data(json):
            {
                "email":"example.com",
                "password":"secure_password"
            }
        
        reponse (user exists):
            {
                "refresh": "refresh_token",
                "access": "access_token"
            }

    User profile view and edit (JWT authentication):
        endpoint:
            http://localhost:port_number/account/api/profile/
        methods: [GET, PATCH]
        Authenticaion type: Bearer Authentication (access token obtained from login)
        reponse (GET):
            {
                "first_name": null,
                "last_name": null,
                "birthdate": null,
                "gender": null,
                "email": "example@gmail.com",
                "phone_number": null,
                "profile_image": null
            }
        response (PATCH):
            {
                "first_name": "sample first name",
                "last_name": "sample last name",
                "birthdate": null,
                "gender": null,
                "email": "example@gmail.com",
                "phone_number": "sample phone",
                "profile_image": null
            }


'accounts' application - deals with user registration, login, profile and user-list
    

keep user logged in:
store access and refresh tokens(valid for 7-20 days) securely on device:
    flutter: flutter_secure_storage
    jetpack compose:
        EncryptedSharedPreferences: securely save tokens
        ViewModel: manage authentication state
        Coroutine: make refresh requests in background
        Navigation: send user to login if token is invalid


check if access stored token is valid:
    yes: authenticate user
    no: use refersh token to get new access token 

