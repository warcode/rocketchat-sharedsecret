SharedSecret = "SUPERSECRET" #localStorage.getItem("rocket.chat.sharedsecret");

class EncryptMessage
	constructor: (message) ->
		if(SharedSecret)
			encrypted = CryptoJS.AES.encrypt(message.msg, SharedSecret)
			message.msg = encrypted.toString()
			message.encrypted = true
			console.log("encrypted message " + message.msg)
		return message

class DecryptMessage
	constructor: (message) ->
		if(message.encrypted)
			console.log("decrypting message " + message.msg)
			decrypted = CryptoJS.AES.decrypt(message.msg, SharedSecret)
			message.msg = decrypted.toString(CryptoJS.enc.Utf8)
		return message


RocketChat.callbacks.add 'beforeSaveMessage', EncryptMessage, RocketChat.callbacks.priority.LOW
RocketChat.callbacks.add 'renderMessage', DecryptMessage, RocketChat.callbacks.priority.HIGH