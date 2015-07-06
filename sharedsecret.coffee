SharedSecret = "SUPERSECRET"

if (Meteor.isServer)
	class EncryptMessage
		constructor: (message) ->
			if(SharedSecret)
				encrypted = CryptoJS.AES.encrypt(message.msg, SharedSecret)
				message.msg = encrypted.toString()

				#urls
				for urls in message.urls
					urls.url = CryptoJS.AES.encrypt(urls.url, SharedSecret).toString()

				message.encrypted = true
				console.log("encrypted message " + message.msg)
			return message

	RocketChat.callbacks.add 'beforeSaveMessage', EncryptMessage, RocketChat.callbacks.priority.LOW

if (Meteor.isClient)
	class DecryptMessage
		constructor: (message) ->
			if(message.encrypted)
				console.log("decrypting message " + message.msg)
				decrypted = CryptoJS.AES.decrypt(message.msg, SharedSecret).toString(CryptoJS.enc.Utf8)
				console.log("decrypted message " + decrypted)
				message.msg = decrypted
				message.html = decrypted

				#urls
				for urls in message.urls
					urls.url = CryptoJS.AES.decrypt(urls.url, SharedSecret).toString(CryptoJS.enc.Utf8)

			return message

	RocketChat.callbacks.add 'renderMessage', DecryptMessage, RocketChat.callbacks.priority.HIGH
