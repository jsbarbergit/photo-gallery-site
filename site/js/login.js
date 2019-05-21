//AWS IDs
var constRegion = 'eu-west-1';
var constIdentityPoolId = 'eu-west-1:fd58c1e2-d075-4746-bfb7-9c03eb86ccd5';
var constUserPoolId = 'eu-west-1_33BNzuB0F';
var constClientId = '3tvhifd1o8hlbkamto8r8aa4st';
var constCognitoProviderId = 'cognito-idp.' + constRegion + '.amazonaws.com/' + constUserPoolId;

var poolData = {
    UserPoolId : constUserPoolId, // your user pool id here
    ClientId : constClientId // your app client id here
};


var userPool = 
new AmazonCognitoIdentity.CognitoUserPool(poolData);

function cognitoLogin(username, password) {
	var userData = {
		Username : username, // your username here
		Pool : userPool
	};
	var authenticationData = {
        Username : username, // your username here
        Password : password, // your password here
    };
    var authenticationDetails = 
new AmazonCognitoIdentity.AuthenticationDetails(authenticationData);
 
	var attributeList = [];
	
	var dataName = {
		Name : 'name',
		Value : username,
	};
	var attributeName = 
	new AmazonCognitoIdentity.CognitoUserAttribute(dataName);

	attributeList.push(attributeName);


    var cognitoUser = 
new AmazonCognitoIdentity.CognitoUser(userData);
    cognitoUser.authenticateUser(authenticationDetails, {
        onSuccess: function (result) {
			var accessToken = result.getAccessToken().getJwtToken();
			console.log('Logged In :)');
        },
 
        onFailure: function(err) {
			alert(err);
			console.log('Failed To Log In :(');
        },
        // mfaRequired: function(codeDeliveryDetails) {
        //     var verificationCode = prompt('Please input verification code' ,'');
        //     cognitoUser.sendMFACode(verificationCode, this);
		// }
		newPasswordRequired: function(userAttributes, requiredAttributes) {
            // User was signed up by an admin and must provide new 
            // password and required attributes, if any, to complete 
            // authentication.

            // userAttributes: object, which is the user's current profile. It will list all attributes that are associated with the user. 
            // Required attributes according to schema, which don’t have any values yet, will have blank values.
            // requiredAttributes: list of attributes that must be set by the user along with new password to complete the sign-in.

            
            // Get these details and call 
            // newPassword: password that user has given
			// attributesData: object with key as attribute name and value that the user has given.
			var newPassword = prompt("This is the first time you've logged in. Please enter a new password:", "")
			cognitoUser.completeNewPasswordChallenge(newPassword, this.attributeList, this);
		}
    });
}