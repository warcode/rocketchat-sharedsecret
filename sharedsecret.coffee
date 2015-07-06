SharedSecret = "SUPERSECRET"

if (Meteor.isServer)
	class EncryptMessage
		constructor: (message) ->
			if(SharedSecret)
				encrypted = CryptoJS.AES.encrypt(message.msg, SharedSecret)
				message.msg = encrypted.toString()
				message.encrypted = true
				console.log("encrypted message " + message.msg)
			return message

	RocketChat.callbacks.add 'beforeSaveMessage', EncryptMessage, RocketChat.callbacks.priority.LOW

if (Meteor.isClient)
	class DecryptMessage
		constructor: (message) ->
			if(message.encrypted)
				console.log("decrypting message " + message.msg)
				decrypted = CryptoJS.AES.decrypt(message.msg, SharedSecret)
				messageString = decrypted.toString(CryptoJS.enc.Utf8)
				console.log("decrypted message " + messageString)
				message.msg = messageString
				message.html = messageString
			return message

	RocketChat.callbacks.add 'renderMessage', DecryptMessage, RocketChat.callbacks.priority.HIGH
